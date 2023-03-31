import { createStore, applyMiddleware, combineReducers } from 'redux'
import { persistStore, persistReducer } from 'redux-persist'
import sessionStorage from 'redux-persist/lib/storage/session'
import thunk from 'redux-thunk';
import { tokenReducer, emailReducer, emailHistoryReducer, emailTasksReducer, emailTemplateReducer } from '../reducers'

const rootPersistConfig = {
  key: 'root',
  storage: sessionStorage,
  blacklist: ['token', 'email', 'email_history', 'email_tasks', 'email_templates'],
}

const rootReducer = combineReducers({
  token: tokenReducer,
  email: emailReducer,
  email_history: emailHistoryReducer,
  email_tasks: emailTasksReducer,
  email_templates: emailTemplateReducer
})

export const store = createStore(persistReducer(rootPersistConfig, rootReducer), applyMiddleware(thunk))
export const persistor = persistStore(store)