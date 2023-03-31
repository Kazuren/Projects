import {
  FETCH_TIMERS_SUCCESS, CREATE_TIMER_SUCCESS, DELETE_TIMERS_SUCCESS, EDIT_TIMER_SUCCESS
} from "../actions/actionTypes"

const timerReducer = (timers = [], action) => {
  switch (action.type) {
    case FETCH_TIMERS_SUCCESS:
      return action.payload
    case CREATE_TIMER_SUCCESS:
      return [...timers, action.payload]
    case DELETE_TIMERS_SUCCESS:
      return timers.filter(timer => !action.payload.includes(timer._id))
    case EDIT_TIMER_SUCCESS:
      return timers.map(timer => timer._id === action.payload._id ? action.payload : timer)
    default:
      return timers
  }
}

export default timerReducer
