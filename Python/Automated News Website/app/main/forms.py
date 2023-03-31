from datetime import datetime
from flask_wtf import FlaskForm
from flask import request, current_app
from wtforms import SubmitField
from wtforms.validators import ValidationError, DataRequired
from wtforms.ext.sqlalchemy.fields import QuerySelectField
from app.models import Source
from app.main.widgets import MultiCheckboxField, CustomRadioField

class FilterForm(FlaskForm):
  sources = MultiCheckboxField(coerce=str)
  categories = MultiCheckboxField(coerce=str,
    choices=[
      ('all', 'All'),
      ('general', 'General'),
      ('technology', 'Technology'),
      ('business', 'Business'),
      ('sports', 'Sports'),
      ('entertainment', 'Entertainment'),
      ('science', 'Science')
    ]
  )
  publication_date = CustomRadioField('Publication Date',
    coerce=int,
    choices=[
      (7, 'Past week'), 
      (30, 'Past month'), 
      (365, 'Past year'), 
      ((datetime.utcnow().year * 365) - (1970 * 365), 'All')
    ], 
    default=7
  )

  def __init__(self, *args, **kwargs):
    if 'formdata' not in kwargs:
      kwargs['formdata'] = request.args
    if 'csrf_enabled' not in kwargs:
      kwargs['csrf_enabled'] = False

    super(FilterForm, self).__init__(*args, **kwargs)
    self.sources.choices = [(source.id, source.name) for source in Source.query.order_by(Source.name).all()]
