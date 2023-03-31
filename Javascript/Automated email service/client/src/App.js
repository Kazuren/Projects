import React from 'react';
import { PersistGate } from 'redux-persist/integration/react'
import { Provider } from 'react-redux';
import { store, persistor } from './store'
import { Router } from '@gatsbyjs/reach-router'
import {
  Home, Email, Login, Register,
  TestEmail, EmailHistory, EmailTasks, EmailTemplate
} from './pages'
import { ThemeProvider } from '@mui/material/styles'
import { Theme } from './styles/Theme'
import { CssBaseline } from '@mui/material'
import { SnackbarProvider } from 'notistack';

function App() {
  return (
    <React.Fragment>
      <CssBaseline />
      <Provider store={store}>
        <PersistGate loading={null} persistor={persistor}>
          <ThemeProvider theme={Theme}>
            <SnackbarProvider
              maxSnack={1}
              anchorOrigin={{
                vertical: 'bottom',
                horizontal: 'right',
              }}
              autoHideDuration={3000}
              hideIconVariant
            >
              <Router>
                <Home path="/" />
                <Email path="/email" />
                <TestEmail path="email/test" />
                <EmailHistory path="email/history" />
                <EmailTasks path="email/tasks" />
                <EmailTemplate path="email/template" />
                <Login path="/login" />
                <Register path="/register" />
              </Router>
            </SnackbarProvider>
          </ThemeProvider>
        </PersistGate>
      </Provider>
    </React.Fragment>
  );
}

export default App;