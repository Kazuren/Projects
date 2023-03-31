import {
  FETCH_EMAIL_HISTORY_SENT, FETCH_EMAIL_HISTORY_SUCCESS, FETCH_EMAIL_HISTORY_REJECTED
} from "../actions/actionTypes"
import { persistReducer } from 'redux-persist';
import sessionStorage from 'redux-persist/lib/storage/session'

const emailHistoryReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_EMAIL_HISTORY_SENT:
      return { ...state, status: "pending" }
    case FETCH_EMAIL_HISTORY_SUCCESS:
      return { ...state, data: action.payload, status: "success" }
    case FETCH_EMAIL_HISTORY_REJECTED:
      return { ...state, err: { message: action.payload.message }, status: "rejected" }
    default:
      return state
  }
}


const persistConfig = {
  key: 'email_history',
  storage: sessionStorage,
  blacklist: ['err']
}

export default persistReducer(persistConfig, emailHistoryReducer)
