import React, { useState } from 'react';
import { Box, Button, Modal, TextField } from '@mui/material';
import { connect } from 'react-redux'
import { useSnackbar } from 'notistack'

function EmailFormModal(props) {
  const { enqueueSnackbar } = useSnackbar();

  const [hits, setHits] = useState("")
  const [companyName, setCompanyName] = useState("")
  const [readingVolume, setReadingVolume] = useState("")

  const { open, handleClose } = props


  function handleHitsChange(e) {
    setHits(e.target.value)
  }

  function handleCompanyNameChange(e) {
    setCompanyName(e.target.value)
  }

  function handleReadingVolumeChange(e) {
    setReadingVolume(e.target.value)
  }

  function handleSubmit(event) {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    event.preventDefault();
    if (hits === "" || companyName === "" || readingVolume === "") {
      enqueueSnackbar("All fields are required!", snackbarOptions)
      return
    }
    props.handleSubmit(event, hits, companyName, readingVolume)
  }
  // "hits per month"
  // "#1 company name"
  // "monthly reading volume"
  return (
    <Modal
      open={open}
      onClose={handleClose}
    >
      <Box
        component="form"
        noValidate
        onSubmit={handleSubmit}
        sx={{
          zIndex: 1500,
          width: '320px',
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          bgcolor: 'background.paper',
          p: 2
        }}
      >
        <TextField
          margin="normal"
          required
          fullWidth
          id="hits"
          label="Hits per month"
          placeholder="50-100"
          name="hits"
          autoComplete="off"
          autoFocus
          onChange={handleHitsChange}
          value={hits}
        />
        <TextField
          margin="normal"
          required
          fullWidth
          id="name"
          label="Number one company name"
          placeholder="Sixth City Marketing"
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
          id="name"
          label="Monthly reading volume"
          placeholder="70"
          name="name"
          autoComplete="off"
          autoFocus
          onChange={handleReadingVolumeChange}
          value={readingVolume}
        />
        <Box
          sx={{
            display: 'flex',
            justifyContent: 'end',
            gap: '8px',
            mt: 1,
          }}
        >

          <Button onClick={handleClose}>Cancel</Button>
          <Button
            type="submit"
            variant="contained"
          >
            Submit
          </Button>
        </Box>
      </Box>
    </Modal>
  )
}

const mapStateToProps = state => ({})

export default connect(mapStateToProps, {})(EmailFormModal)