import React, { useState, useEffect } from 'react'
import Helmet from "react-helmet"
import {
  Container, Box,
  Button, CircularProgress, Typography
} from '@mui/material'
import { useSnackbar } from 'notistack'
import { connect } from 'react-redux'
import { navigate } from "@gatsbyjs/reach-router"
import { fetch_email_data } from '../actions'
import { _send_emails } from '../api'
import DomainSearchBar from '../components/DomainSearchBar'
import Navbar from '../components/Navbar'
import EmailNavbar from '../components/EmailNavbar'
import EmailFormModal from '../components/EmailFormModal'
import CompaniesBox from '../components/CompaniesBox'


function Email(props) {
  const { enqueueSnackbar } = useSnackbar();

  const [sentStatus, setSentStatus] = useState("")
  const [rejectedCompanies, setRejectedCompanies] = useState([])
  const [acceptedCompanies, setAcceptedCompanies] = useState([])
  const [openModal, setOpenModal] = useState(false)


  const { token, data, status, err, fetch_email_data } = props

  useEffect(() => {
    if (!token) {
      navigate('/login', { replace: true })
    }
  }, [token])


  useEffect(() => {
    if (data) {
      const companies = data.companies.map(company => {
        const emails = company.emails.map(email => {
          return {
            email: email.address,
            checked: !email.sentBefore,
            sentBefore: email.sentBefore,
            position: email.position
          }
        })
        return { ...company, emails }
      })
      setRejectedCompanies(companies)
      setAcceptedCompanies([])
    }
  }, [data])


  useEffect(() => {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if (err) {
      enqueueSnackbar(err.message, snackbarOptions)
    }
  }, [err, enqueueSnackbar])

  function handleCheckboxChange(checked, company, email, added) {
    if (added) {
      const companies = acceptedCompanies.map(c => {
        if (c.id === company.id) {
          const emails = c.emails.map(e => {
            if (e.email === email.email) {
              return { ...e, checked: checked }
            }
            return e
          })
          return { ...c, emails }
        }
        return c
      })
      setAcceptedCompanies(companies)
    } else {
      const companies = rejectedCompanies.map(c => {
        if (c.id === company.id) {
          const emails = c.emails.map(e => {
            if (e.email === email.email) {
              return { ...e, checked: checked }
            }
            return e
          })
          return { ...c, emails }
        }
        return c
      })
      setRejectedCompanies(companies)
    }
    return
  }

  function handleSubmit(event, query, page, limit) {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    event.preventDefault();
    if (query === "" || page === "" || limit === "") {
      enqueueSnackbar("All fields are required!", snackbarOptions)
      return
    }
    fetch_email_data(token, query, page, limit)
  };

  function handleModalSubmit(event, hits, companyName, readingVolume) {
    const companies = acceptedCompanies.map(company => {
      const emails = company.emails.filter(email => email.checked).map(email => {
        return email.email
      })
      return { ...company, emails }
    }).filter(company => company.emails.length !== 0)
    if (companies.length === 0) {
      throw Error("Please send emails to at least one company!")
    }
    sendEmails(companies, hits, companyName, readingVolume)
  }

  function handleModalOpen() {
    try {
      const companies = acceptedCompanies.map(company => {
        const emails = company.emails.filter(email => email.checked).map(email => {
          return email.email
        })
        return { ...company, emails }
      }).filter(company => company.emails.length !== 0)
      if (companies.length === 0) {
        throw Error("Please send emails to at least one company!")
      }
      setOpenModal(true)
    }
    catch (err) {
      enqueueSnackbar(err.message, { variant: 'error' })
    }
  }

  function handleModalClose() {
    setOpenModal(false)
  }

  function onEmailClick(company, added) {
    if (!added) {
      setRejectedCompanies(rejectedCompanies.filter(c => c.id !== company.id))
      setAcceptedCompanies([...acceptedCompanies, company])
    } else {
      setAcceptedCompanies(acceptedCompanies.filter(c => c.id !== company.id))
      setRejectedCompanies([...rejectedCompanies, company])
    }
  }

  function acceptAll() {
    setAcceptedCompanies([...rejectedCompanies, ...acceptedCompanies])
    setRejectedCompanies([])
  }

  function rejectAll() {
    setRejectedCompanies([...acceptedCompanies, ...rejectedCompanies])
    setAcceptedCompanies([])
  }

  async function sendEmails(companies, hits, companyName, readingVolume) {
    try {
      handleModalClose()
      setSentStatus("pending")
      await _send_emails(token,
        {
          query: data.query,
          companies: companies,
          hits: hits,
          first: companyName,
          reading_volume: readingVolume
        }
      )
      enqueueSnackbar("Successfully started new email task!", { variant: 'success' })
      setSentStatus("success")
    } catch (err) {
      setSentStatus("error")
      enqueueSnackbar(err.message, { variant: 'error' })
    }
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
          my: 8
        }}
      >
        <EmailFormModal open={openModal} handleClose={handleModalClose} handleSubmit={handleModalSubmit} />
        <EmailNavbar value="/email" />
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
              flex: "1 1 auto"
            }}
          >
            <DomainSearchBar handleSubmit={handleSubmit} />
            {data ? <Box
              sx={{
                display: 'flex',
                alignItems: 'center',
                flexDirection: 'column',
                mb: 2
              }}
            >
              <Typography variant="h6"
                sx={{
                  my: 3
                }}
              >
                Results for "{data.query}"
              </Typography>
              <Box>
                <Box
                  sx={{
                    display: 'flex',
                    justifyContent: 'center',
                    flexWrap: 'wrap',
                    gap: '10px'
                  }}
                >
                  <Box
                    sx={{
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      alignSelf: 'start'
                    }}
                  >
                    <Typography
                      sx={{
                        mb: 1,
                        fontWeight: '400',
                        fontSize: '18px'
                      }}
                    >
                      Rejected companies
                    </Typography>
                    <CompaniesBox companies={rejectedCompanies} onEmailClick={onEmailClick} handleCheckboxChange={handleCheckboxChange} added={false} />
                  </Box>
                  <Box
                    sx={{
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center'
                    }}
                  >
                    <Typography
                      sx={{
                        mb: 1,
                        fontWeight: '400',
                        fontSize: '18px'
                      }}
                    >
                      Accepted companies
                    </Typography>
                    <CompaniesBox companies={acceptedCompanies} onEmailClick={onEmailClick} handleCheckboxChange={handleCheckboxChange} added={true} />
                    <Box
                      sx={{
                        display: 'flex',
                        gap: '16px',
                        justifyContent: 'flex-end',
                        width: '100%'
                      }}
                    >
                      <Button variant="text" color="success" onClick={acceptAll}>Accept All</Button>
                      <Button variant="text" color="warning" onClick={rejectAll}>Reject All</Button>
                      <Box sx={{ position: 'relative' }}>
                        <Button
                          variant="contained"
                          color="primary"
                          onClick={handleModalOpen}
                          disabled={sentStatus === "pending"}
                        >
                          Send
                        </Button>
                        {sentStatus === "pending" && (
                          <CircularProgress
                            size={24}
                            sx={{
                              position: 'absolute',
                              top: '50%',
                              left: '50%',
                              marginTop: '-12px',
                              marginLeft: '-12px',
                            }}
                          />
                        )}
                      </Box>
                    </Box>
                  </Box>
                </Box>
              </Box>
            </Box> : null}
          </Box>
        }
      </Container>
    </>
  )
}

const mapStateToProps = state => ({
  token: state.token.value,
  data: state.email.data,
  err: state.email.err,
  status: state.email.status
})

export default connect(mapStateToProps, { fetch_email_data })(Email)