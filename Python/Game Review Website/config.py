import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'), override=True)


class Config(object):
  SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
  SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    'sqlite:///' + os.path.join(basedir, 'app.db')
  SQLALCHEMY_TRACK_MODIFICATIONS = False

  MAIL_SERVER = os.environ.get('MAIL_SERVER')
  MAIL_PORT = int(os.environ.get('MAIL_PORT') or 25)
  MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS') is not None
  MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
  MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
  ADMINS = ['email.flask@gmail.com, alexandrosgramma@gmail.com, jedimind2000@hotmail.com']

  RECAPTCHA_USE_SSL = False
  RECAPTCHA_PUBLIC_KEY = os.environ.get('RECAPTCHA_PUBLIC_KEY') or None
  RECAPTCHA_PRIVATE_KEY = os.environ.get('RECAPTCHA_PRIVATE_KEY') or None
  RECAPTCHA_DATA_ATTRS = {'theme': 'white'}

  ELASTICSEARCH_URL = os.environ.get('ELASTICSEARCH_URL') or None # 'http://localhost:9200'
  REDIS_URL = os.environ.get('REDIS_URL') or 'redis://'

  UPLOAD_FOLDER = 'app/static/images'
  ALLOWED_EXTENSIONS = set(['png', 'jpg', 'jpeg'])
  GAMES_PER_PAGE = 60
  REVIEWS_PER_PAGE = 20
  MESSAGES_PER_PAGE = 20
  