from datetime import datetime
from flask import current_app
from app import db

class Article(db.Model):
  id = db.Column(db.Integer, primary_key=True, index=True)
  body = db.Column(db.String(4096))
  title = db.Column(db.String(255))
  url = db.Column(db.String(255), unique=True)
  author = db.Column(db.String(255))
  timestamp = db.Column(db.DateTime, index=True)
  source_id = db.Column(db.String(64), db.ForeignKey('source.id'), index=True)

class Source(db.Model):
  id = db.Column(db.String(64), primary_key=True)
  name = db.Column(db.String(255))
  url = db.Column(db.String(255))
  description = db.Column(db.String(2048))
  category = db.Column(db.String(255))
  country_id = db.Column(db.Integer, db.ForeignKey('country.id'), index=True)
  articles = db.relationship('Article', backref='source', lazy='dynamic', cascade='save-update, merge, delete')
  cookies = db.relationship('Cookie', backref='source', lazy='dynamic', cascade='save-update, merge, delete')

  def to_dict(self):
    data = {
      'id': self.id,
      'name': self.name,
      'url': self.url,
      'description': self.description,
      'category': self.category,
      'country': self.country.name,
      'article_count': self.articles.count()
    }
    return data

class Country(db.Model):
  id = db.Column(db.Integer, primary_key=True, index=True)
  country_code = db.Column(db.String(4)) # 2 letter ISO Code 
  language_code = db.Column(db.String(4)) # 2 letter ISO Code 
  language = db.Column(db.String(64))
  name = db.Column(db.String(64))
  sources = db.relationship('Source', backref='country', lazy='dynamic', cascade='save-update, merge, delete')

class Cookie(db.Model):
  id = db.Column(db.Integer, primary_key=True, index=True)
  name = db.Column(db.String(255))
  value = db.Column(db.String(255))
  source_id = db.Column(db.String(64), db.ForeignKey('source.id'), index=True)
