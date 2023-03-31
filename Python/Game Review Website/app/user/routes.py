from datetime import datetime
from sqlalchemy import func
from flask import render_template, flash, redirect, url_for, request, jsonify, current_app
from flask_login import login_required, current_user
from app import db
from app.user import bp
from app.forms.user import EditProfileForm, MessageForm
from app.forms.review import DeleteReviewForm
from app.models import User, Review, Notification, Message

#@bp.route('/<username>', methods=['GET', 'POST'])
#@bp.route('/<username>/', methods=['GET', 'POST'])
#def user(username):
#  user = User.query.filter(func.lower(User.username) == func.lower(username)).first_or_404()

#  page = request.args.get('page', 1, type=int)
#  reviews = user.reviews.order_by(Review.timestamp.desc()).paginate(
#    page, current_app.config['REVIEWS_PER_PAGE'], False
#  )
#  first_page = url_for('.user', username=username, page=1)
#  last_page = url_for('.user', username=username, page=reviews.pages)

#  next_url = url_for('.user', username=username, page=reviews.next_num) \
#    if reviews.has_next else None
#  prev_url = url_for('.user', username=username, page=reviews.prev_num) \
#    if reviews.has_prev else None

#  delete_review_form = DeleteReviewForm()
#  form = EditProfileForm(original_username=current_user.username)
#  if form.validate_on_submit():
#    current_user.username = form.username.data
#    db.session.commit()
#    flash('Your changes have been saved.')
#    return redirect(url_for('.user', username=form.username.data))
#  elif request.method == 'GET':
#    form.username.data = current_user.username

# return render_template('user/user.html', user=user, reviews=reviews.items, delete_review_form=delete_review_form, form=form, page=page, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)

@bp.route('/<username>')
@bp.route('/<username>/')
def profile(username):
  user = User.query.filter(func.lower(User.username) == func.lower(username)).first_or_404()

  page = request.args.get('page', 1, type=int)
  reviews = user.reviews.order_by(Review.timestamp.desc()).paginate(
    page, current_app.config['REVIEWS_PER_PAGE'], False
  )
  first_page = url_for('.profile', username=username, page=1)
  last_page = url_for('.profile', username=username, page=reviews.pages)

  next_url = url_for('.profile', username=username, page=reviews.next_num) \
    if reviews.has_next else None
  prev_url = url_for('.profile', username=username, page=reviews.prev_num) \
    if reviews.has_prev else None

  delete_review_form = DeleteReviewForm()

  return render_template('user/profile.html', user=user, reviews=reviews.items, delete_review_form=delete_review_form, page=page, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)

@bp.route('/send_message/<recipient>', methods=['GET', 'POST'])
@bp.route('/send_message/<recipient>/', methods=['GET', 'POST'])
@login_required
def send_message(recipient):
  user = User.query.filter_by(username=recipient).first_or_404()
  form = MessageForm()
  if form.validate_on_submit():
    msg = Message(author=current_user, recipient=user, body=form.message.data)
    user.add_notification('unread_message_count', user.new_messages())
    db.session.add(msg)
    db.session.commit()
    flash('Your message has been sent.')
    return redirect(url_for('user.profile', username=recipient))
  return render_template('user/send_message.html', title='Send Message', form=form, recipient=recipient)

@bp.route('/messages')
@bp.route('/messages/')
@login_required
def messages():
  current_user.last_message_read_time = datetime.utcnow()
  current_user.add_notification('unread_message_count', 0)
  db.session.commit()
  page = request.args.get('page', 1, type=int)
  messages = current_user.messages_received.order_by(Message.timestamp.desc()).paginate(
    page, current_app.config['MESSAGES_PER_PAGE'], False
  )
  first_page = url_for('.messages', page=1)
  last_page = url_for('.messages', page=messages.pages)

  next_url = url_for('.messages', page=messages.next_num) \
    if messages.has_next else None
  prev_url = url_for('.messages', page=messages.prev_num) \
    if messages.has_prev else None

  return render_template('user/messages.html', messages=messages.items, page=page, first_page=first_page, last_page=last_page, next_url=next_url, prev_url=prev_url)

@bp.route('/notifications', methods=['GET'])
@bp.route('/notifications/', methods=['GET'])
@login_required
def notifications():
  since = request.args.get('since', 0.0, type=float)
  notifications = current_user.notifications.filter(
    Notification.timestamp > since).order_by(Notification.timestamp.asc())
  return jsonify([{
      'name': n.name,
      'data': n.get_data(),
      'timestamp': n.timestamp
    } for n in notifications ])


@bp.route('/follow/<username>')
@bp.route('/follow/<username>/')
@login_required
def follow(username):
  user = User.query.filter(func.lower(User.username) == func.lower(username)).first()
  if user is None:
    flash('User {} not found.'.format(username))
    return redirect(url_for('game.games'))
  if user == current_user:
    flash('You cannot follow yourself!')
    return redirect(url_for('.user', username=username))
  current_user.follow(user)
  db.session.commit()
  flash('You are following {}!'.format(username))
  return redirect(url_for('.user', username=username))

@bp.route('/unfollow/<username>')
@bp.route('/unfollow/<username>/')
@login_required
def unfollow(username):
  user = User.query.filter(func.lower(User.username) == func.lower(username)).first()
  if user is None:
    flash('User {} not found.'.format(username))
    return redirect(url_for('game.games'))
  if user == current_user:
    flash('You cannot unfollow yourself!')
    return redirect(url_for('.user', username=username))
  current_user.unfollow(user)
  db.session.commit()
  flash('You are not following {}.'.format(username))
  return redirect(url_for('.user', username=username))

@bp.route('/delete/review/<int:review_id>', methods=['POST'])
@bp.route('/delete/review/<int:review_id>/', methods=['POST'])
@login_required
def delete_review(review_id):
  review = Review.query.filter_by(id=review_id).first_or_404()
  if current_user.id != review.author.id:
    return redirect(url_for('.user', username=current_user.username))

  db.session.delete(review)
  db.session.commit()

  flash('You have successfully deleted your review')
  return redirect(url_for('.user', username=current_user.username))

@bp.route('/export_reviews')
@bp.route('/export_reviews/')
@login_required
def export_reviews():
  if current_user.get_task_in_progress('export_reviews'):
    flash('An export task is currently in progress')
  else:
    current_user.launch_task('normal', 'export_reviews', 'Exporting reviews...')
    db.session.commit()
  return redirect(url_for('.profile', username=current_user.username))
