import { UPDATE_TOKEN, DELETE_TOKEN } from "../actions/actionTypes"

const tokenReducer = (token = null, action) => {
  switch (action.type) {
    case UPDATE_TOKEN:
      return action.payload
    case DELETE_TOKEN:
      return null
    default:
      return token
  }
}

export default tokenReducer
