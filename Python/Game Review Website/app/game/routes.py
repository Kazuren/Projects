import re
import requests
import urllib.request
import os
from time import time
from flask import render_template, flash, redirect, url_for, current_app, request, abort, jsonify, g
from flask_login import login_required, current_user
from bs4 import BeautifulSoup
from sqlalchemy import func, union, select, literal, exists
from datetime import datetime, timedelta
from dateutil import parser
from multiprocessing import Process, Queue
from app import db
from app.game import bp
from app.game.helpers import lookup
from app.forms.game import AddGameForm, FilterForm, SearchForm
from app.forms.review import ReviewForm, FilterReviewForm, DeleteReviewForm
from app.models import Game, Review, Category, CategoryUpvote, User, Developer, Revision, Platform

@bp.route('/games', methods=['GET', 'POST'])
@bp.route('/games/', methods=['GET', 'POST'])
@bp.route('/', methods=['GET', 'POST'])
def games():
  categories = Category.query.order_by(Category.name).all()
  developers = Developer.query.order_by(Developer.name).all()
  platforms = Platform.query.order_by(Platform.name).all()
  page = request.args.get('page', 1, type=int)

  form = FilterForm()
  form.categories.choices = [(category.id, category.name) for category in categories]
  form.developers.choices = [(developer.id, developer.name) for developer in developers]
  form.platforms.choices = [(platform.id, platform.name) for platform in platforms]

  if form.validate_on_submit():
    if form.data['sort_by'] == 'active':
      order = Game.activity.desc()
    elif form.data['sort_by'] == 'top':
      order = Game.avg_rating.desc()
    else:
      order = Game.activity.desc()

    if len(form.data['categories']) > 0:
      ids = union(*[select([literal(i).label('id')]) for i in form.data['categories']])
      if not form.data['filter_by_or']:
        cat_filter_and = ~exists(
          ids.select()
            .except_(Game.categories
                .correlate(Game)
                .with_entities(Category.id)
                .subquery()
                .select()))
      else:
        cat_filter_or = exists(
          ids.select()
            .intersect(Game.categories
                .correlate(Game)
                .with_entities(Category.id)
                .subquery()
                .select()))

    if len(form.data['categories']) > 0 and len(form.data['developers']) > 0 and len(form.data['platforms']) > 0:
      dev_filter = Game.developers.any(Developer.id.in_(form.data['developers']))
      plat_filter = Game.platforms.any(Platform.id.in_(form.data['platforms']))
      if not form.data['filter_by_or']:
        cat_filter = cat_filter_and
        
      else:
        cat_filter = cat_filter_or

    elif len(form.data['developers']) > 0 and len(form.data['platforms']) > 0:
      dev_filter = Game.developers.any(Developer.id.in_(form.data['developers']))
      plat_filter = Game.platforms.any(Platform.id.in_(form.data['platforms']))
      cat_filter = None

    elif len(form.data['categories']) > 0 and len(form.data['platforms']) > 0:
      dev_filter = None
      plat_filter = Game.platforms.any(Platform.id.in_(form.data['platforms']))
      if not form.data['filter_by_or']:
        cat_filter = cat_filter_and
        
      else:
        cat_filter = cat_filter_or

    elif len(form.data['categories']) > 0 and len(form.data['developers']) > 0:
      dev_filter = Game.developers.any(Developer.id.in_(form.data['developers']))
      plat_filter = None
      if not form.data['filter_by_or']:
        cat_filter = cat_filter_and
        
      else:
        cat_filter = cat_filter_or

    elif len(form.data['developers']) > 0:
      dev_filter = Game.developers.any(Developer.id.in_(form.data['developers']))
      plat_filter = None
      cat_filter = None

    elif len(form.data['platforms']) > 0:
      dev_filter = None
      plat_filter = Game.platforms.any(Platform.id.in_(form.data['platforms']))
      cat_filter = None

    elif len(form.data['categories']) > 0:
      dev_filter = None
      plat_filter = None
      if not form.data['filter_by_or']:
        cat_filter = cat_filter_and

      else:
        cat_filter = cat_filter_or

    else:
      dev_filter = None
      cat_filter = None
      plat_filter = None

    if dev_filter is not None and plat_filter is not None and cat_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(dev_filter) \
        .filter(plat_filter) \
        .filter(cat_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)
    
    elif dev_filter is not None and plat_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(dev_filter) \
        .filter(plat_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)
    
    elif plat_filter is not None and cat_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(plat_filter) \
        .filter(cat_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)

    elif dev_filter is not None and cat_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(dev_filter) \
        .filter(cat_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)

    elif dev_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(dev_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)

    elif plat_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(plat_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)

    elif cat_filter is not None:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .filter(cat_filter) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)

    else:
      games = Game.query \
        .filter(Game.game_type == "game") \
        .filter(Game.release_date >= datetime.utcnow() - timedelta(days=form.data['release_date'])) \
        .order_by(order) \
        .paginate(page, current_app.config['GAMES_PER_PAGE'], False)

    first_page = url_for('.games', page=1)
    last_page = url_for('.games', page=games.pages)

    next_url = url_for('.games', page=games.next_num) \
      if games.has_next else None
    prev_url = url_for('.games', page=games.prev_num) \
      if games.has_prev else None

    return render_template('game/games.html', title='Home', games=games.items, categories=categories, form=form, page=page, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)

  else:
    games = Game.query.filter(Game.game_type == "game") \
      .order_by(Game.activity.desc()).paginate(
        page, current_app.config['GAMES_PER_PAGE'], False
      )
  
    first_page = url_for('.games', page=1)
    last_page = url_for('.games', page=games.pages)

    next_url = url_for('.games', page=games.next_num) \
      if games.has_next else None
    prev_url = url_for('.games', page=games.prev_num) \
      if games.has_prev else None

  return render_template('game/games.html', title='Home', games=games.items, categories=categories, form=form, page=page, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)

