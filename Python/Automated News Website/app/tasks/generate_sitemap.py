import xml.etree.cElementTree as ET
from lxml import etree
import datetime
import sys
from xml.dom import minidom
from xml.dom.minidom import parse

from app import celery, create_app, db
from app.models import Article, Source
from flask import current_app

@celery.task()
def generate_sitemap():
  articles = get_articles()
  sources = get_sources()
  extras = get_extras()
  created = create_sitemap_index(articles, sources, extras)

def create_sitemap_index(articles, sources, extras):
  try:
    root = ET.Element('sitemapindex')
    root.attrib['xmlns']="http://www.sitemaps.org/schemas/sitemap/0.9"

    dt = datetime.datetime.now().strftime("%Y-%m-%d")
    for i, articles in enumerate(chunks(articles, 5000)):
      doc = ET.SubElement(root, "sitemap")
      ET.SubElement(doc, "loc").text = "https://tldrfeed.com/sitemap_articles_{0}.xml".format(i) #.gz
      ET.SubElement(doc, "lastmod").text = dt
      article_sitemap = create_article_sitemap(articles, i)
      

    doc = ET.SubElement(root, "sitemap")
    ET.SubElement(doc, "loc").text = "https://tldrfeed.com/sitemap_sources.xml" #.gz
    ET.SubElement(doc, "lastmod").text = dt
    sources_sitemap = create_source_sitemap(sources)

    doc = ET.SubElement(root, "sitemap")
    ET.SubElement(doc, "loc").text = "https://tldrfeed.com/sitemap_extras.xml" #.gz
    ET.SubElement(doc, "lastmod").text = dt
    extras_sitemap = create_extras_sitemap(extras)

    tree = ET.ElementTree(root)
    tree.write('./app/static/sitemap_index.xml', encoding='utf-8', xml_declaration=True)

    return True

  except Exception as e:
    print(e)
    return False

def create_article_sitemap(articles, index):
  try:
    root = ET.Element('urlset')
    root.attrib['xmlns:xsi']="http://www.w3.org/2001/XMLSchema-instance"
    root.attrib['xsi:schemaLocation']="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    root.attrib['xmlns']="http://www.sitemaps.org/schemas/sitemap/0.9"

    dt = datetime.datetime.now().strftime("%Y-%m-%d")
    for article in articles:
      doc = ET.SubElement(root, "url")
      ET.SubElement(doc, "loc").text = article
      ET.SubElement(doc, "lastmod").text = dt
      ET.SubElement(doc, "changefreq").text = "never"
      ET.SubElement(doc, "priority").text = "0.8"

    tree = ET.ElementTree(root)
    tree.write('./app/static/sitemap_articles_{0}.xml'.format(index), encoding='utf-8', xml_declaration=True)

    return True

  except Exception as e:
    print(e)
    return False

def create_source_sitemap(sources):
  try:
    root = ET.Element('urlset')
    root.attrib['xmlns:xsi']="http://www.w3.org/2001/XMLSchema-instance"
    root.attrib['xsi:schemaLocation']="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    root.attrib['xmlns']="http://www.sitemaps.org/schemas/sitemap/0.9"

    dt = datetime.datetime.now().strftime("%Y-%m-%d")
    for source in sources:
      doc = ET.SubElement(root, "url")
      ET.SubElement(doc, "loc").text = source
      ET.SubElement(doc, "lastmod").text = dt
      ET.SubElement(doc, "changefreq").text = "never"
      ET.SubElement(doc, "priority").text = "0.6"

    tree = ET.ElementTree(root)
    tree.write('./app/static/sitemap_sources.xml', encoding='utf-8', xml_declaration=True)

    return True

  except Exception as e:
    print(e)
    return False

def create_extras_sitemap(extras):
  try:
    root = ET.Element('urlset')
    root.attrib['xmlns:xsi']="http://www.w3.org/2001/XMLSchema-instance"
    root.attrib['xsi:schemaLocation']="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    root.attrib['xmlns']="http://www.sitemaps.org/schemas/sitemap/0.9"

    dt = datetime.datetime.now().strftime("%Y-%m-%d")

    doc = ET.SubElement(root, "url")
    ET.SubElement(doc, "loc").text = "https://tldrfeed.com/"
    ET.SubElement(doc, "lastmod").text = dt
    ET.SubElement(doc, "changefreq").text = "hourly"
    ET.SubElement(doc, "priority").text = "1.0"

    for extra in extras:
      doc = ET.SubElement(root, "url")
      ET.SubElement(doc, "loc").text = extra
      ET.SubElement(doc, "lastmod").text = dt
      ET.SubElement(doc, "changefreq").text = "never"
      ET.SubElement(doc, "priority").text = "0.5"

    tree = ET.ElementTree(root)

    tree.write('./app/static/sitemap_extras.xml', encoding='utf-8', xml_declaration=True)

  except Exception as e:
    print(e)
    return False


def get_articles():
  articles = []
  for article_id in Article.query.with_entities(Article.id).yield_per(500).all():
    articles.append('https://tldrfeed.com/articles/{0}/'.format(article_id[0]))

  return articles

def get_sources():
  sources = []
  for source in Source.query.all():
    sources.append('https://tldrfeed.com/sources/{0}/'.format(source.id))

  return sources

def get_extras():
  extras = [
    'https://tldrfeed.com/contact/',
    'https://tldrfeed.com/about/',
    'https://tldrfeed.com/privacy/',
    'https://tldrfeed.com/terms/'
  ]
  return extras

def chunks(l, n):
  """Yield successive n-sized chunks from l."""
  for i in range(0, len(l), n):
    yield l[i:i + n]
