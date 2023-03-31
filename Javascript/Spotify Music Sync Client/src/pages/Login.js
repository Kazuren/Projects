import React from 'react';
import PropTypes from 'prop-types';
import Helmet from 'react-helmet'
import { Container, Button, TextField, Divider, Paper } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    minHeight: '100vh',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  },
  formTextField: {
    marginBottom: theme.spacing(2)
  }
}));

async function loginUser(credentials) {
  return fetch(`${process.env.REACT_APP_API_IP_ADDRESS}/api/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(credentials)
  }).then(data => data.json())
}

export default function Login({ setToken }) {
  const classes = useStyles();
  const [username, setUsername] = React.useState('');
  const [password, setPassword] = React.useState('');

  function handleUsernameChange(e) {
    setUsername(e.target.value)
  }

  function handlePasswordChange(e) {
    setPassword(e.target.value)
  }

  async function handleSubmit(e) {
    e.preventDefault()
    const token = await loginUser({username, password})
    setToken(token)
  }

  return (
    <React.Fragment>
      <Helmet>
        <title>Login</title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Paper>
        <Container className={classes.root}>
          <div className={classes.form}>
            <div className={classes.formBody}>
              <div className={classes.formGroup}>
                <TextField
                  label="Username"
                  variant="outlined"
                  onChange={handleUsernameChange}
                  value={username}
                  className={classes.formTextField}
                  InputLabelProps={{ shrink: true }}
                />
              </div>
              <div className={classes.formGroup}>
                <TextField
                  label="Password"
                  variant="outlined"
                  onChange={handlePasswordChange}
                  value={password}
                  className={classes.formTextField}
                  InputLabelProps={{ shrink: true }}
                />
              </div>
            </div>
            <Divider/>
            <div className={classes.formFooter}>
              <Button onClick={handleSubmit} color="secondary" variant="text" disableElevation>Login</Button>
            </div>
          </div>
        </Container>
      </Paper>
    </React.Fragment>
  )
}

Login.propTypes = {
  setToken: PropTypes.func.isRequired
}
