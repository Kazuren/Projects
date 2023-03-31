import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'), override=True)


class Config(object):
  SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess-bitch'
  SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    'sqlite:///' + os.path.join(basedir, 'app.db')
  SQLALCHEMY_TRACK_MODIFICATIONS = False

  NEWS_API_KEY = os.environ.get('NEWS_API_KEY') or ''

  ARTICLES_PER_PAGE = 10

  MINUTES_PER_TRIGGER = 5
  MISFIRE_GRACE_TIME = 600 # in seconds
  MAX_INSTANCES = 1

  REDIS_HOST = "0.0.0.0"
  REDIS_PORT = 6379
  CELERY_BROKER_URL = os.environ.get('REDIS_URL', "redis://{host}:{port}/0".format(
    host=REDIS_HOST, port=str(REDIS_PORT)))
  CELERY_RESULT_BACKEND = CELERY_BROKER_URL
