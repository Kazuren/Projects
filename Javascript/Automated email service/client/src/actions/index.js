import {
  _login, _register, _fetch_email_data,
  _fetch_email_history, _fetch_email_tasks,
  _fetch_email_templates, _save_email_template,
  _delete_email_template, _load_email_template
} from '../api'

import {
  LOGIN_USER_SENT, LOGIN_USER_SUCCESS, LOGIN_USER_REJECTED,
  REGISTER_USER_SENT, REGISTER_USER_SUCCESS, REGISTER_USER_REJECTED,
  FETCH_EMAIL_DATA_SENT, FETCH_EMAIL_DATA_SUCCESS, FETCH_EMAIL_DATA_REJECTED,
  FETCH_EMAIL_HISTORY_SENT, FETCH_EMAIL_HISTORY_SUCCESS, FETCH_EMAIL_HISTORY_REJECTED,
  FETCH_EMAIL_TASKS_SENT, FETCH_EMAIL_TASKS_SUCCESS, FETCH_EMAIL_TASKS_REJECTED,
  FETCH_EMAIL_TEMPLATES_SENT, FETCH_EMAIL_TEMPLATES_SUCCESS, FETCH_EMAIL_TEMPLATES_REJECTED,
  SAVE_EMAIL_TEMPLATE_SENT, SAVE_EMAIL_TEMPLATE_SUCCESS, SAVE_EMAIL_TEMPLATE_REJECTED,
  DELETE_EMAIL_TEMPLATE_SENT, DELETE_EMAIL_TEMPLATE_SUCCESS, DELETE_EMAIL_TEMPLATE_REJECTED,
  LOAD_EMAIL_TEMPLATE_SENT, LOAD_EMAIL_TEMPLATE_SUCCESS, LOAD_EMAIL_TEMPLATE_REJECTED
} from './actionTypes'

export const login = (username, password) => async dispatch => {
  dispatch({ type: LOGIN_USER_SENT })
  try {
    const token = await _login(username, password)
    dispatch({ type: LOGIN_USER_SUCCESS, payload: token })
  } catch (err) {
    dispatch({ type: LOGIN_USER_REJECTED, payload: err })
  }
}

export const register = (username, password) => async dispatch => {
  dispatch({ type: REGISTER_USER_SENT })
  try {
    const token = await _register(username, password)
    dispatch({ type: REGISTER_USER_SUCCESS, payload: token })
  } catch (err) {
    dispatch({ type: REGISTER_USER_REJECTED, payload: err })
  }
}

export const fetch_email_data = (token, query, page, limit) => async dispatch => {
  dispatch({ type: FETCH_EMAIL_DATA_SENT })
  try {
    const data = await _fetch_email_data(token, query, page, limit)
    dispatch({ type: FETCH_EMAIL_DATA_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: FETCH_EMAIL_DATA_REJECTED, payload: err })
  }
}

export const fetch_email_history = (token) => async dispatch => {
  dispatch({ type: FETCH_EMAIL_HISTORY_SENT })
  try {
    const data = await _fetch_email_history(token)
    dispatch({ type: FETCH_EMAIL_HISTORY_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: FETCH_EMAIL_HISTORY_REJECTED, payload: err })
  }
}

export const fetch_email_tasks = (token) => async dispatch => {
  dispatch({ type: FETCH_EMAIL_TASKS_SENT })
  try {
    const data = await _fetch_email_tasks(token)
    dispatch({ type: FETCH_EMAIL_TASKS_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: FETCH_EMAIL_TASKS_REJECTED, payload: err })
  }
}

export const fetch_email_templates = (token) => async dispatch => {
  dispatch({ type: FETCH_EMAIL_TEMPLATES_SENT })
  try {
    const data = await _fetch_email_templates(token)
    dispatch({ type: FETCH_EMAIL_TEMPLATES_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: FETCH_EMAIL_TEMPLATES_REJECTED, payload: err })
  }
}

export const save_email_template = (token, name, subject, template_data) => async dispatch => {
  dispatch({ type: SAVE_EMAIL_TEMPLATE_SENT })
  try {
    const data = await _save_email_template(token, name, subject, template_data)
    dispatch({ type: SAVE_EMAIL_TEMPLATE_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: SAVE_EMAIL_TEMPLATE_REJECTED, payload: err })
  }
}

export const delete_email_template = (token, name) => async dispatch => {
  dispatch({ type: DELETE_EMAIL_TEMPLATE_SENT })
  try {
    const data = await _delete_email_template(token, name)
    dispatch({ type: DELETE_EMAIL_TEMPLATE_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: DELETE_EMAIL_TEMPLATE_REJECTED, payload: err })
  }
}

export const load_email_template = (token, name) => async dispatch => {
  dispatch({ type: LOAD_EMAIL_TEMPLATE_SENT })
  try {
    const data = await _load_email_template(token, name)
    dispatch({ type: LOAD_EMAIL_TEMPLATE_SUCCESS, payload: data })
  } catch (err) {
    dispatch({ type: LOAD_EMAIL_TEMPLATE_REJECTED, payload: err })
  }
}
