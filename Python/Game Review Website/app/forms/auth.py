from flask_wtf import FlaskForm, RecaptchaField
from sqlalchemy import func
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import ValidationError, DataRequired, EqualTo, Length, Email, Regexp
from app.models import User

class LoginForm(FlaskForm):
  username = StringField('Username', validators=[DataRequired(), Length(min=3, max=32)])
  password = PasswordField('Password', validators=[DataRequired(), Length(min=6, max=64)])
  submit = SubmitField('Login')
  recaptcha = RecaptchaField('Recaptcha')

class RegistrationForm(FlaskForm):
  username = StringField('Username', validators=[DataRequired(), Regexp(r'^[\w.@+-]+$', message="Username can only contain alphanumeric characters and '.', '@', '+', '-'")])
  email = StringField('Email', validators=[DataRequired(), Email()])
  password = PasswordField('Password', validators=[DataRequired()])
  password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')])
  submit = SubmitField('Register')
  recaptcha = RecaptchaField('Recaptcha')

  def validate_username(self, username):
    user = User.query.filter(func.lower(User.username) == func.lower(username.data)).first()
    if user is not None:
      raise ValidationError('Please use a different username.')

  def validate_email(self, email):
    user = User.query.filter(func.lower(User.email) == func.lower(email.data)).first()
    if user is not None:
      raise ValidationError('Please use a different email address.')

class ResetPasswordRequestForm(FlaskForm):
  email = StringField('Email', validators=[DataRequired(), Email()])
  submit = SubmitField('Request Password Reset')

class ResetPasswordForm(FlaskForm):
  password = PasswordField('Password', validators=[DataRequired()])
  password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')])
  submit = SubmitField('Request Password Reset')
