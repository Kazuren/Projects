import React from 'react';
import Helmet from 'react-helmet'
import { Container, Button, Link } from '@material-ui/core'
import { makeStyles } from '@material-ui/core/styles';
import usePrevious from '../hooks/usePrevious'
import ProgressBar from '../components/ProgressBar'
import clsx from 'clsx'

const useStyles = makeStyles((theme) => ({
  root: {
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center'
  },
  songContainer: {
    position: 'fixed',
    bottom: 0,
    left: 0,
    backgroundColor: theme.palette.background.default,
    padding: theme.spacing(2),
    width: '100%',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    color: theme.palette.text.primary
  },
  songInfo: {
    display: 'flex',
    flexDirection: 'column',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  songName: {
    fontSize: '14px',
    '&:hover': {
      cursor: 'pointer',
      textDecoration: 'underline'
    }
  },
  albumImage: {
    width: '36px',
    height: '36px'
  },
  songInfoWrapper: {
    display: 'flex',
    flex: 1
  },
  artists: {
    fontSize: '12px',
    color: theme.palette.text.secondary,
    '& span': {
      '&:hover': {
        color: theme.palette.text.primary,
        cursor: 'pointer',
        textDecoration: 'underline'
      },
    }
  },
  barWrapper: {
    width: '100%',
    maxWidth: '800px'
  },
  barInfo: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  },
  songTime: {
    fontSize: '12px'
  },
  mr1: {
    marginRight: theme.spacing(1)
  },
  mr2: {
    marginRight: theme.spacing(2)
  },
  ml1: {
    marginLeft: theme.spacing(1)
  },
  mb1: {
    marginBottom: theme.spacing(1)
  },
  centerContent: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center'
  },
  rightFakeDiv: {
    flex: 1
  },
  paused: {
    display: 'flex',
    justifyContent: 'center',
    flex: 1
  }
}));

const URL = process.env.REACT_APP_WEBSOCKET_SERVER

