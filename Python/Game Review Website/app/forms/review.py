from datetime import datetime
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField, RadioField, SelectField
from wtforms.validators import ValidationError, DataRequired, Length
from app.forms.widgets import CustomRadioField

class DeleteReviewForm(FlaskForm):
  confirm = StringField('Type "DELETE" into the field to confirm', validators=[DataRequired()])
  submit = SubmitField('Delete')

class ReviewForm(FlaskForm):
  content = TextAreaField('Leave a review', validators=[Length(min=1, max=3000)])
  rating = SelectField('Leave a rating', validators=[DataRequired()], 
    choices=[
      ('', '---'),
      ('1', '1'),
      ('2', '2'),
      ('3', '3'),
      ('4', '4'),
      ('5', '5')
    ],
    default='---'
  )
  submit = SubmitField('Submit')

  def validate_rating(self, rating):
    rating.data = int(rating.data)
    if rating.data < 1 or rating.data > 5:
      raise ValidationError('Rating must be between 1 and 5')
    if rating.data % 1 != 0:
      raise ValidationError('Rating must be an integer')

class FilterReviewForm(FlaskForm):
  sort_by = CustomRadioField('Sort by',
    choices=[
      ('active', 'Active'),
      ('top', 'Top'),
      ('positive', 'Positive'),
      ('negative', 'Negative'),
      ('reputation', 'User Reputation'),
    ], 
    default='active'
  )
  date = CustomRadioField('Date written',
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
  submit_review_filter = SubmitField('Submit')
