import {
  FETCH_FILTERS_SUCCESS, EDIT_FILTER_SUCCESS
} from "../actions/actionTypes"

const filterReducer = (filters = [], action) => {
  switch (action.type) {
    case FETCH_FILTERS_SUCCESS:
      return action.payload
    case EDIT_FILTER_SUCCESS:
      return filters.map(filter => filter._id === action.payload._id ? action.payload : filter)
    default:
      return filters
  }
}

export default filterReducer
