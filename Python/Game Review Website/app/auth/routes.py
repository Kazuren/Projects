from flask import render_template, redirect, url_for, flash, request
from flask_login import current_user, login_user, logout_user
from sqlalchemy import func
from werkzeug.urls import url_parse
from app import db
from app.auth import bp
from app.forms.auth import LoginForm, RegistrationForm, ResetPasswordRequestForm, ResetPasswordForm
from app.auth.email import send_password_reset_email
from app.models import User


@bp.route('/login', methods=['GET', 'POST'])
@bp.route('/login/', methods=['GET', 'POST'])
def login():
  if current_user.is_authenticated:
    return redirect(url_for('game.games'))

  form = LoginForm()
  if form.validate_on_submit():
    user = User.query.filter(func.lower(User.username) == func.lower(form.username.data)).first()
    if user is None or not user.check_password(form.password.data):
      flash('Invalid username or password')
      return redirect(url_for('.login'))
    login_user(user, remember=True)
    next_page = request.args.get('next')
    if not next_page or url_parse(next_page).netloc != '':
      next_page = url_for('game.games')
    return redirect(url_for('game.games'))

  return render_template('auth/login.html', title='Sign in', form=form)

@bp.route('/logout')
@bp.route('/logout/')
def logout():
  logout_user()
  return redirect(url_for('game.games'))

@bp.route('/register', methods=['GET', 'POST'])
@bp.route('/register/', methods=['GET', 'POST'])
def register():
  if current_user.is_authenticated:
    return redirect(url_for('game.games'))
  form = RegistrationForm()
  if form.validate_on_submit():
    user = User(username=form.username.data, email=form.email.data)
    user.set_password(form.password.data)
    db.session.add(user)
    db.session.commit()
    flash('Congratulations, you are now a registered user!')
    login_user(user, remember=True)
    return redirect(url_for('game.games'))
  return render_template('auth/register.html', title='Register', form=form)

@bp.route('/reset_password_request', methods=['GET', 'POST'])
@bp.route('/reset_password_request/', methods=['GET', 'POST'])
def reset_password_request():
  if current_user.is_authenticated:
    return redirect(url_for('game.games'))

  form = ResetPasswordRequestForm()
  if form.validate_on_submit():
    user = User.query.filter_by(email=form.email.data).first()
    if user:
      send_password_reset_email(user)
    flash('Check your email for the instructions to reset your password')
    return redirect(url_for('.login'))

  return render_template('auth/reset_password_request.html', title='Reset Password', form=form)

@bp.route('/reset_password/<token>', methods=['GET', 'POST'])
@bp.route('/reset_password/<token>/', methods=['GET', 'POST'])
def reset_password(token):
  if current_user.is_authenticated:
    return redirect(url_for('game.games'))
  user = User.verify_reset_password_token(token)
  if not user:
    return redirect(url_for('game.games'))
  form = ResetPasswordForm()
  if form.validate_on_submit():
    user.set_password(form.password.data)
    db.session.commit()
    flash('Your password has been reset.')
    return redirect(url_for('.login'))
  return render_template('auth/reset_password.html', form=form)

@bp.route('/privacy-policy')
@bp.route('/privacy-policy/')
def privacy():
  return render_template('auth/privacy_policy.html')

@bp.route('/terms-and-conditions')
@bp.route('/terms-and-conditions/')
def terms():
  return render_template('auth/terms_and_conditions.html')
