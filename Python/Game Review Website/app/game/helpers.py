import feedparser
import urllib.request
from threading import Thread
from flask import request
from datetime import datetime
from app import db
from app.game import bp
from app.models import Game, Category, Developer, Platform, Publisher

# Threaded function snippet
def threaded(fn):
  """To use as decorator to make a function call threaded.
  Needs import
  from threading import Thread"""
  def wrapper(*args, **kwargs):
    thread = Thread(target=fn, args=args, kwargs=kwargs)
    thread.start()
    return thread
  return wrapper


def lookup(game):
  if game.game_type == "dlc":
    game = game.game
  
  game_id = game.steam_id

  if game_id in lookup.cache:
    return lookup.cache[game_id]
  
  # get feed from Steam
  feed = feedparser.parse("https://steamcommunity.com/games/{0}/rss/".format(game_id))

  # if no items in feed, get feed from Onion
  #if not feed["items"]:
  #  feed = feedparser.parse("http://www.theonion.com/feeds/rss")

  # cache results
  lookup.cache[game_id] = [{"link": item["link"], "title": item["title"], "description": item["description"].replace("https://steamcommunity.com/linkfilter/?url=", ""), "published": datetime.strptime(item["published"], "%a, %d %b %Y %H:%M:%S %z")} for item in feed["items"]]

  # return results
  return lookup.cache[game_id]

# initialize cache
lookup.cache = {}
