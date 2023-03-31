import { getBot, createBot, _updateBot, 
  _joinChannel, _partChannel, getUser,
  _fetchCommands, _createCommand, _deleteCommands, _editCommand,
  _fetchTimers, _createTimer, _deleteTimers, _editTimer,
  _fetchFilters, _editFilter
} from '../api'
import {
  UPDATE_USER, UPDATE_TOKEN, UPDATE_BOT, DELETE_USER, DELETE_TOKEN, DELETE_BOT,
  UPDATE_BOT_SENT, UPDATE_BOT_SUCCESS, UPDATE_BOT_REJECTED,
  FETCH_USER_SENT, FETCH_USER_SUCCESS, FETCH_USER_REJECTED,
  FETCH_BOT_SENT, FETCH_BOT_SUCCESS, FETCH_BOT_REJECTED,
  CREATE_BOT_SENT, CREATE_BOT_SUCCESS, CREATE_BOT_REJECTED,
  JOIN_CHANNEL_SENT, JOIN_CHANNEL_SUCCESS, JOIN_CHANNEL_REJECTED,
  PART_CHANNEL_SENT, PART_CHANNEL_SUCCESS, PART_CHANNEL_REJECTED, 
  FETCH_COMMANDS_SENT, FETCH_COMMANDS_SUCCESS, FETCH_COMMANDS_REJECTED, 
  CREATE_COMMAND_SENT, CREATE_COMMAND_SUCCESS, CREATE_COMMAND_REJECTED, 
  DELETE_COMMANDS_SENT, DELETE_COMMANDS_SUCCESS, DELETE_COMMANDS_REJECTED, 
  EDIT_COMMAND_SENT, EDIT_COMMAND_SUCCESS, EDIT_COMMAND_REJECTED, 
  FETCH_TIMERS_SENT, FETCH_TIMERS_SUCCESS, FETCH_TIMERS_REJECTED, 
  CREATE_TIMER_SENT, CREATE_TIMER_SUCCESS, CREATE_TIMER_REJECTED, 
  DELETE_TIMERS_SENT, DELETE_TIMERS_REJECTED, DELETE_TIMERS_SUCCESS, 
  EDIT_TIMER_SENT, EDIT_TIMER_SUCCESS, EDIT_TIMER_REJECTED,
  FETCH_FILTERS_SENT, FETCH_FILTERS_SUCCESS, FETCH_FILTERS_REJECTED,
  EDIT_FILTER_SENT, EDIT_FILTER_SUCCESS, EDIT_FILTER_REJECTED
} from './actionTypes'

// action creators

export const updateUser = update => ({
  type: UPDATE_USER,
  payload: update,
})

export const updateToken = update => ({
  type: UPDATE_TOKEN,
  payload: update,
})

export const updateBotSync = update => ({
  type: UPDATE_BOT,
  payload: update,
})


export const deleteUser = () => ({
  type: DELETE_USER
})
export const deleteToken = () => ({
  type: DELETE_TOKEN
})
export const deleteBot = () => ({
  type: DELETE_BOT
})

// async action creators

export const joinChannel = token => async dispatch => {
  dispatch({type: JOIN_CHANNEL_SENT})
  try {
    const bot = await _joinChannel(token)
    dispatch({type: JOIN_CHANNEL_SUCCESS, payload: bot})
    return true
  } catch (err) {
    dispatch({type: JOIN_CHANNEL_REJECTED, payload: err.message})
    return false
  }
}

export const partChannel = token => async dispatch => {
  dispatch({type: PART_CHANNEL_SENT})
  try {
    const bot = await _partChannel(token)
    dispatch({type: PART_CHANNEL_SUCCESS, payload: bot})
    return true
  } catch (err) {
    dispatch({type: PART_CHANNEL_REJECTED, payload: err.message})
    return false
  }
}


export const updateBot = (token, update) => async dispatch => {
  dispatch({type: UPDATE_BOT_SENT})
  try {
    const bot = await _updateBot(token, update)
    dispatch({type: UPDATE_BOT_SUCCESS, payload: bot})
    return true
  } catch (err) {
    dispatch({type: UPDATE_BOT_REJECTED, payload: err.message})
    return false
  }
}


export const fetchUser = token => async dispatch => {
  dispatch({type: FETCH_USER_SENT})
  try {
    const user = await getUser(token) 
    dispatch({type: FETCH_USER_SUCCESS, payload: user})
    return true
  } catch (err) {
    dispatch({type: FETCH_USER_REJECTED, payload: err.message})
    return false
  }
}

