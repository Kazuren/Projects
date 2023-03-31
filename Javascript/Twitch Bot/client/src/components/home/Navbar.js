import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { navigate } from "@reach/router"
import { AppBar, Toolbar, Typography, Button } from '@material-ui/core';

// client id: 3t4vcu7m9ggdmjszt5n74ls692rj7v
// client secret: n4vtj6jcrfwdj5x7l88esd15d6hcfn

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1,
  },
  title: {
    flexGrow: 1,
  },
  appBar: {
    backgroundColor: theme.palette.primary.main
  },
  logoname: {
    fontWeight: 800,
    letterSpacing: 1,
    color: theme.palette.secondary.main
  },
  logobot: {
    fontWeight: 800,
    letterSpacing: 1,
    color: theme.palette.text.primary
  }
}));

function Navbar({ logo, token }) {
  const classes = useStyles();

  const redirect_uri = process.env.REACT_APP_REDIRECT_URI
  const client_id = process.env.REACT_APP_CLIENT_ID
  const href = `https://id.twitch.tv/oauth2/authorize?client_id=${client_id}&redirect_uri=${redirect_uri}&response_type=token&scope=user:read:email&force_verify=true`

  function handleLogin(e) {
    e.preventDefault();
    if (token) { navigate('/dashboard', { replace: false })}
    else { window.location.href = href }
  }

  return (
    <div className={classes.root}>
      <AppBar position='static' className={classes.appBar}>
        <Toolbar variant='dense'>
          <div className={classes.title}>
            <Typography className={classes.logoname} display="inline" variant="h6">
              KAZU
            </Typography>
            <Typography className={classes.logobot} display="inline" variant="h6">
              BOT
            </Typography>
          </div>
          <Button onClick={handleLogin} size='medium' color='inherit' variant="outlined">Login</Button>
        </Toolbar>
      </AppBar >
    </div>
  )
}

const mapStateToProps = state => ({
  token: state.token,
})

export default connect(mapStateToProps, {})(Navbar)