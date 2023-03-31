import {
  UPDATE_BOT, DELETE_BOT,
  FETCH_BOT_SUCCESS, FETCH_BOT_REJECTED,
  CREATE_BOT_SUCCESS, CREATE_BOT_REJECTED, 
  UPDATE_BOT_SUCCESS, UPDATE_BOT_REJECTED,
  JOIN_CHANNEL_SUCCESS, JOIN_CHANNEL_REJECTED,
  PART_CHANNEL_SUCCESS, PART_CHANNEL_REJECTED
} from "../actions/actionTypes"

const merge = (prev, next) => Object.assign({}, prev, next)

const botReducer = (bot = null, action) => {
  switch (action.type) {
    case UPDATE_BOT:
      return merge(bot, action.payload)
    case DELETE_BOT:
      return null
    case UPDATE_BOT_SUCCESS: // make this return only the update and merge
      return action.payload
    case UPDATE_BOT_REJECTED:
      return bot
    case FETCH_BOT_SUCCESS:
      return action.payload
    case FETCH_BOT_REJECTED:
      return null
    case CREATE_BOT_SUCCESS:
      return action.payload
    case CREATE_BOT_REJECTED:
      return null
    case JOIN_CHANNEL_SUCCESS:
      return action.payload
    case JOIN_CHANNEL_REJECTED:
      return bot
    case PART_CHANNEL_SUCCESS:
      return action.payload
    case PART_CHANNEL_REJECTED:
      return bot
    default:
      return bot
  }
}

export default botReducer
