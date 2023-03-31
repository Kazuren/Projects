import {
  FETCH_EMAIL_TASKS_SENT, FETCH_EMAIL_TASKS_SUCCESS, FETCH_EMAIL_TASKS_REJECTED
} from "../actions/actionTypes"
import { persistReducer } from 'redux-persist';
import sessionStorage from 'redux-persist/lib/storage/session'

const emailTasksReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_EMAIL_TASKS_SENT:
      return { ...state, status: "pending" }
    case FETCH_EMAIL_TASKS_SUCCESS:
      return { ...state, data: action.payload, status: "success" }
    case FETCH_EMAIL_TASKS_REJECTED:
      return { ...state, err: { message: action.payload.message }, status: "rejected" }
    default:
      return state
  }
}


const persistConfig = {
  key: 'email_tasks',
  storage: sessionStorage,
  blacklist: ['err']
}

export default persistReducer(persistConfig, emailTasksReducer)
