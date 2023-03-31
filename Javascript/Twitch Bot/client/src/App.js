import React from 'react';
import { PersistGate } from 'redux-persist/integration/react'
import { Provider } from 'react-redux';
import { store, persistor } from './store'
import { Router } from '@reach/router'
import { Home, Auth, 
  Dashboard, DashboardHome, DashboardCommands, DashboardLogYears,
  DashboardLogMonths, DashboardLogDays, DashboardLogFile,
  DashboardFilters, DashboardKeywords, DashboardTimers, DashboardVariables
} from './pages'
import { ThemeProvider } from '@material-ui/core/styles'
import { Theme } from './styles/Theme'
import CssBaseline from '@material-ui/core/CssBaseline'
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
            >
              <Router>
                <Home path="/"/>
                <Dashboard path="/dashboard">
                  <DashboardHome path="/"/>
                  <DashboardCommands path="/commands"/>
                  <DashboardLogYears path="/logs"/>
                  <DashboardLogMonths path="/logs/:year"/>
                  <DashboardLogDays path="/logs/:year/:month"/>
                  <DashboardLogFile path="/logs/:year/:month/:day"/>
                  <DashboardFilters path="/filters"/>
                  <DashboardKeywords path="/keywords"/>
                  <DashboardTimers path="/timers"/>
                  <DashboardVariables path="/variables"/>
                </Dashboard>
                <Auth path="/auth"/>
              </Router>
            </SnackbarProvider>
          </ThemeProvider>
        </PersistGate>
      </Provider>
    </React.Fragment>
  );
}

export default App;
