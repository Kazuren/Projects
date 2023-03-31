from flask import render_template, flash, redirect, url_for, current_app, g, request
from flask_login import login_required, current_user
from datetime import datetime
from app import db
from app.main import bp
from app.forms.game import SearchForm

@bp.before_app_request
def before_request():
  if current_user.is_authenticated:
    current_user.last_seen = datetime.utcnow()
    db.session.commit()
  g.search_form = SearchForm()
