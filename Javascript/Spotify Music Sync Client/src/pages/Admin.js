import React from 'react';
import Helmet from 'react-helmet'
import { Container, Button } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import useToken from '../hooks/useToken';

const useStyles = makeStyles((theme) => ({
  root: {
    minHeight: '100vh',
    display: 'flex',
  },
  buttons: {
    height: '100%',
    width: '300px',
    margin: 'auto'
  },
  button: {
    width: '100%',
    fontSize: '2rem',
  }
}));

export default function Admin(props) {
  const classes = useStyles();
  const { token } = useToken();

  React.useEffect(() => {
    // make sure token is correct
  }, [token])

  function handleHost(e) {
    e.preventDefault()

    const { client_id, response_type, redirect_uri, scope, show_dialog } = {
      client_id: process.env.REACT_APP_SPOTIFY_CLIENT_ID,
      response_type: 'code',
      redirect_uri: process.env.REACT_APP_REDIRECT_URI,
      scope: 'user-read-playback-state user-read-currently-playing user-read-recently-played user-read-playback-position',
      show_dialog: true
    }
    const href = `https://accounts.spotify.com/authorize?client_id=${client_id}&response_type=${response_type}&redirect_uri=${redirect_uri}&scope=${scope}&show_dialog=${show_dialog}&state=${token}`
    window.location.href = href
  }

  return (
    <React.Fragment>
      <Helmet>
        <title>Host</title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Container className={classes.root}>
        <div className={classes.buttons}>
          <Button className={classes.button} onClick={handleHost} color="primary" variant="contained" size="large">Host</Button>
        </div>
      </Container>
    </React.Fragment>
  )
}
