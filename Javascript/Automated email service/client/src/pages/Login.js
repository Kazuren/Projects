import React, { useState, useEffect } from 'react';
import Helmet from "react-helmet";
import {
  Avatar, Button, TextField, Box,
  Typography, CircularProgress, Container
} from '@mui/material';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import { useSnackbar } from 'notistack';
import { navigate } from "@gatsbyjs/reach-router"
import { connect } from 'react-redux'
import { login } from '../actions';

function Login(props) {
  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")
  const { enqueueSnackbar } = useSnackbar();

  const { token, status, err, login } = props

  useEffect(() => {
    if (token) {
      navigate('/', { replace: true })
    }
  }, [token])


  useEffect(() => {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if (err) {
      enqueueSnackbar(err.message, snackbarOptions)
    }
  }, [err, enqueueSnackbar])


  function handleSubmit(event) {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    event.preventDefault();
    if (username === "") {
      enqueueSnackbar("Username can't be empty!", snackbarOptions)
      return
    }
    if (password === "") {
      enqueueSnackbar("Password can't be empty!", snackbarOptions)
      return
    }
    login(username, password)
  };

  function handleUsernameChange(e) {
    setUsername(e.target.value)
  }

  function handlePasswordChange(e) {
    setPassword(e.target.value)
  }

  return (
    <>
      <Helmet>
        <title>Automaton</title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Container
        sx={{
          display: "flex",
          flexFlow: "column",
          height: "100vh",
        }}
      >
        {status === "pending" ? <Box
          sx={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flex: "1 1 auto"
          }}
        >
          <CircularProgress size={100} />
        </Box> :
          <Box
            sx={{
              mt: 8,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              flex: "1 1 auto"
            }}
          >
            <Avatar sx={{ m: 1, bgcolor: 'warning.main' }}>
              <LockOutlinedIcon />
            </Avatar>
            <Typography component="h1" variant="h5">
              Sign in
            </Typography>
            <Box component="form" noValidate onSubmit={handleSubmit} sx={{ mt: 1 }}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="username"
                label="Username"
                name="username"
                autoComplete="username"
                autoFocus
                onChange={handleUsernameChange}
                value={username}
              />
              <TextField
                margin="normal"
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                autoComplete="current-password"
                onChange={handlePasswordChange}
                value={password}
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                sx={{ mt: 3 }}
              >
                Sign In
              </Button>
            </Box>
          </Box>
        }
      </Container>
    </>
  )
}

const mapStateToProps = state => ({
  token: state.token.value,
  err: state.token.err,
  status: state.token.status
})

export default connect(mapStateToProps, { login })(Login)