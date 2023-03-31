import requests
from datetime import datetime
from dateutil import parser
from bs4 import BeautifulSoup
from flask_wtf import FlaskForm
from flask import request, current_app
from slugify import slugify
from wtforms import StringField, SubmitField, BooleanField, RadioField
from wtforms.validators import ValidationError, DataRequired
from app.models import Game
from app.forms.widgets import MultiCheckboxField, CustomRadioField

class SearchForm(FlaskForm):
  q = StringField('Search')

  def __init__(self, *args, **kwargs):
    if 'formdata' not in kwargs:
      kwargs['formdata'] = request.args
    if 'csrf_enabled' not in kwargs:
      kwargs['csrf_enabled'] = False
    super(SearchForm, self).__init__(*args, **kwargs)

class AddGameForm(FlaskForm):
  url = StringField('Add a game from steam', validators=[DataRequired()])
  submit = SubmitField('Submit')

class FilterForm(FlaskForm):
  categories = MultiCheckboxField(coerce=int)
  developers = MultiCheckboxField(coerce=int)
  platforms = MultiCheckboxField(coerce=int)
  sort_by = CustomRadioField('Sort by',
    choices=[
      ('active', 'Active'),
      ('top', 'Top'),
    ], 
    default='active'
  )
  release_date = CustomRadioField('Release Date',
    coerce=int,
    choices=[
      (1, 'Past day'), 
      (7, 'Past week'), 
      (30, 'Past month'), 
      (365, 'Past year'), 
      ((datetime.utcnow().year * 365) - (1970 * 365), 'All')
    ], 
    default=(datetime.utcnow().year * 365) - (1970 * 365)
  )

  filter_by_or = BooleanField('or')
  submit = SubmitField('Submit')
