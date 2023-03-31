import {
  FETCH_EMAIL_TEMPLATES_SENT, FETCH_EMAIL_TEMPLATES_SUCCESS, FETCH_EMAIL_TEMPLATES_REJECTED,
  SAVE_EMAIL_TEMPLATE_SENT, SAVE_EMAIL_TEMPLATE_SUCCESS, SAVE_EMAIL_TEMPLATE_REJECTED,
  DELETE_EMAIL_TEMPLATE_SENT, DELETE_EMAIL_TEMPLATE_SUCCESS, DELETE_EMAIL_TEMPLATE_REJECTED,
  LOAD_EMAIL_TEMPLATE_SENT, LOAD_EMAIL_TEMPLATE_SUCCESS, LOAD_EMAIL_TEMPLATE_REJECTED
} from "../actions/actionTypes"
import { persistReducer } from 'redux-persist';
import sessionStorage from 'redux-persist/lib/storage/session'

const emailTemplateReducer = (state = {}, action) => {
  switch (action.type) {
    case FETCH_EMAIL_TEMPLATES_SENT:
      return {
        ...state,
        fetch: { status: "pending" }
      }
    case FETCH_EMAIL_TEMPLATES_SUCCESS:
      return {
        ...state,
        fetch: { data: action.payload, status: "success" }
      }
    case FETCH_EMAIL_TEMPLATES_REJECTED:
      return {
        ...state,
        fetch: { err: { message: action.payload.message }, status: "rejected" }
      }
    case LOAD_EMAIL_TEMPLATE_SENT:
      return {
        ...state,
        template: { status: "pending" }
      }
    case LOAD_EMAIL_TEMPLATE_SUCCESS:
      return {
        ...state,
        template: { data: action.payload, status: "success" },
        fetch: {
          ...state.fetch,
          data: state.fetch.data.map(template => {
            if (template.name === action.payload.name) {
              return {
                ...template,
                loaded: true
              }
            }
            return {
              ...template, loaded: false
            }
          })
        }
      }
    case LOAD_EMAIL_TEMPLATE_REJECTED:
      return {
        ...state,
        template: { err: { message: action.payload.message }, status: "rejected" }
      }
    case SAVE_EMAIL_TEMPLATE_SENT:
      return {
        ...state,
        save: { status: "pending" }
      }
    case SAVE_EMAIL_TEMPLATE_SUCCESS:
      return {
        ...state,
        fetch: {
          ...state.fetch,
          data: [
            ...state.fetch.data.filter(template => {
              return template.name !== action.payload.name
            }).map(template => { return { ...template, loaded: false } }),
            { name: action.payload.name, loaded: action.payload.loaded }
          ]
        },
        template: { data: action.payload, status: "success" },
        save: { status: "success" },
      }
    case SAVE_EMAIL_TEMPLATE_REJECTED:
      return {
        ...state,
        save: { err: { message: action.payload.message }, status: "rejected" }
      }
    case DELETE_EMAIL_TEMPLATE_SENT:
      return {
        ...state,
        delete: { status: "pending" }
      }
    case DELETE_EMAIL_TEMPLATE_SUCCESS:
      return {
        ...state,
        fetch: {
          ...state.fetch,
          data: [
            ...state.fetch.data.filter(template => {
              return template.name !== action.payload.name
            })
          ]
        },
        delete: { status: "success" }
      }
    case DELETE_EMAIL_TEMPLATE_REJECTED:
      return {
        ...state,
        delete: { err: { message: action.payload.message }, status: "rejected" }
      }
    default:
      return state
  }
}


const persistConfig = {
  key: 'email_templates',
  storage: sessionStorage
}

export default persistReducer(persistConfig, emailTemplateReducer)
