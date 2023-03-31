from flask_wtf import FlaskForm
from sqlalchemy import func
from wtforms import StringField, TextAreaField, SubmitField
from wtforms.validators import ValidationError, DataRequired, Length
from app.models import User

class EditProfileForm(FlaskForm):
  username = StringField('Customize capitalization for your username', validators=[DataRequired(), Length(min=2, max=16)])
  submit = SubmitField('Submit')

  def __init__(self, original_username, *args, **kwargs):
    super(EditProfileForm, self).__init__(*args, **kwargs)
    self.original_username = original_username

  def validate_username(self, username):
    if username.data.lower() != self.original_username.lower():
      #user = User.query.filter(func.lower(User.username) == func.lower(self.username.data)).first()
      #if user is not None:
      raise ValidationError('*You may not change your display name, only the capitalization of it')

class MessageForm(FlaskForm):
  message = TextAreaField('Message', validators=[DataRequired(), Length(min=0, max=140)])
  submit = SubmitField('Submit')