@bp.route('/games/<slug>', methods=['GET', 'POST'])
@bp.route('/games/<slug>/', methods=['GET', 'POST'])
def game(slug):
  game = Game.query.filter_by(slug=slug).first_or_404()
  categories = Category.query.order_by(Category.name).all()
  feed = lookup(game)
  form = ReviewForm()
  delete_review_form = DeleteReviewForm()
  filter_review_form = FilterReviewForm()
  if not current_user.is_anonymous:
    review = Review.query.filter_by(user_id=current_user.id, game_id=game.id).first()
  if form.submit.data and form.validate():
    if review:
      flash('You have already submitted a review for this game!')
      return redirect(url_for('.game', slug=slug))

    data = form.content.data
    soup = BeautifulSoup(data, "html.parser")

    for x in soup.findAll():
      if len(x.text.strip()) == 0:
        x.extract()

    timestamp = datetime.utcnow()
    review = Review(body=str(soup), rating=form.rating.data, game=game, author=current_user, timestamp=timestamp)
    db.session.add(review)
    db.session.commit()
    flash('Your review was submitted.')
    return redirect(url_for('.game', slug=slug))

  elif filter_review_form.submit_review_filter.data and filter_review_form.validate():
    page = request.args.get('page', 1, type=int)
    order = None
    join = None
    if filter_review_form.data['sort_by'] == 'active':
      order = Review.timestamp.desc()
    elif filter_review_form.data['sort_by'] == 'top':
      order = Review.score.desc()
    elif filter_review_form.data['sort_by'] == 'positive':
      order = Review.rating.desc()
    elif filter_review_form.data['sort_by'] == 'negative':
      order = Review.rating
    else:
      order = Review.timestamp.desc()

    if join:
      if current_user.is_anonymous:
        reviews = game.reviews \
          .filter(Review.timestamp >= datetime.utcnow() - timedelta(days=filter_review_form.data['date'])) \
          .join(join) \
          .order_by(order) \
          .paginate(page, current_app.config['REVIEWS_PER_PAGE'], False)
      else:
        reviews = game.reviews \
          .filter(Review.timestamp >= datetime.utcnow() - timedelta(days=filter_review_form.data['date']), Review.user_id != current_user.id) \
          .join(join) \
          .order_by(order) \
          .paginate(page, current_app.config['REVIEWS_PER_PAGE'], False)
    else:
      if current_user.is_anonymous:
        reviews = game.reviews \
          .filter(Review.timestamp >= datetime.utcnow() - timedelta(days=filter_review_form.data['date'])) \
          .order_by(order) \
          .paginate(page, current_app.config['REVIEWS_PER_PAGE'], False)
      else:
        reviews = game.reviews \
          .filter(Review.timestamp >= datetime.utcnow() - timedelta(days=filter_review_form.data['date']), Review.user_id != current_user.id) \
          .order_by(order) \
          .paginate(page, current_app.config['REVIEWS_PER_PAGE'], False)


    first_page = url_for('.game', slug=slug, page=1)
    last_page = url_for('.game', slug=slug, page=reviews.pages)

    next_url = url_for('.game', slug=slug, page=reviews.next_num) \
      if reviews.has_next else None
    prev_url = url_for('.game', slug=slug, page=reviews.prev_num) \
      if reviews.has_prev else None

    return render_template('game/game.html', form=form, filter_review_form=filter_review_form, game=game, reviews=reviews.items, page=page, categories=categories, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)
  else:
    page = request.args.get('page', 1, type=int)
    if not current_user.is_anonymous:
      reviews = game.reviews \
        .filter(Review.user_id != current_user.id) \
        .order_by(Review.timestamp.desc()).paginate(
          page, current_app.config['REVIEWS_PER_PAGE'], False
        )
    else:
      reviews = game.reviews \
        .order_by(Review.timestamp.desc()).paginate(
          page, current_app.config['REVIEWS_PER_PAGE'], False
        )

    first_page = url_for('.game', slug=slug, page=1)
    last_page = url_for('.game', slug=slug, page=reviews.pages)

    next_url = url_for('.game', slug=slug, page=reviews.next_num) \
      if reviews.has_next else None
    prev_url = url_for('.game', slug=slug, page=reviews.prev_num) \
      if reviews.has_prev else None

  if not current_user.is_anonymous:
    if review: # If the user has left a review render the review instead of form
      return render_template('game/game.html', review=review, delete_review_form=delete_review_form, filter_review_form=filter_review_form, game=game, reviews=reviews.items, page=page, categories=categories, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)
    else:
      return render_template('game/game.html', form=form, filter_review_form=filter_review_form, game=game, reviews=reviews.items, page=page, categories=categories, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)
  else:
    return render_template('game/game.html', form=form, filter_review_form=filter_review_form, game=game, reviews=reviews.items, page=page, categories=categories, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)


