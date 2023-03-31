from app import create_app, db
from app.models import Article, Source, Country, Cookie

app = create_app()

@app.shell_context_processor
def make_shell_context():
  return {'db': db, 'Article': Article, 'Source': Source, 'Country': Country, 'Cookie': Cookie}
