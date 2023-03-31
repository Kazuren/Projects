import os
import time
import atexit
from flask import Flask, request, current_app
from flask_sqlalchemy import SQLAlchemy as _BaseSQLAlchemy
from flask_migrate import Migrate
from flask_moment import Moment
from threading import Thread
from config import Config
from celery import Celery
from celery.schedules import crontab
import celeryconfig
import requests

class SQLAlchemy(_BaseSQLAlchemy):
  def apply_pool_defaults(self, app, options):
    super(SQLAlchemy, self).apply_pool_defaults(app, options)
    options["pool_pre_ping"] = True

db = SQLAlchemy()
migrate = Migrate()
moment = Moment()
celery = Celery(__name__, broker=Config.CELERY_BROKER_URL)

def add_countries(app, countries):
  with app.app_context():
    
    for country in countries:
      already_exists = Country.query.filter_by(country_code=country['country_code']).first()
      if already_exists:
        continue
      country = Country(
        country_code = country['country_code'],
        language_code = country['language_code'],
        language = country['language'],
        name = country['name']
      )
      db.session.add(country)
    db.session.commit()

def add_sources(app, banned_sources):
  with app.app_context():
    payload = {'language': 'en', 'apiKey': current_app.config['NEWS_API_KEY']}
    try:
      r = requests.get('https://newsapi.org/v2/sources', params=payload)
    except (
      requests.exceptions.TooManyRedirects, requests.exceptions.ConnectionError, 
      requests.exceptions.HTTPError, requests.exceptions.Timeout, 
      requests.exceptions.ReadTimeout, requests.exceptions.URLRequired
    ) as e:
      sources = []
    data = r.json()
    if data['status'] == "error":
      sources = []

    sources = data['sources']
    db_sources = Source.query.all()
    for source in sources:
      if source['id'] in banned_sources:
        found_source = Source.query.filter_by(id=source['id']).first()
        if found_source:
          db.session.delete(found_source)
        continue

      found_source = Source.query.filter_by(id=source['id']).first()
      if found_source:
        continue
      country = Country.query.filter_by(country_code=source['country']).first()
      if not country:
        continue
      source = Source(
        id=source['id'],
        name=source['name'], 
        description=source['description'],
        url=source['url'],
        category=source['category'],
        country=country
      )
      db.session.add(source)
    db.session.commit()

def add_cookies(app, cookies):
  with app.app_context():
    for cookie in cookies:
      source = Source.query.filter_by(id=cookie['source']).first()
      already_exists = Cookie.query.filter_by(name=cookie['name'], source=source).first()
      if already_exists:
        continue
      cookie_ = Cookie(name=cookie['name'], value=cookie['value'], source=source)
      db.session.add(cookie_)
    db.session.commit()

def setup(app):
  # This will fail if database is not initialized/upgraded to latest version
  countries = [
    {
      "country_code": "us",
      "language_code": "en",
      "language": "English",
      "name": "United States"
    },
    {
      "country_code": "au",
      "language_code": "en",
      "language": "English",
      "name": "Australia"
    },
    {
      "country_code": "gb",
      "language_code": "en",
      "language": "English",
      "name": "United Kingdom"
    },
  ]
  banned_sources = [
    'reddit-r-all', # Banned because reddit
    'ign', # Banned because User Agent doesn't work
    'four-four-two', # No content
    'google-news-au', # No content
    'google-news-uk', # No content
    'hacker-news', # No content
    'medical-news-today', # No content
    'mtv-news-uk', # Low effort content
    'next-big-future', # No content
    'talksport', # No content
    'the-guardian-uk', # No content
    'the-lad-bible', # No content
    'the-sport-bible', # No content
    'financial-times', # No content
    'espn', # No content
    'buzzfeed', # Low effort content
    'business-insider-uk', # No content
    'bbc-sport', # No content
    'bloomberg' # No content
  ]
  cookies = [
    {
      "name": "euConsent",
      "value": "true",
      "source": "entertainment-weekly"
    },
    {
      "name": "euConsent",
      "value": "true",
      "source": "fortune"
    },
    {
      "name": "euConsent",
      "value": "true",
      "source": "time"
    },
    {
      "name": "wp_gdpr",
      "value": "1|1",
      "source": "the-washington-post"
    },
  ]

  try:
    add_countries(app, countries)
  except Exception:
    pass

  try:
    add_sources(app, banned_sources)
  except Exception:
    pass

  try:
    add_cookies(app, cookies)
  except Exception:
    pass


def create_app(config_class=Config):
  app = Flask(__name__, static_folder='static', static_url_path='')
  app.config.from_object(config_class)

  db.init_app(app)
  migrate.init_app(app, db)
  moment.init_app(app)
  celery.conf.update(app.config)

  try:
    with app.app_context():
      sources = Source.query.all()
      comma_seperated_list_of_sources = ""
      for i, source in enumerate(sources):
        if i == 0:
          comma_seperated_list_of_sources += "{0}".format(source.id)
        else:
          comma_seperated_list_of_sources += ",{0}".format(source.id)
  except Exception:
    comma_seperated_list_of_sources = ""

  celery.conf.beat_schedule = {
    'add-articles': {
      'task': 'app.tasks.add_articles.add_articles',
      'schedule': crontab(minute="*/5"),
      'args': (1, comma_seperated_list_of_sources)
    },
    'generate-sitemap': {
      'task': 'app.tasks.generate_sitemap.generate_sitemap',
      'schedule': crontab(minute="*/60"),
    }
  }
  celery.config_from_object(celeryconfig)

  TaskBase = celery.Task

  class ContextTask(TaskBase):
    abstract = True

    def __call__(self, *args, **kwargs):
      with app.app_context():
        return TaskBase.__call__(self, *args, **kwargs)

  celery.Task = ContextTask

  from app.main import bp as main_bp
  app.register_blueprint(main_bp)

  from app.errors import bp as errors_bp
  app.register_blueprint(errors_bp)

  thread = Thread(target=setup, args=(app, ))
  thread.start()

  return app

from app.models import Article, Source, Country, Cookie