@bp.route('/games/<slug>/edit', methods=['GET', 'POST'])
@bp.route('/games/<slug>/edit/', methods=['GET', 'POST'])
@login_required
def edit(slug):
  game = Game.query.filter_by(slug=slug).first_or_404()
  review = Review.query.filter_by(user_id=current_user.id, game_id=game.id).first_or_404()

  form = ReviewForm()
  if form.validate_on_submit():
    data = form.content.data
    soup = BeautifulSoup(data, "html.parser")

    for x in soup.findAll():
      if len(x.text.strip()) == 0:
        x.extract()

    if review.timestamp < datetime.utcnow() - timedelta(days=7):
      revision = Revision(review=review, body=str(soup), rating=form.rating.data)
      review.timestamp = datetime.utcnow()
      review.timestamp_in_seconds = time()

    review.body = str(soup)
    review.rating = form.rating.data

    db.session.commit()
    flash('Your changes have been saved.')
    return redirect(url_for('.game', slug=slug))

  elif request.method == 'GET':
    form.content.data = review.body
    form.rating.data = review.rating

  return render_template('game/edit.html', form=form, game=game, review=review)

@bp.route('/games/<slug>/<username>/revisions')
@bp.route('/games/<slug>/<username>/revisions/')
def revisions(slug, username):
  game = Game.query.filter_by(slug=slug).first_or_404()
  user = User.query.filter(func.lower(User.username) == func.lower(username)).first_or_404()
  review = Review.query.filter_by(user_id=user.id, game_id=game.id).first_or_404()

  return render_template('game/revisions.html', review=review, revisions=review.revisions)

@bp.route('/games/add', methods=['GET', 'POST'])
@bp.route('/games/add/', methods=['GET', 'POST'])
@login_required
def add():
  form = AddGameForm()
  if form.validate_on_submit():
    data = form.data['url'].split('//')
    if len(data) == 2:
      protocol = data[0]
      domain = data[1]
    elif len(data) == 1:
      domain = data[0]
    else:
      flash('An error occured when adding this game, please try again later.')
      return(redirect(url_for('.add')))

    if "store.steampowered.com" in domain:

      if current_user.get_task_in_progress('add_steam_game'):
        flash('Adding a game is currently in progress')
      else:
        current_user.launch_task('low', 'add_steam_game', 'Adding game...', domain)
        db.session.commit()
      return redirect(url_for('.games'))

    else:
      flash('An error occured when adding this game, please try again later.')
      return(redirect(url_for('.add')))

  return render_template('game/add_game.html', form=form)

