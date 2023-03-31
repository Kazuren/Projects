from flask import render_template
from app import db, create_app
from app.game import bp
from app.models import Task, User, Review, Game, Category, Developer, Platform, Publisher
from app.email import send_email
from rq import get_current_job
from dateutil import parser
import requests
import time
import json
import sys

app = create_app()
app.app_context().push()

def example(seconds):
  job = get_current_job()
  print('Starting task')
  for i in range(seconds):
    job.meta['progress'] = 100.0 * i / seconds
    job.save_meta()
    print(i)
    time.sleep(1)
  job.meta['progress'] = 100
  job.save_meta()
  print('Task completed')


def _set_task_progress(progress):
  job = get_current_job()
  if job:
    job.meta['progress'] = progress
    job.save_meta()
    task = Task.query.get(job.get_id())
    task.user.add_notification('task_progress', {'task_id': job.get_id(), 'progress': progress, 'complete': task.complete})

    if progress >= 100:
      task.complete = True

    db.session.commit()

def export_reviews(user_id):
  try:
    # read user reviews from database
    user = User.query.get(user_id)
    _set_task_progress(0)
    data = []
    i = 0
    total_reviews = user.reviews.count()
    for review in user.reviews.order_by(Review.original_timestamp.asc()):
      data.append({'body': review.body, 'timestamp': review.timestamp.isoformat() + 'Z'})
      i += 1
      _set_task_progress(100 * i // total_reviews)

    # send email with data to user
    send_email('[Blapblap] Your reviews',
      sender=app.config['ADMINS'][0], recipients=[user.email],
      text_body=render_template('email/export_reviews.txt', user=user),
      html_body=render_template('email/export_reviews.html', user=user),
      attachments=[('reviews.json', 'application/json', json.dumps({'reviews': data}, indent=4))],
      sync=True
    )

  except:
    # handle unexpected errors
    _set_task_progress(100)
    app.logger.error('Unhandled exception', exc_info=sys.exc_info())

def add_steam_game(user_id, domain):
  _set_task_progress(0)

  domain_data = domain.split('/')
  game_id = domain_data[2]
  game_slug = domain_data[3]

  domain = "https://store.steampowered.com/api/appdetails?appids={0}".format(game_id)
  
  response = requests.get(domain).json() 

  if response[game_id]['success']:
    data = response[game_id]['data']
    if data['type'] == "game":
      steam_id = data['steam_appid']
      steam_page = "https://store.steampowered.com/app/{0}/{1}".format(steam_id, game_slug)
      title = data['name']

      game = Game.query.filter_by(title=title).first()
      if game is not None:
        return

      if 'release_date' in data and data['release_date']['date'] != "":
        release_date = parser.parse(data['release_date']['date'])
      else:
        return # do stuff

      if 'website' in data:
        website = data['website']
      else:
        website = None

      if 'header_image' in data:
        header_image = data['header_image']
      else:
        header_image = None


      game = Game(title=title, release_date=release_date, steam_id=steam_id, steam_page=steam_page, header_image=header_image, website=website, game_type="game")

      if 'developers' in data:
        for developer in data['developers']:
          dev = Developer.query.filter_by(name=developer).first()
          if not dev:
            developer = Developer(name=developer)
            db.session.add(developer)
          game.developers.append(developer)

      if 'publishers' in data:
        for publisher in data['publishers']:
          pub = Publisher.query.filter_by(name=publisher).first()
          if not pub:
            publisher = Publisher(name=publisher)
            db.session.add(publisher)
          game.publishers.append(publisher)
        
      if 'genres' in data:
        for genre in data['genres']:
          category = Category.query.filter_by(name=genre['description']).first()
          if not category:
            category = Category(name=genre['description'])
            db.session.add(category)
      
      if 'platforms' in data:
        for key in data['platforms']:
          if data['platforms'][key]:
            key = key.capitalize()
            platform = Platform.query.filter_by(name=key).first()
            if not platform:
              platform = Platform(name=key)
              db.session.add(platform)
            game.platforms.append(platform)
      
      if 'dlc' in data:
        for dlc in data['dlc']:
          dlc = str(dlc)
          domain = "https://store.steampowered.com/api/appdetails?appids={0}".format(dlc)
          response = requests.get(domain).json()
          if response[dlc]['success']:
            data = response[dlc]['data']
            if data['type'] == "dlc":
              steam_id = data['steam_appid']
              title = data['name']

              dlc = Game.query.filter_by(title=title).first()
              if dlc is not None:
                continue

              if 'release_date' in data and data['release_date']['date'] != "":
                release_date = parser.parse(data['release_date']['date'])
              else:
                continue # do stuff

              if 'header_image' in data:
                header_image = data['header_image']
              else:
                header_image = None

              dlc = Game(game=game, title=title, release_date=release_date, steam_id=steam_id, header_image=header_image, game_type="dlc")

      db.session.commit()
    
  _set_task_progress(100)
