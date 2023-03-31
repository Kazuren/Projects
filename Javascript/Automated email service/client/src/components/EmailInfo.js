import React from 'react';
import { Box, Typography, IconButton, FormGroup, FormControlLabel, Checkbox } from '@mui/material';
import { connect } from 'react-redux'
import DoneIcon from '@mui/icons-material/Done';
import CloseIcon from '@mui/icons-material/Close';
import he from 'he'


function EmailInfo(props) {
  const { company, added } = props
  function onClick() {
    props.onClick(company, added)
  }
  function handleCheckboxChange(e, email) {
    const checked = e.currentTarget.checked
    props.handleCheckboxChange(checked, company, email, added)
  }
  return (
    <Box
      sx={{
        display: 'flex',
        alignItems: 'center',
        p: 1,
        borderBottom: '1px solid black',
        position: 'relative'
      }}
    >

      <IconButton
        sx={{
          position: 'absolute',
          right: 0,
          top: 0,
        }}
        onClick={onClick}
        color={added ? "warning" : "success"}
        size="large"
      >
        {added ? <CloseIcon /> : <DoneIcon />}
      </IconButton>
      <Box sx={{
        display: 'flex',
        flex: '1 1 auto',
        flexDirection: 'column'
      }}>
        <Box
          sx={{
            m: -1,
            p: 1,
          }}
        >
          <Typography
            sx={{
              fontSize: '18px',
            }}
          >
            {he.decode(company.name)}
          </Typography>
          <Typography
            sx={{
              fontSize: '16px',
              color: '#444'
            }}
          >
            {company.domain} (Page {company.page})
          </Typography>
        </Box>
        <Box
          sx={{
            display: 'flex',
          }}
        >
          <FormGroup>
            {company.emails.map((email, i) => {
              return <FormControlLabel
                key={email.email}
                sx={{
                  fontSize: '16px',
                  color: email.sentBefore ? 'error.light' : '#222',
                  fontWeight: '500'
                }}
                control={<Checkbox
                  checked={email.checked}
                  onChange={(e) => handleCheckboxChange(e, email)}
                />}
                label={
                  <Box
                    sx={{
                      py: 0.5
                    }}
                  >
                    <Typography
                      sx={{
                        color: "#666"
                      }}
                    >
                      {he.decode(email.position)}
                    </Typography>
                    <Typography>{email.email}</Typography>
                  </Box>
                }
              />
            })}
          </FormGroup>
        </Box>
      </Box>
    </Box>
  )
}

const mapStateToProps = state => ({})

export default connect(mapStateToProps, {})(EmailInfo)