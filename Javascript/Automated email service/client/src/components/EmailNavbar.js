import React from 'react'
import {
  BottomNavigation, BottomNavigationAction, Paper
} from '@mui/material'
import { connect } from 'react-redux'
import { navigate } from "@gatsbyjs/reach-router"
import HomeIcon from '@mui/icons-material/Home';
import HistoryIcon from '@mui/icons-material/History';
import EmailIcon from '@mui/icons-material/Email';
import ListIcon from '@mui/icons-material/List';
import AssignmentIcon from '@mui/icons-material/Assignment';

function EmailNavbar(props) {
  const { value } = props

  return (
    <Paper
      sx={{
        position: 'fixed',
        top: 0,
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
        <BottomNavigationAction label="Home" value="/email" icon={<HomeIcon />} />
        <BottomNavigationAction label="History" value="/email/history" icon={<HistoryIcon />} />
        <BottomNavigationAction label="Test" value="/email/test" icon={<EmailIcon />} />
        <BottomNavigationAction label="Tasks" value="/email/tasks" icon={<ListIcon />} />
        <BottomNavigationAction label="Template" value="/email/template" icon={<AssignmentIcon />} />
      </BottomNavigation>
    </Paper>

  )
}

const mapStateToProps = state => ({})


export default connect(mapStateToProps, {})(EmailNavbar)