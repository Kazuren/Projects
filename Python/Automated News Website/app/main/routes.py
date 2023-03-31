from datetime import datetime, timedelta
from flask import render_template, current_app, request, url_for, abort, jsonify
from sqlalchemy import or_, func
from app import db
from app.main import bp
from app.main.forms import FilterForm
from app.models import Article, Source, Country

@bp.route('/', methods=['GET'])
def articles():
  page = request.args.get('page', 1, type=int)
  q = request.args.get('q', None, type=str)

  form = FilterForm()
  if form.validate():
    query = Article.query.join(Source)

    if q:
      query = query.filter(func.lower(Article.title).like("%{0}%".format(q).lower()))

    if form.sources.data:
      query = query.filter(Source.id.in_(form.sources.data))

    if form.categories.data:
      if 'all' in form.categories.data:
        query = query.filter(Source.category.in_(['general', 'technology', 'business', 'sports', 'entertainment', 'science']))
      else:
        query = query.filter(Source.category.in_(form.categories.data))

    if form.publication_date.data:
      query = query.filter(Article.timestamp >= datetime.utcnow() - timedelta(days=form.publication_date.data))
    else:
      query = query.filter(Article.timestamp >= datetime.utcnow() - timedelta(days=7))

    articles = query.order_by(Article.timestamp.desc()).paginate(page, current_app.config['ARTICLES_PER_PAGE'], True)

  else:
    articles = Article.query \
      .filter(Article.timestamp >= datetime.utcnow() - timedelta(days=7)) \
      .order_by(Article.timestamp.desc()) \
      .paginate(page, current_app.config['ARTICLES_PER_PAGE'], True)

  kwargs = {
    'q': q,
    'sources': form.sources.data,
    'categories': form.categories.data,
    'publication_date': form.publication_date.data
  }
  kwargs_without_query = {
    'sources': form.sources.data,
    'categories': form.categories.data,
    'publication_date': form.publication_date.data
  }
  pages = articles.pages
  current_page = url_for('.articles', page=page, **kwargs)
  first_page = url_for('.articles', page=1, **kwargs)
  last_page = url_for('.articles', page=pages, **kwargs)
  
  next_url = url_for('.articles', page=articles.next_num, **kwargs) \
    if articles.has_next else None

  prev_url = url_for('.articles', page=articles.prev_num, **kwargs) \
    if articles.has_prev else None

  return render_template('articles.html', 
    articles=articles.items,
    page=page, pages=pages, route="/", # category=category,
    title="Home", # category.capitalize() if category else "Home",
    current_page=current_page, first_page=first_page, last_page=last_page,
    next_url=next_url, prev_url=prev_url, form=form, q=q, kwargs_without_query=kwargs_without_query
  )

@bp.route('/sources')
@bp.route('/sources/')
def sources():
  sources = Source.query.order_by(Source.name).all()

  return render_template('sources.html', sources=sources, title="Sources", route="/sources/")

@bp.route('/articles/<article_id>')
@bp.route('/articles/<article_id>/')
def article(article_id):
  article = Article.query.filter_by(id=article_id).first_or_404()
  source = article.source

  return render_template('link_to_article.html', article=article, source=source, title=article.title, route="/articles/article/")


@bp.route('/sources/<source_id>')
@bp.route('/sources/<source_id>/')
def source(source_id):
  page = request.args.get('page', 1, type=int)
  q = request.args.get('q', None, type=str)

  source = Source.query.filter_by(id=source_id).first_or_404()
  query = Article.query.filter_by(source=source).order_by(Article.timestamp.desc())
  if q:
    query = query.filter(or_(func.lower(Article.title).like("%{0}%".format(q).lower()), func.lower(Article.body).like("%{0}%".format(q).lower())))

  articles = query.paginate(page, current_app.config['ARTICLES_PER_PAGE'], True)

  kwargs = {
    'q': q
  }
  
  current_page = url_for('.source', source_id=source_id, page=page, **kwargs)
  first_page = url_for('.source', source_id=source_id, page=1, **kwargs)
  last_page = url_for('.source', source_id=source_id, page=articles.pages, **kwargs)
  pages = articles.pages

  next_url = url_for('.source', source_id=source_id, page=articles.next_num, **kwargs) \
    if articles.has_next else None

  prev_url = url_for('.source', source_id=source_id, page=articles.prev_num, **kwargs) \
    if articles.has_prev else None
  

  return render_template('articles.html', 
    articles=articles.items, title=source.name,
    page=page, pages=pages,
    current_page=current_page, first_page=first_page, last_page=last_page,
    next_url=next_url, prev_url=prev_url,
    route="/sources/source/", source=source, q=q
  )


@bp.route('/contact')
@bp.route('/contact/')
def contact():
  return render_template('contact.html', title="Contact")

@bp.route('/about')
@bp.route('/about/')
def about():
  return render_template('about.html', title="About")

@bp.route('/privacy')
@bp.route('/privacy/')
def privacy():
  return render_template('privacy.html', title="Privacy Policy")

@bp.route('/terms')
@bp.route('/terms/')
def terms():
  return render_template('terms.html', title="Terms of Service")

@bp.route('/api/sources')
@bp.route('/api/sources/')
def get_sources():
  sources = [source.to_dict() for source in Source.query.all()]
  return jsonify(sources)
