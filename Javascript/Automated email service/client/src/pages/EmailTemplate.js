import React, { useEffect, useState } from 'react';
import Helmet from "react-helmet";
import {
  Button, Box, TextField, Grid,
  Typography, CircularProgress, Container
} from '@mui/material';
import { useSnackbar } from 'notistack';
import { navigate } from "@gatsbyjs/reach-router"
import { connect } from 'react-redux'

import { fetch_email_templates, save_email_template, delete_email_template, load_email_template } from '../actions';
import Navbar from '../components/Navbar'
import EmailNavbar from '../components/EmailNavbar'
import TemplateEditor from '../components/TemplateEditor'

function EmailTemplate(props) {
  const { enqueueSnackbar } = useSnackbar();
  const { token, templates, fetch_email_templates, save_email_template,
    delete_email_template, load_email_template } = props
  const [templateName, setTemplateName] = useState(
    templates?.template?.data?.name ? templates.template.data.name : ""
  )
  const [templateSubject, setTemplateSubject] = useState(
    templates?.template?.data?.subject ? templates.template.data.subject : ""
  )
  useEffect(() => {
    if (!token) {
      navigate('/login', { replace: true })
    }
  }, [token])

  useEffect(() => {
    fetch_email_templates(token)

  }, [token, fetch_email_templates])

  useEffect(() => {
    if (templates?.template?.status === "success") {
      setTemplateName(
        templates?.template?.data?.name ? templates?.template?.data?.name : ""
      )
      setTemplateSubject(
        templates?.template?.data?.subject ? templates?.template?.data?.subject : ""
      )
    }
  }, [templates])


  useEffect(() => {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    const errors = [
      templates?.fetch?.err,
      templates?.delete?.err,
      templates?.template?.err,
      templates?.save?.err
    ]
    for (const error of errors) {
      if (error) {
        enqueueSnackbar(error.message, snackbarOptions)
      }
    }
  }, [templates, enqueueSnackbar])


  function handleSubmit(data) {
    save_email_template(token, templateName, templateSubject, data)
  }

  function onTemplateDelete(name) {
    delete_email_template(token, name)
  }

  function onTemplateLoad(name) {
    load_email_template(token, name)
  }

  function handleTemplateNameChange(e) {
    setTemplateName(e.target.value)
  }
  function handleTemplateSubjectChange(e) {
    setTemplateSubject(e.target.value)
  }

  return (
    <>
      <Helmet>
        <title>Automaton</title>
        <link rel="icon" href="/favicon.ico" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"></link>
      </Helmet>
      <Container
        sx={{
          display: 'flex',
          flexFlow: 'column',
          alignItems: 'center',
          my: 8
        }}
      >
        <EmailNavbar value="/email/template" />
        <Navbar value="/email" />
        <Box
          sx={{
            maxWidth: '780px',
            width: '100%',
          }}
        >
          <Box
            sx={{
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'center',
              alignItems: 'center'
            }}
          >
            <Typography
              sx={{
                fontSize: '24px'
              }}
            >
              Your Templates
            </Typography>
            <Box
              sx={{
                border: '1px solid',
                width: '100%',
                height: '200px',
                borderColor: 'text.primary',
                my: 1,
                overflowY: 'scroll'
              }}
            >
              {templates?.fetch?.data && (
                templates.fetch.data.map((template => {
                  return <Box
                    key={template.name}
                    sx={{
                      p: 1,
                      borderBottom: '1px solid',
                      borderColor: 'text.secondary',
                      display: 'flex',
                      alignItems: 'center',
                    }}
                  >
                    <Typography>{template.name}</Typography>
                    {template.loaded &&
                      <Typography
                        color="primary"
                        sx={{
                          fontSize: '16px',
                          fontWeight: 500,
                          ml: 1
                        }}>
                        LOADED
                      </Typography>
                    }
                    <Button
                      color="error"
                      sx={{
                        ml: 'auto'
                      }}
                      disabled={templates?.delete?.status === "pending"}
                      onClick={() => onTemplateDelete(template.name)}
                    >
                      Delete
                    </Button>
                    <Button
                      color="primary"
                      sx={{

                      }}
                      disabled={templates?.template?.status === "pending"}
                      onClick={() => onTemplateLoad(template.name)}
                    >
                      Load
                    </Button>
                  </Box>
                }))
              )}
            </Box>
          </Box>
          <Grid container columnSpacing={1}>
            <Grid item xs={6}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="name"
                label="Template Name"
                name="name"
                autoComplete="off"
                onChange={handleTemplateNameChange}
                value={templateName}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="subject"
                label="Template Subject"
                name="subject"
                autoComplete="off"
                onChange={handleTemplateSubjectChange}
                value={templateSubject}
              />
            </Grid>
          </Grid>
          <TemplateEditor handleSubmit={handleSubmit} />
        </Box>
      </Container>
    </>
  )
}

const mapStateToProps = state => ({
  token: state.token.value,
  templates: state.email_templates
})

export default connect(mapStateToProps, {
  fetch_email_templates,
  save_email_template,
  delete_email_template,
  load_email_template
})(EmailTemplate)