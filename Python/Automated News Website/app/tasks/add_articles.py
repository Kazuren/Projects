from __future__ import absolute_import
from __future__ import division, print_function, unicode_literals
from sumy.parsers.html import HtmlParser
from sumy.parsers.plaintext import PlaintextParser
from sumy.nlp.tokenizers import Tokenizer
from sumy.summarizers.lsa import LsaSummarizer as Summarizer
from sumy.nlp.stemmers import Stemmer
from sumy.utils import get_stop_words

import dateutil.parser
import requests
from app import celery, create_app, db
from app.models import Article, Source, Country, Cookie
from flask import current_app
from fake_useragent import UserAgent
from newsplease import NewsPlease
from sqlalchemy import exc

ua = UserAgent()

@celery.task()
def add_articles(page, sources):
  articles = fetch_articles(sources, page)
  for article in articles:
    source = valid_article(article)
    if not source:
      continue

    url = article['url']
    found_article = Article.query.filter_by(url=url).first()
    if found_article:
      continue
    
    html = request_article(source, url)
    if not html:
      continue

    scraped_article = NewsPlease.from_html(html)

    summary = summarize_article(source, scraped_article.text)
    if not summary:
      continue

    if scraped_article.authors:
      author = scraped_article.authors[0]
    else:
      author = article['author'] if (article['author'] != '' and article['author'] is not None) else article["source"]["name"]
    
    article = Article(
      body=summary,
      title=article['title'],
      url=url,
      author=author, 
      source=source,
      timestamp=dateutil.parser.parse(article["publishedAt"])
    )
    add_article(article)

def valid_article(article):
  if article['source']['id'] is None: # if id is none
    return False
  else:
    source = Source.query.filter_by(id=article['source']['id']).first()
    if not source:
      return False
    return source

def request_article(source, url):
  cookies = {cookie.name:cookie.value for cookie in source.cookies.all()}
  headers = {'User-Agent': str(ua.chrome)}

  try:
    r = requests.get(url, cookies=cookies, headers=headers)
  except (
    requests.exceptions.TooManyRedirects, requests.exceptions.ConnectionError, 
    requests.exceptions.HTTPError, requests.exceptions.Timeout, 
    requests.exceptions.ReadTimeout, requests.exceptions.URLRequired
  ) as e:
    return False

  return r.text

def summarize_article(source, text):
  country = source.country
  language = country.language.lower()
  parser = PlaintextParser.from_string(text, Tokenizer(language))
  stemmer = Stemmer(language)
  summarizer = Summarizer(stemmer)
  summarizer.stop_words = get_stop_words(language)

  sentences = []
  for sentence in summarizer(parser.document, 7):
    sentences.append(sentence._text)

  if len(sentences) < 7:
    return False

  summary = '<br>'.join(sentences)
  return summary

def fetch_articles(sources, page):
  payload = {'sources': sources, 'pageSize': 100, 'page': page, 'language': 'en', 'apiKey': current_app.config['NEWS_API_KEY']}
  try:
    r = requests.get('https://newsapi.org/v2/everything', params=payload)
  except (
    requests.exceptions.TooManyRedirects, requests.exceptions.ConnectionError, 
    requests.exceptions.HTTPError, requests.exceptions.Timeout, 
    requests.exceptions.ReadTimeout, requests.exceptions.URLRequired
  ) as e:
    return []
  data = r.json()
  if data['status'] == "error":
    return []

  articles = data['articles']
  return articles

def add_article(article):
  try:
    db.session.add(article)
    db.session.commit()
  except (exc.IntegrityError, exc.DataError, exc.InternalError) as e:
    db.session.rollback()
