import jwt
import redis
import rq
import json
from time import time, mktime
from hashlib import md5
from datetime import datetime, timedelta, timezone, date
from slugify import slugify
from flask import current_app
from flask_login import UserMixin
from sqlalchemy import and_
from werkzeug.security import generate_password_hash, check_password_hash
from sqlalchemy.ext.hybrid import hybrid_property
import sqlalchemy.types as types
from app import db, login
from app.search import add_to_index, remove_from_index, query_index

@login.user_loader
def load_user(id):
  return User.query.get(int(id))

class SearchableMixin(object):
  @classmethod
  def search(cls, expression, page, per_page):
    ids, total = query_index(cls.__tablename__, expression, page, per_page)
    if total == 0:
      return cls.query.filter_by(id=0), 0
    when = []
    for i in range(len(ids)):
      when.append((ids[i], i))
    return cls.query.filter(cls.id.in_(ids)).order_by(
      db.case(when, value=cls.id)), total

  @classmethod
  def before_commit(cls, session):
    session._changes = {
      'add': list(session.new),
      'update': list(session.dirty),
      'delete': list(session.deleted)
    }

  @classmethod
  def after_commit(cls, session):
    for obj in session._changes['add']:
      if isinstance(obj, SearchableMixin):
        add_to_index(obj.__tablename__, obj)
    for obj in session._changes['update']:
      if isinstance(obj, SearchableMixin):
        add_to_index(obj.__tablename__, obj)
    for obj in session._changes['delete']:
      if isinstance(obj, SearchableMixin):
        remove_from_index(obj.__tablename__, obj)
    session._changes = None

  @classmethod
  def reindex(cls):
    for obj in cls.query:
      add_to_index(cls.__tablename__, obj)

db.event.listen(db.session, 'before_commit', SearchableMixin.before_commit)
db.event.listen(db.session, 'after_commit', SearchableMixin.after_commit)


followers = db.Table('followers',
  db.Column('follower_id', db.Integer, db.ForeignKey('user.id')),
  db.Column('following_id', db.Integer, db.ForeignKey('user.id'))
)

