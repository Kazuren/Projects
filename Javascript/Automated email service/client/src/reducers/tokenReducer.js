import {
  LOGIN_USER_SENT, LOGIN_USER_SUCCESS, LOGIN_USER_REJECTED,
  REGISTER_USER_SENT, REGISTER_USER_SUCCESS, REGISTER_USER_REJECTED
} from "../actions/actionTypes"
import { persistReducer } from 'redux-persist';
import sessionStorage from 'redux-persist/lib/storage/session'

const tokenReducer = (state = {}, action) => {
  switch (action.type) {
    case REGISTER_USER_SENT:
    case LOGIN_USER_SENT:
      return { ...state, status: "pending" }
    case REGISTER_USER_SUCCESS:
    case LOGIN_USER_SUCCESS:
      return { ...state, value: action.payload, status: "success" }
    case REGISTER_USER_REJECTED:
    case LOGIN_USER_REJECTED:
      return { ...state, err: { message: action.payload.message }, status: "rejected" }
    default:
      return state
  }
}

const persistConfig = {
  key: 'token',
  storage: sessionStorage,
  blacklist: ['err']
}

export default persistReducer(persistConfig, tokenReducer)