export default function Listen({ location }) {
  const classes = useStyles();
  const [websocket, setWebSocket] = React.useState()
  const [track, setTrack] = React.useState({})
  const [progress, setProgress] = React.useState(0)
  const [expiration, setExpiration] = React.useState(localStorage.getItem('expiration'))
  const token = location.state ? location.state?.token : null
  const prevTrack = usePrevious(track)
  let timeout = 250
  let playTimeout = 500

  // connect at start
  React.useEffect(() => {
    connect()
    // eslint-disable-next-line
  }, [])

  function check() {
    if (!websocket || websocket.readyState === WebSocket.CLOSED) {
      connect()
    }
  }

  function connect() {
    const websocket = new WebSocket(URL)
    let connectInterval;
    websocket.onopen = () => {
      console.log('connected')
      setWebSocket(websocket)
      timeout = 250 // reset timer to 250 on open of websocket connection 
      clearTimeout(connectInterval)
    }
    websocket.onclose = e => {
      console.log(
        `Socket is closed. Reconnect will be attempted in ${Math.min(
            10000 / 1000,
            (timeout + timeout) / 1000
        )} seconds.`,
        e.reason
      );
      timeout = timeout + timeout // increment retry interval
      connectInterval = setTimeout(check, Math.min(10000, timeout)); // call check function after timeout
    }

    websocket.onmessage = evt => {
      if (evt.data instanceof Blob) {
        return
      }
      const track = JSON.parse(evt.data)
      setProgress(track.progress) // -3000 (stream delay)
      setTrack(track)
    }
  }

  React.useEffect(() => {
    const timer = setTimeout(() => {
      if (track?.active) {
        setProgress(Math.min(progress + 200, track.duration));
      }
    }, 200);

    return () => clearTimeout(timer);
    // eslint-disable-next-line
  }, [progress]);

  React.useEffect(() => {
    const timer = setTimeout(() => {
      localStorage.setItem('expiration', expiration - 1);
      setExpiration(expiration - 1)
    }, 1000)

    return () => clearTimeout(timer);
  }, [expiration])

  async function playTrack(track) {
    let connectInterval;

    const response = await fetch(`https://api.spotify.com/v1/me/player/play`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        uris: [track.uri],
        position_ms: progress
      })
    })

    if (response.status !== 204) {
      console.log(
        `Could not play song. Will retry in ${Math.min(
            10000 / 1000,
            (playTimeout + playTimeout) / 1000
        )} seconds.`
      );
      playTimeout = playTimeout + playTimeout // increment retry interval
      connectInterval = setTimeout(() => playTrack(track), Math.min(10000, playTimeout)); // call playTrack function after timeout
    } else {
      playTimeout = 500
      clearTimeout(connectInterval)
    }
  }

  // when track changes or on login
  React.useEffect(() => {
    if (!token || !track || !prevTrack) {
      return
    }

    if (!track.active) {
      return
    }

    if (track.uri === prevTrack.uri) {
      return
    }

    playTrack(track)
    // eslint-disable-next-line
  }, [track, prevTrack, token])

  React.useEffect(() => {
    if (!token) {
      return
    }
    fetch(`https://api.spotify.com/v1/me/player/repeat?state=off`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`
      },
    })
  }, [token])

  function handleListen(e) {
    e.preventDefault()

    const { client_id, response_type, redirect_uri, scope, show_dialog } = {
      client_id: process.env.REACT_APP_SPOTIFY_CLIENT_ID,
      response_type: 'token',
      redirect_uri: process.env.REACT_APP_CLIENT_REDIRECT_URI,
      scope: 'user-modify-playback-state',
      show_dialog: true
    }
    const href = `https://accounts.spotify.com/authorize?client_id=${client_id}&response_type=${response_type}&redirect_uri=${redirect_uri}&scope=${scope}&show_dialog=${show_dialog}`
    window.location.href = href
  }

  return (
    <React.Fragment>
      <Helmet>
        <title>
          {track?.artists ? `${track.artists[0]} - ${track?.song}` : 'No song playing'}
        </title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Container className={classes.root}>
        <div className={classes.content}>
          <div className={classes.songContainer}>
            {(() => {
              if (!track || !track.active) { return <div className={classes.paused}>Playback is currently paused</div> };
              const artists = track.artists.map((artist, index, array) => {
                return (
                  <React.Fragment key={artist}>
                    <span>{artist}</span>
                    {index !== array.length - 1 ? ', ' : ''}
                  </React.Fragment>
                )
              })
              return (
                <div className={classes.songInfoWrapper}>
                  <img alt='' className={clsx(classes.albumImage, classes.mr1)} src={track.image.url}/>
                  <div className={clsx(classes.songInfo)}>
                    <div className={classes.songName}>{track.song}</div>
                    <div className={classes.artists}>{artists}</div>
                  </div>
                </div>
              )
            })()}
            {(() => {
              if (!track || !track.active) { return null }
              const minutes = Math.floor(progress / 1000 / 60)
              const seconds = progress / 1000 % 60 < 10 ? '0' + ~~(progress / 1000 % 60) : ~~(progress / 1000 % 60)

              const duration = track?.duration ? track.duration : 0
              const duration_m = Math.floor(duration / 1000 / 60)
              const duration_s = duration / 1000 % 60 < 10 ? '0' + ~~(duration / 1000 % 60) : ~~(duration / 1000 % 60)
              return (
                <div className={classes.barWrapper}>
                  <div className={classes.barInfo}>
                    <span className={clsx(classes.mr1, classes.songTime)}>{minutes}:{seconds}</span>
                    <ProgressBar completed={progress / duration * 100}/>
                    <span className={clsx(classes.ml1, classes.songTime)}>{duration_m}:{duration_s}</span>
                  </div>
                </div>
              )
            })()}
            { track && track.active ? <div className={classes.rightFakeDiv}></div> : null}
          </div>
          <div className={classes.centerContent}>
            <div className={clsx(classes.buttons, classes.mb1)}>
              { !token ? (
                <Button onClick={handleListen} color="primary" variant="contained" size="large">Listen</Button>
              ) : null}
              { token ? <Button className={classes.mr1} onClick={() => playTrack(track)} color="primary" variant="contained" size="large">Resync</Button> : null}
              { token ? <Button onClick={handleListen} color="primary" variant="contained" size="large">Refresh session</Button> : null}
            </div>
            { token ? <div>Session expires in { expiration } seconds </div> : null}
              <div>Make sure you have a spotify player open and playing a song before syncing</div>
              <div>If you like this app consider <Link className={classes.donateLink} href="https://www.paypal.me/kazuren">donating</Link> &#9829;</div>
              <div>Made by Kazuren</div>
            </div>
          </div>
        </Container>
    </React.Fragment>
  )
}