class CategoryUpvote(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
  game_id = db.Column(db.Integer, db.ForeignKey('game.id'))

class Downvote(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  review_id = db.Column(db.Integer, db.ForeignKey('review.id'))

class Upvote(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  review_id = db.Column(db.Integer, db.ForeignKey('review.id'))

class User(UserMixin, db.Model):
  id = db.Column(db.Integer, primary_key=True)
  username = db.Column(db.String(32), index=True, unique=True)
  email = db.Column(db.String(120), index=True, unique=True)
  date = db.Column(db.DateTime, default=datetime.utcnow)
  password_hash = db.Column(db.String(128))
  reviews = db.relationship('Review', backref='author', lazy='dynamic', cascade="save-update, merge, delete")
  category_upvotes = db.relationship('CategoryUpvote', backref='user', lazy='dynamic', cascade="save-update, merge, delete")
  last_seen = db.Column(db.DateTime, default=datetime.utcnow)
  reputation = db.Column(db.Integer, default=0)
  tasks = db.relationship('Task', backref='user', lazy='dynamic')
  messages_sent = db.relationship('Message', foreign_keys='Message.sender_id', backref='author', lazy='dynamic')
  messages_received = db.relationship('Message', foreign_keys='Message.recipient_id', backref='recipient', lazy='dynamic')
  last_message_read_time = db.Column(db.DateTime)
  notifications = db.relationship('Notification', backref='user', lazy='dynamic')

  following = db.relationship(
    'User', secondary=followers,
    primaryjoin=(followers.c.follower_id == id),
    secondaryjoin=(followers.c.following_id == id),
    backref=db.backref('followers', lazy='dynamic'), lazy='dynamic'
  )

  def __repr__(self):
    return '{0}'.format(self.username)

  def set_password(self, password):
    self.password_hash = generate_password_hash(password)

  def check_password(self, password):
    return check_password_hash(self.password_hash, password)

  def new_messages(self):
    last_read_time = self.last_message_read_time or datetime(1900, 1 ,1)
    return Message.query.filter_by(recipient=self).filter(Message.timestamp > last_read_time).count()

  def follow(self, user):
    if not self.is_following(user):
      self.following.append(user)

  def unfollow(self, user):
    if self.is_following(user):
      self.following.remove(user)

  def is_following(self, user):
    return self.following.filter(followers.c.following_id == user.id).count() > 0

  def following_reviews(self):
    following = Review.query.join(
      followers, (followers.c.following_id == Review.user_id)).filter(
        followers.c.follower_id == self.id)
    # own = Review.query.filter_by(user_id=self.id)
    return following # .union(own)

  def add_notification(self, name, data):
    self.notifications.filter_by(name=name).delete()
    n = Notification(name=name, payload_json=json.dumps(data), user=self)
    db.session.add(n)
    return n

  def launch_task(self, priority, name, description, *args, **kwargs):
    if priority == 'high':
      rq_job = current_app.high_task_queue.enqueue('app.tasks.' + name, self.id, *args, **kwargs)
    elif priority == 'normal':
      rq_job = current_app.normal_task_queue.enqueue('app.tasks.' + name, self.id, *args, **kwargs)
    elif priority == 'low':
      rq_job = current_app.low_task_queue.enqueue('app.tasks.' + name, self.id, *args, **kwargs)
    else: # Go normal priority
      rq_job = current_app.normal_task_queue.enqueue('app.tasks.' + name, self.id, *args, **kwargs)
    
    task = Task(id=rq_job.get_id(), name=name, description=description, user=self)
    db.session.add(task)
    return task
  
  def get_tasks_in_progress(self):
    return Task.query.filter_by(user=self, complete=False).all()
  
  def get_task_in_progress(self, name):
    return Task.query.filter_by(name=name, user=self, complete=False).first()

  def get_reset_password_token(self, expires_in=600):
    return jwt.encode(
      {'reset_password': self.id, 'exp': time() + expires_in},
      current_app.config['SECRET_KEY'], algorithm='HS256').decode('utf-8')

  @staticmethod
  def verify_reset_password_token(token):
    try:
      id = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=['HS256'])['reset_password']
    except:
      return
    return User.query.get(id)

class Notification(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(128), index=True)
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  timestamp = db.Column(db.Float, index=True, default=time)
  payload_json = db.Column(db.Text)

  def get_data(self):
    return json.loads(str(self.payload_json))

class Task(db.Model):
  id = db.Column(db.String(36), primary_key=True)
  name = db.Column(db.String(128), index=True)
  description = db.Column(db.String(128))
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  complete = db.Column(db.Boolean, default=False)

  def get_rq_job(self):
    try:
      rq_job = rq.job.Job.fetch(self.id, connection=current_app.redis)
    except (redis.exceptions.RedisError, rq.exceptions.NoSuchJobError):
      return None
    return rq_job
  def get_progress(self):
    job = self.get_rq_job()
    return job.meta.get('progress', 0) if job is not None else 100

class Message(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  sender_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  recipient_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  body = db.Column(db.String(140))
  timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)

  def __repr__(self):
    return '<Message {0}>'.format(self.body)

class Revision(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  review_id =  db.Column(db.Integer, db.ForeignKey('review.id'))
  body = db.Column(db.String(1024))
  rating = db.Column(db.Integer)
  timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)

class Review(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  rating = db.Column(db.Integer, index=True)
  body = db.Column(db.String(1024))
  timestamp_in_seconds = db.Column(db.Float, index=True, default=time)
  timestamp = db.Column(db.DateTime, index=True, default=datetime.utcnow)
  original_timestamp = db.Column(db.DateTime, index=True)
  original_rating = db.Column(db.Integer)
  original_body = db.Column(db.String(1024))
  user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
  game_id = db.Column(db.Integer, db.ForeignKey('game.id'))
  revisions = db.relationship('Revision', backref='review', lazy='dynamic', cascade="save-update, merge, delete")
  upvotes = db.relationship('Upvote', backref='review', lazy='dynamic', cascade="save-update, merge, delete")
  downvotes = db.relationship('Downvote', backref='review', lazy='dynamic', cascade="save-update, merge, delete")
  score = db.Column(db.Integer, default=0)

  def __init__(self, *args, **kwargs):
    super(Review, self).__init__(*args, **kwargs)
    self.original_timestamp = self.timestamp
    self.original_rating = self.rating
    self.original_body = self.body

  def add_downvote(self, user):
    if user.reputation >= 25:
      if not self.is_downvoted(user):
        downvote = Downvote(review_id=self.id, user_id=user.id)
        db.session.add(downvote)
        self.author.reputation -= 1
        self.score -= 1
        if self.is_upvoted(user):
          upvote = self.upvotes.filter(Upvote.user_id == user.id).first()
          db.session.delete(upvote)
          self.author.reputation -= 1
          self.score -= 1
      else:
        downvote = self.downvotes.filter(Downvote.user_id == user.id).first()
        db.session.delete(downvote)
        self.author.reputation += 1
        self.score += 1
  
  def is_downvoted(self, user):
    return self.downvotes.filter(Downvote.user_id == user.id).count() > 0

  def add_upvote(self, user):
    if not self.is_upvoted(user):
      upvote = Upvote(review_id=self.id, user_id=user.id)
      db.session.add(upvote)
      self.author.reputation += 1
      self.score += 1

      if self.is_downvoted(user):
        downvote = self.downvotes.filter(Downvote.user_id == user.id).first()
        db.session.delete(downvote)
        self.author.reputation += 1
        self.score += 1

    else:
      upvote = self.upvotes.filter(Upvote.user_id == user.id).first()
      db.session.delete(upvote)
      self.author.reputation -= 1
      self.score -= 1

  def is_upvoted(self, user):
    return self.upvotes.filter(Upvote.user_id == user.id).count() > 0

class Category(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(32), index=True, unique=True)
  category_upvotes = db.relationship('CategoryUpvote', backref='category', lazy='dynamic', cascade="save-update, merge, delete")

  def __repr__(self):
    return '{0}'.format(self.name)

  def upvote_count(self, game):
    return CategoryUpvote.query \
      .filter(CategoryUpvote.game_id == game.id, CategoryUpvote.category_id == self.id) \
      .count()

developers = db.Table('developers',
  db.Column('developer_id', db.Integer, db.ForeignKey('developer.id'), primary_key=True),
  db.Column('game_id', db.Integer, db.ForeignKey('game.id'), primary_key=True)
)
publishers = db.Table('publishers',
  db.Column('publisher_id', db.Integer, db.ForeignKey('publisher.id'), primary_key=True),
  db.Column('game_id', db.Integer, db.ForeignKey('game.id'), primary_key=True)
)

platforms = db.Table('platforms',
  db.Column('platform_id', db.Integer, db.ForeignKey('platform.id'), primary_key=True),
  db.Column('game_id', db.Integer, db.ForeignKey('game.id'), primary_key=True)
)

class Platform(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(32), unique=True)

  def __repr__(self):
    return '{0}'.format(self.name)

class Developer(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(32), unique=True)

  def __repr__(self):
    return '{0}'.format(self.name)

class Publisher(db.Model):
  id = db.Column(db.Integer, primary_key=True)
  name = db.Column(db.String(32), unique=True)

  def __repr__(self):
    return '{0}'.format(self.name)

#class Image(db.Model):
#  id = db.Column(db.Integer, primary_key=True)
#  name = db.Column(db.String(64))
#  filepath = db.Column(db.String(264), unique=True) # absolute path to file
#  game_id = db.Column(db.Integer, db.ForeignKey('game.id'))

class Game(SearchableMixin, db.Model):
  __searchable__ = ['title']

  id = db.Column(db.Integer, primary_key=True)
  game_type = db.Column(db.String(255))
  steam_id = db.Column(db.Integer, nullable=True)
  steam_page = db.Column(db.String(255), nullable=True)
  header_image = db.Column(db.String(255), nullable=True)
  website = db.Column(db.String(255), nullable=True)
  title = db.Column(db.String(255), index=True, unique=True)
  release_date = db.Column(db.DateTime, index=True)
  slug = db.Column(db.String(255), index=True)
  reviews = db.relationship('Review', backref='game', lazy='dynamic', cascade="save-update, merge, delete")

  game_id = db.Column(db.Integer, db.ForeignKey('game.id'))
  dlc = db.relationship('Game', backref=db.backref('game', remote_side=[id]), uselist=True, lazy='dynamic', cascade="save-update, merge, delete")
  # images = db.relationship('Image', backref='game', lazy='dynamic', cascade="save-update, merge, delete")

  category_upvotes = db.relationship('CategoryUpvote', backref='game', lazy='dynamic', cascade="save-update, merge, delete")

  platforms = db.relationship(
    'Platform',
    secondary=platforms,
    lazy='dynamic',
    backref=db.backref('games', lazy=True)
  )

  developers = db.relationship(
    'Developer',
    secondary=developers,
    lazy='dynamic',
    backref=db.backref('games', lazy=True)
  )
  publishers = db.relationship(
    'Publisher',
    secondary=publishers,
    lazy='dynamic',
    backref=db.backref('games', lazy=True)
  )

  def __init__(self, *args, **kwargs):
    super(Game, self).__init__(*args, **kwargs)
    self.slug = slugify(self.title)

  def __repr__(self):
    return '{0}'.format(self.title)

  def add_upvote(self, category, user):
    if not self.is_upvoted(category, user):
      upvote = CategoryUpvote(category_id=category.id, game_id=self.id, user_id=user.id)
      db.session.add(upvote)
    else:
      upvote = self.category_upvotes.filter(CategoryUpvote.category_id == category.id, CategoryUpvote.user_id == user.id, CategoryUpvote.game_id == self.id).first()
      db.session.delete(upvote)

  def is_upvoted(self, category, user):
    return self.category_upvotes.filter(CategoryUpvote.category_id == category.id, CategoryUpvote.user_id == user.id, CategoryUpvote.game_id == self.id).count() > 0

  @hybrid_property
  def avg_rating(self):
    reviews = Review.query \
      .filter(Review.game_id == self.id).all()
    try:
      return round(sum(review.rating for review in reviews) / len(reviews), 1)
    except ZeroDivisionError:
      return 0

  @avg_rating.expression
  def avg_rating(cls):
    return db.select([db.func.avg(Review.rating)]).where(Review.game_id == cls.id).label('avg_rating')

  @hybrid_property
  def categories(self):
    return Category.query \
      .join(CategoryUpvote) \
      .filter(CategoryUpvote.game_id == self.id) \
      .group_by(Category.id) \
      .order_by(db.func.count(CategoryUpvote.game_id).desc()) \
      .limit(5) \

  @hybrid_property
  def activity(self):
    return db.select([db.func.avg(Review.timestamp_in_seconds)]) \
      .where(Review.game_id == self.id) \
      .order_by(Review.timestamp_in_seconds.desc()).limit(10) \
      .label('activity')

  @hybrid_property
  def related_games(self):
    games = Game.query.all()
    related_games = []
    for game in games:
      for category in game.categories:
        if category in self.categories:
          related_games.append(game)
          break

    return related_games

    #return Game.query \
    #  .filter(self.categories == Game.categories) \
    #  .all()

