import React, { useEffect } from 'react';
import Helmet from "react-helmet";
import {
  Button, Box,
  Typography, CircularProgress, Container
} from '@mui/material';
import { useSnackbar } from 'notistack';
import { navigate } from "@gatsbyjs/reach-router"
import { connect } from 'react-redux'
import { fetch_email_tasks } from '../actions';
import Navbar from '../components/Navbar'
import EmailNavbar from '../components/EmailNavbar'

function EmailTasks(props) {
  const { enqueueSnackbar } = useSnackbar();

  const { token, data, status, err, fetch_email_tasks } = props

  useEffect(() => {
    if (!token) {
      navigate('/login', { replace: true })
    }
  }, [token])

  useEffect(() => {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if (err) {
      enqueueSnackbar(err.message, snackbarOptions)
    }
  }, [err, enqueueSnackbar])


  function handleSubmit(event) {
    event.preventDefault();
    fetch_email_tasks(token)
  };

  return (
    <>
      <Helmet>
        <title>Automaton</title>
        <link rel="icon" href="/favicon.ico" />
      </Helmet>
      <Container
        sx={{
          display: 'flex',
          flexFlow: 'column',
          alignItems: 'center',
          my: 8
        }}
      >
        <EmailNavbar value="/email/tasks" />
        <Navbar value="/email" />
        {status === "pending" ? <Box
          sx={{
            position: 'fixed',
            left: '50%',
            top: '50%',
            transform: 'translate(-50%, -50%)'
          }}
        >
          <CircularProgress size={100} />
        </Box> :
          <Box
            sx={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              flex: "1 1 auto",
              maxWidth: '640px',
              width: '100%',
            }}
          >
            <Button
              variant='contained'
              onClick={handleSubmit}
              sx={{
                mb: 2
              }}
            >
              Fetch Tasks
            </Button>
            {data ? <Box
              sx={{
                display: 'flex',
                alignItems: 'center',
                flexDirection: 'column',
                width: '100%'
              }}
            >
              {data.map((task, i) => {
                return <Box
                  key={i}
                  sx={{
                    p: 1,
                    border: '1px solid #555',
                    width: '100%'
                  }}
                >
                  <Box
                    sx={{
                      display: 'flex',
                      width: '100%',
                      flexDirection: 'column'
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: '18px',
                      }}
                    >
                      {task.query}
                    </Typography>
                    <Typography
                      sx={{
                        fontSize: '16px',
                        color: '#444'
                      }}
                    >
                      Status: {task.status} {task.error ? `(${task.error})` : null}
                    </Typography>
                  </Box>
                </Box>
              })}
            </Box> : null}
          </Box>
        }
      </Container>
    </>
  )
}

const mapStateToProps = state => ({
  token: state.token.value,
  data: state.email_tasks.data,
  err: state.email_tasks.err,
  status: state.email_tasks.status
})

export default connect(mapStateToProps, { fetch_email_tasks })(EmailTasks)