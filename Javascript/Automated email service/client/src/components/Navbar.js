import React from 'react'
import {
  BottomNavigation, BottomNavigationAction, Paper
} from '@mui/material'
import { connect } from 'react-redux'
import { navigate } from "@gatsbyjs/reach-router"
import EmailIcon from '@mui/icons-material/Email';
// import InstagramIcon from '@mui/icons-material/Instagram';

function Navbar(props) {
  const { value } = props

  return (
    <Paper
      sx={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: 1000
      }}
      variant="outlined"
    >
      <BottomNavigation
        showLabels
        value={value}
        onChange={(event, v) => {
          navigate(v)
        }}
      >
        <BottomNavigationAction label="Email" value="/email" icon={<EmailIcon />} />
        {/* <BottomNavigationAction label="Social" value="/social" icon={<InstagramIcon />} /> */}
      </BottomNavigation>
    </Paper>

  )
}

const mapStateToProps = state => ({})


export default connect(mapStateToProps, {})(Navbar)