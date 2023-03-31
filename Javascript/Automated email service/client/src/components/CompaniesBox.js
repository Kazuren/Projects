import React from 'react';
import { Box } from '@mui/material';
import { connect } from 'react-redux'
import EmailInfo from './EmailInfo'

function CompaniesBox(props) {
  const { companies, onEmailClick, handleCheckboxChange, added } = props

  return (
    <Box
      sx={{
        width: '320px',
        border: '1px solid black',
        height: '480px',
        overflowY: 'scroll',
        overflowX: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        mb: 2
      }}
    >
      {companies.map((company, i) => {
        return <EmailInfo key={company.id} company={company} onClick={onEmailClick} handleCheckboxChange={handleCheckboxChange} added={added} />
      })}
    </ Box>
  )
}

const mapStateToProps = state => ({})

export default connect(mapStateToProps, {})(CompaniesBox)