export const fetchBot = token => async dispatch => {
  dispatch({type: FETCH_BOT_SENT})
  try {
    const bot = await getBot(token)
    dispatch({type: FETCH_BOT_SUCCESS, payload: bot})
    return true
  } catch (err) {
    dispatch({type: FETCH_BOT_REJECTED, payload: err.message})
    return false
  }
}

export const addBot = token => async dispatch => {
  dispatch({type: CREATE_BOT_SENT})
  try {
    const bot = await createBot(token)
    dispatch({type: CREATE_BOT_SUCCESS, payload: bot})
    return true
  } catch (err) {
    dispatch({type: CREATE_BOT_REJECTED, payload: err.message})
    return false
  }
}

// COMMANDS

export const fetchCommands = token => async dispatch => {
  dispatch({type: FETCH_COMMANDS_SENT})
  try {
    const commands = await _fetchCommands(token)
    dispatch({type: FETCH_COMMANDS_SUCCESS, payload: commands})
  } catch (err) {
    dispatch({type: FETCH_COMMANDS_REJECTED, payload: err.message})
  }
}

export const createCommand = (token, options) => async dispatch => {
  dispatch({type: CREATE_COMMAND_SENT})
  try {
    const command = await _createCommand(token, options)
    dispatch({type: CREATE_COMMAND_SUCCESS, payload: command})
  } catch (err) {
    dispatch({type: CREATE_COMMAND_REJECTED, payload: err.message})
  }
}


export const deleteCommands = (token, ids) => async dispatch => {
  dispatch({type: DELETE_COMMANDS_SENT})
  try {
    const command_ids = await _deleteCommands(token, ids)
    dispatch({type: DELETE_COMMANDS_SUCCESS, payload: command_ids})
  } catch (err) {
    dispatch({type: DELETE_COMMANDS_REJECTED, payload: err.message})
  }
}

export const editCommand = (token, id, options) => async dispatch => {
  dispatch({type: EDIT_COMMAND_SENT})
  try {
    const command = await _editCommand(token, id, options)
    dispatch({type: EDIT_COMMAND_SUCCESS, payload: command})
  } catch (err) {
    dispatch({type: EDIT_COMMAND_REJECTED, payload: err.message})
  }
}

// TIMERS

export const fetchTimers = token => async dispatch => {
  dispatch({type: FETCH_TIMERS_SENT})
  try {
    const timers = await _fetchTimers(token)
    dispatch({type: FETCH_TIMERS_SUCCESS, payload: timers})
  } catch (err) {
    dispatch({type: FETCH_TIMERS_REJECTED, payload: err.message})
  }
}

export const createTimer = (token, options) => async dispatch => {
  dispatch({type: CREATE_TIMER_SENT})
  try {
    const timer = await _createTimer(token, options)
    dispatch({type: CREATE_TIMER_SUCCESS, payload: timer})
  } catch (err) {
    dispatch({type: CREATE_TIMER_REJECTED, payload: err.message})
  }
}

export const deleteTimers = (token, ids) => async dispatch => {
  dispatch({type: DELETE_TIMERS_SENT})
  try {
    const timer_ids = await _deleteTimers(token, ids)
    dispatch({type: DELETE_TIMERS_SUCCESS, payload: timer_ids})
  } catch (err) {
    dispatch({type: DELETE_TIMERS_REJECTED, payload: err.message})
  }
}

export const editTimer = (token, id, options) => async dispatch => {
  dispatch({type: EDIT_TIMER_SENT})
  try {
    const timer = await _editTimer(token, id, options)
    dispatch({type: EDIT_TIMER_SUCCESS, payload: timer})
  } catch (err) {
    dispatch({type: EDIT_TIMER_REJECTED, payload: err.message})
  }
}

// FILTERS

export const fetchFilters = token => async dispatch => {
  dispatch({type: FETCH_FILTERS_SENT})
  try {
    const filter = await _fetchFilters(token)
    dispatch({type: FETCH_FILTERS_SUCCESS, payload: filter})
  } catch (err) {
    dispatch({type: FETCH_FILTERS_REJECTED, payload: err.message})
  }
}

export const editFilter = (token, id, options) => async dispatch => {
  dispatch({type: EDIT_FILTER_SENT})
  try {
    const filter = await _editFilter(token, id, options)
    dispatch({type: EDIT_FILTER_SUCCESS, payload: filter})
    return [true]
  } catch (err) {
    dispatch({type: EDIT_FILTER_REJECTED, payload: err.message})
    return [false, err]
  }
}
