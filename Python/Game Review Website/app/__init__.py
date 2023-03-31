from redis import Redis
import rq
import logging
from logging.handlers import SMTPHandler, RotatingFileHandler
import os
from flask import Flask, request, current_app
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_mail import Mail
from flask_moment import Moment
from config import Config
from elasticsearch import Elasticsearch

db = SQLAlchemy()
migrate = Migrate()
login = LoginManager()
login.login_view = 'auth.login'
login.login_message = 'Please sign in to access this page.'
mail = Mail()
moment = Moment()

def create_app(config_class=Config):
  app = Flask(__name__)
  app.config.from_object(config_class)
  app.redis = Redis.from_url(app.config['REDIS_URL'])
  app.high_task_queue = rq.Queue('high', connection=app.redis)
  app.normal_task_queue = rq.Queue('normal', connection=app.redis)
  app.low_task_queue = rq.Queue('low', connection=app.redis)

  db.init_app(app)
  migrate.init_app(app, db)
  login.init_app(app)
  mail.init_app(app)
  moment.init_app(app)
  app.elasticsearch = Elasticsearch([app.config['ELASTICSEARCH_URL']]) \
    if app.config['ELASTICSEARCH_URL'] else None # 'http://localhost:9200'


  from app.main import bp as main_bp
  app.register_blueprint(main_bp)

  from app.errors import bp as errors_bp
  app.register_blueprint(errors_bp)

  from app.auth import bp as auth_bp
  app.register_blueprint(auth_bp)

  from app.user import bp as user_bp
  app.register_blueprint(user_bp, url_prefix='/user')

  from app.game import bp as game_bp
  app.register_blueprint(game_bp)

  if not app.debug and not app.testing:
    if app.config['MAIL_SERVER']:
      auth = None
      if app.config['MAIL_USERNAME'] or app.config['MAIL_PASSWORD']:
        auth = (app.config['MAIL_USERNAME'],
                app.config['MAIL_PASSWORD'])

      secure = None
      if app.config['MAIL_USE_TLS']:
        secure = ()

      mail_handler = SMTPHandler(
        mailhost=(app.config['MAIL_SERVER'], app.config['MAIL_PORT']),
        fromaddr='no-reply@' + app.config['MAIL_SERVER'],
        toaddrs=app.config['ADMINS'], subject='Gamereview Failure',
        credentials=auth, secure=secure)
      mail_handler.setLevel(logging.ERROR)
      app.logger.addHandler(mail_handler)

    if not os.path.exists('logs'):
      os.mkdir('logs')

    file_handler = RotatingFileHandler('logs/gamereview.log',
                                        maxBytes=10240, backupCount=10)
    file_handler.setFormatter(logging.Formatter(
      '%(asctime)s %(levelname)s: %(message)s '
      '[in %(pathname)s:%(lineno)d]'))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)

    app.logger.setLevel(logging.INFO)
    app.logger.info('Gamereview startup')

  return app


from app import models