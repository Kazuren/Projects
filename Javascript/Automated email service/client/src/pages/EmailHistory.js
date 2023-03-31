import React, { useEffect } from 'react';
import Helmet from "react-helmet";
import {
  Button, Box,
  Typography, CircularProgress, Container
} from '@mui/material';
import { useSnackbar } from 'notistack';
import { navigate } from "@gatsbyjs/reach-router"
import { connect } from 'react-redux'
import { fetch_email_history } from '../actions';
import Navbar from '../components/Navbar'
import EmailNavbar from '../components/EmailNavbar'

function EmailHistory(props) {
  const { enqueueSnackbar } = useSnackbar();

  const { token, data, status, err, fetch_email_history } = props

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
    fetch_email_history(token)
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
        <EmailNavbar value="/email/history" />
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
              maxWidth: '640px'
            }}
          >
            <Button
              variant='contained'
              onClick={handleSubmit}
              sx={{
                mb: 2
              }}
            >
              Fetch History
            </Button>
            {data ? <Box
              sx={{
                display: 'flex',
                alignItems: 'center',
                flexDirection: 'column',
              }}
            >
              {data.map((company, i) => {
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
                      flexDirection: 'column'
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: '18px',
                      }}
                    >
                      {company.name}
                    </Typography>
                    <Typography
                      sx={{
                        fontSize: '16px',
                        color: '#444'
                      }}
                    >
                      {company.domain} (Page {company.page})
                    </Typography>
                    <Box
                      sx={{
                        display: 'flex',
                        flexWrap: 'wrap',
                      }}
                    >
                      {company.emails.map((email, i) => {
                        return <Typography
                          key={email}
                          sx={{
                            fontSize: '16px',
                            fontWeight: '500',
                            '&:not(:last-child):after': {
                              content: '",\\00a0"'
                            }
                          }}
                        >
                          {email}
                        </Typography>
                      })}
                    </Box>
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
  data: state.email_history.data,
  err: state.email_history.err,
  status: state.email_history.status
})

export default connect(mapStateToProps, { fetch_email_history })(EmailHistory)