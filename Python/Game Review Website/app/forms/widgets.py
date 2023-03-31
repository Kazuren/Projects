from flask_wtf import FlaskForm
from flask import request
from wtforms import SelectMultipleField, SelectField, RadioField, widgets
from wtforms.widgets.core import HTMLString, html_params

class CheckboxList(object):
  def __call__(self, field, **kwargs):
    kwargs.setdefault('type', 'checkbox')
    field_id = kwargs.pop('id', field.id)
    parent_class = kwargs.pop('parent_class', '')
    html = [u'<div %s">' % html_params(id=field_id, class_=parent_class)]
    for value, label, checked in field.iter_choices():
      choice_id = u'%s-%s' % (field_id, value)
      options = dict(kwargs, name=field.name, value=value, id=choice_id)
      if checked:
        options['checked'] = 'checked'
      html.append(u'<div><input %s class="custom-control-input"/> ' % html_params(**options))
      html.append(u'<label for="%s-%s" class="custom-control-label">%s</label></div>' % (field_id, value, label))
    html.append(u'</div>')
    return  HTMLString(u''.join(html))

class RadioList(object):
  def __call__(self, field, **kwargs):
    kwargs.setdefault('type', 'radio')
    field_id = kwargs.pop('id', field.id)
    html = [u'<div %s class="custom-control custom-radio">' % html_params(id=field_id)]
    for value, label, checked in field.iter_choices():
      choice_id = u'%s-%s' % (field_id, value)
      options = dict(kwargs, name=field.name, value=value, id=choice_id)
      if checked:
        options['checked'] = 'checked'
      html.append(u'<div><input %s class="custom-control-input"/> ' % html_params(**options))
      html.append(u'<label for="%s-%s" class="custom-control-label">%s</label></div>' % (field_id, value, label))
    html.append(u'</div>')
    return  HTMLString(u''.join(html))

class CustomRadioField(SelectField):
  """
  A select field, except displays a list of custom radio buttons.
  """
  widget = RadioList()

class MultiCheckboxField(SelectMultipleField):
  """
  A multiple-select, except displays a list of checkboxes.

  Iterating the field will produce subfields, allowing custom rendering of
  the enclosed checkbox fields.
  """
  widget = CheckboxList()