import React, { useState, useEffect } from 'react'
import Helmet from "react-helmet"
import {
  Container, Box, TextField,
  Button, CircularProgress, Typography
} from '@mui/material'
import { useSnackbar } from 'notistack'
import { connect } from 'react-redux'
import { navigate } from "@gatsbyjs/reach-router"
import { _test_email } from '../api'
import Navbar from '../components/Navbar'
import EmailNavbar from '../components/EmailNavbar'
import EmailFormModal from '../components/EmailFormModal'


function TestEmail(props) {
  const [query, setQuery] = useState("")
  const [companyName, setCompanyName] = useState("")
  const [emails, setEmails] = useState("")
  const [domain, setDomain] = useState("")
  const [page, setPage] = useState("")
  const [sentStatus, setSentStatus] = useState("")
  const [openModal, setOpenModal] = useState(false)
  const { enqueueSnackbar } = useSnackbar();

  const { token } = props

  useEffect(() => {
    if (!token) {
      navigate('/login', { replace: true })
    }
  }, [token])


  async function handleSubmit(event, hits, first, readingVolume) {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    event.preventDefault();

    try {
      handleModalClose()
      const email_array = emails.split(',')
      setSentStatus("pending")
      await _test_email(token, {
        query: query,
        company: {
          name: companyName,
          emails: email_array,
          domain: domain,
          page: page
        },
        hits: hits,
        first: first,
        reading_volume: readingVolume
      })
      enqueueSnackbar("Successfully sent email!", { variant: 'success' })
      setSentStatus("success")
    }
    catch (err) {
      setSentStatus("error")
      enqueueSnackbar(err.message, snackbarOptions)
    }
  }

  function handleModalSubmit(event, hits, companyName, readingVolume) {
    handleSubmit(event, hits, companyName, readingVolume)
  }

  function handleModalOpen() {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if (query === "" || companyName === "" || emails === "" || domain === "" || page === "") {
      enqueueSnackbar("All fields are required!", snackbarOptions)
      return
    }
    setOpenModal(true)
  }

  function handleModalClose() {
    setOpenModal(false)
  }

  function handleQueryChange(e) {
    setQuery(e.target.value)
  }
  function handleCompanyNameChange(e) {
    setCompanyName(e.target.value)
  }
  function handleEmailChange(e) {
    setEmails(e.target.value)
  }
  function handleDomainChange(e) {
    setDomain(e.target.value)
  }
  function handlePageChange(e) {
    setPage(e.target.value)
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
          alignItems: 'center',
          my: 8
        }}
      >
        <EmailFormModal open={openModal} handleClose={handleModalClose} handleSubmit={handleModalSubmit} />
        <EmailNavbar value="/email/test" />
        <Navbar value="/email" />
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            flex: "1 1 auto",
            maxWidth: "320px"
          }}
        >
          <Typography component="h1" variant="h5">
            Test Email Sending Functionality
          </Typography>
          <Box sx={{ mt: 1 }}>
            <TextField
              margin="normal"
              required
              fullWidth
              id="query"
              label="Query"
              name="query"
              autoComplete="off"
              autoFocus
              onChange={handleQueryChange}
              value={query}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              id="name"
              label="Company Name"
              name="name"
              autoComplete="off"
              autoFocus
              onChange={handleCompanyNameChange}
              value={companyName}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="domain"
              label="Domain"
              type="text"
              id="domain"
              autoComplete="off"
              onChange={handleDomainChange}
              value={domain}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="email"
              label="Emails"
              type="text"
              id="email"
              autoComplete="off"
              onChange={handleEmailChange}
              value={emails}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="page"
              label="Page"
              type="text"
              id="page"
              autoComplete="off"
              onChange={handlePageChange}
              value={page}
            />
            <Box sx={{ position: 'relative', mt: 3 }}>
              <Button
                type="submit"
                fullWidth
                variant="contained"
                disabled={sentStatus === "pending"}
                onClick={handleModalOpen}
              >
                Test
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
      </Container>
    </>
  )
}

const mapStateToProps = state => ({
  token: state.token.value,
})

export default connect(mapStateToProps, {})(TestEmail)