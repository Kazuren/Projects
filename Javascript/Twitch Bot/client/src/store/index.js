import { createStore, applyMiddleware, combineReducers } from 'redux'
import { persistStore, persistReducer} from 'redux-persist'
import localStorage from 'redux-persist/lib/storage';
import thunk from 'redux-thunk';
import { userReducer, tokenReducer, botReducer, 
  commandReducer, timerReducer, filterReducer } from '../reducers'

const rootPersistConfig = {
  key: 'root',
  storage: localStorage,
  whitelist: ['bot', 'token', 'user', 'commands', 'timers', 'filters'],
}

const rootReducer = combineReducers({
  token: tokenReducer,
  bot: botReducer,
  user: userReducer,
  commands: commandReducer,
  timers: timerReducer,
  filters: filterReducer
})

export const store = createStore(persistReducer(rootPersistConfig, rootReducer), applyMiddleware(thunk))
export const persistor = persistStore(store)
