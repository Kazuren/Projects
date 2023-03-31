import { UPDATE_USER, DELETE_USER,
  FETCH_USER_SUCCESS, FETCH_USER_REJECTED
} from "../actions/actionTypes"

const merge = (prev, next) => Object.assign({}, prev, next)

const userReducer = (user = null, action) => {
  switch (action.type) {
    case UPDATE_USER:
      return merge(user, action.payload)
    case DELETE_USER:
      return null
    case FETCH_USER_SUCCESS:
      return action.payload
    case FETCH_USER_REJECTED:
      return null
    default:
      return user
  }
}

export default userReducer
