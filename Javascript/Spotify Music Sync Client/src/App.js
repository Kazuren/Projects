import React from 'react';
import { Router } from '@reach/router'
import { ThemeProvider } from '@material-ui/core/styles'
import { Theme } from './styles/Theme'
import CssBaseline from '@material-ui/core/CssBaseline'
import { Listen, Auth, Login, Admin } from './pages'
import useToken from './hooks/useToken';

function App() {
  const { token, setToken } = useToken();

  return (
    <React.Fragment>
      <CssBaseline/>
      <ThemeProvider theme={Theme}>
        <Router>
          <Listen path='/'/>
          <Auth path='/auth'/>
          {token ? <Admin path='/admin'/> : <Login setToken={setToken} path='/admin'/>}
        </Router>
      </ThemeProvider>
    </React.Fragment>
  );
}

export default App;
