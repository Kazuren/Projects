import {
  FETCH_COMMANDS_SUCCESS, FETCH_COMMANDS_REJECTED,
  CREATE_COMMAND_SUCCESS, CREATE_COMMAND_REJECTED,
  DELETE_COMMANDS_SUCCESS, DELETE_COMMANDS_REJECTED,
  EDIT_COMMAND_SUCCESS, EDIT_COMMAND_REJECTED
} from "../actions/actionTypes"


const commandReducer = (commands = [], action) => {
  switch (action.type) {
    case FETCH_COMMANDS_SUCCESS:
      return action.payload
    case CREATE_COMMAND_SUCCESS:
      return [...commands, action.payload]
    case DELETE_COMMANDS_SUCCESS:
      return commands.filter(command => !action.payload.includes(command._id))
    case EDIT_COMMAND_SUCCESS:
      return commands.map(command => command._id === action.payload._id ? action.payload : command)
    default:
      return commands
  }
}

export default commandReducer