@bp.route('/games/upvote/<int:review_id>', methods=['POST'])
@bp.route('/games/upvote/<int:review_id>/', methods=['POST'])
@login_required
def upvote(review_id):
  review = Review.query.filter_by(id=review_id).first_or_404()
  if review.author == current_user:
    return jsonify({'success': False, 'message': "You can't upvote yourself!"})

  review.add_upvote(current_user)
  db.session.commit()
  if review.is_upvoted(current_user):
    return jsonify({'success': True, 'upvoted': True})
  else:
    return jsonify({'success': True, 'upvoted': False})

@bp.route('/games/downvote/<int:review_id>', methods=['POST'])
@bp.route('/games/downvote/<int:review_id>/', methods=['POST'])
@login_required
def downvote(review_id):
  review = Review.query.filter_by(id=review_id).first_or_404()
  if review.author == current_user:
    return jsonify({'success': False, 'message': "You can't downvote yourself!"})
  if current_user.reputation < 25:
    return jsonify({'success': False, 'message': "You must have at least 25 reputation to downvote reviews"})

  review.add_downvote(current_user)
  db.session.commit()
  if review.is_downvoted(current_user):
    return jsonify({'success': True, 'downvoted': True})
  else:
    return jsonify({'success': True, 'downvoted': False})

@bp.route('/games/<slug>/upvote/<int:category_id>', methods=['GET', 'POST'])
@bp.route('/games/<slug>/upvote/<int:category_id>/', methods=['GET', 'POST'])
@login_required
def upvote_category(slug, category_id):
  game = Game.query.filter_by(slug=slug).first_or_404()
  category = Category.query.filter_by(id=category_id).first_or_404()

  game.add_upvote(category=category, user=current_user)
  db.session.commit()
  return jsonify({'success': True })

@bp.route('/games/search')
@bp.route('/games/search/')
def search():
  if not g.search_form.validate():
    return redirect(url_for('.games'))
  
  categories = Category.query.order_by(Category.name).all()
  developers = Developer.query.order_by(Developer.name).all()
  platforms = Platform.query.order_by(Platform.name).all()

  form = FilterForm()
  form.categories.choices = [(category.id, category.name) for category in categories]
  form.developers.choices = [(developer.id, developer.name) for developer in developers]
  form.platforms.choices = [(platform.id, platform.name) for platform in platforms]

  page = request.args.get('page', 1, type=int)
  if not g.search_form.q.data.strip():
    games = Game.query.filter(Game.game_type == "game") \
      .order_by(Game.activity.desc()).paginate(
        page, current_app.config['GAMES_PER_PAGE'], False
      )
  
    first_page = url_for('.games', page=1)
    last_page = url_for('.games', page=games.pages)

    next_url = url_for('.games', page=games.next_num) \
      if games.has_next else None
    prev_url = url_for('.games', page=games.prev_num) \
      if games.has_prev else None
    games = games.items
  else:
    games, total = Game.search(g.search_form.q.data, page, current_app.config['GAMES_PER_PAGE'])
    next_url = url_for('.search', q=g.search_form.q.data, page=page + 1) \
      if total > page * current_app.config['GAMES_PER_PAGE'] else None
    prev_url = url_for('.search', q=g.search_form.q.data, page=page - 1) \
      if page > 1 else None

    first_page = url_for('.games', page=1)
    last_page = url_for('.games', page=999) #games.pages len(games) / current_app.config['GAMES_PER_PAGE'] , games.count() / current_app.config['GAMES_PER_PAGE']

  return render_template('game/games.html', title='Search', games=games, categories=categories, form=form, page=page, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)

@bp.route('/games/delete/game/<int:review_id>', methods=['POST'])
@bp.route('/games/delete/game/<int:review_id>/', methods=['POST'])
@login_required
def delete_review(review_id):
  review = Review.query.filter_by(id=review_id).first_or_404()
  game = Game.query.filter_by(id=review.game_id).first_or_404()
  if current_user.id != review.author.id:
    return redirect(url_for('.game', slug=game.slug))

  db.session.delete(review)
  db.session.commit()

  flash('You have successfully deleted your review')
  return redirect(url_for('.game', slug=game.slug))
