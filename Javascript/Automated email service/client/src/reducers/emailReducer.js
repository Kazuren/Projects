import {
  FETCH_EMAIL_DATA_SENT, FETCH_EMAIL_DATA_SUCCESS, FETCH_EMAIL_DATA_REJECTED
} from "../actions/actionTypes"
import { persistReducer } from 'redux-persist';
import sessionStorage from 'redux-persist/lib/storage/session'

const emailReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_EMAIL_DATA_SENT:
      return { ...state, status: "pending" }
    case FETCH_EMAIL_DATA_SUCCESS:
      return { ...state, data: action.payload, status: "success" }
    case FETCH_EMAIL_DATA_REJECTED:
      return { ...state, err: { message: action.payload.message }, status: "rejected" }
    default:
      return state
  }
}


const persistConfig = {
  key: 'email',
  storage: sessionStorage,
  blacklist: ['err']
}

export default persistReducer(persistConfig, emailReducer)
