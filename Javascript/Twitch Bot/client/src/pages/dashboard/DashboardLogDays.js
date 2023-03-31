import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { _fetchLogDays } from '../../api'
import { Link } from '@material-ui/core';
import { Link as RouterLink } from '@reach/router'

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));


function DashboardLogDays(props) {
  const classes = useStyles();
  const { token, year, month } = props
  const [ days, setDays ] = React.useState([])

  React.useEffect(() => {
    async function fetchDays() {
      const days = await _fetchLogDays(token, year, month)
      setDays(days)
    }
    fetchDays()
  }, [token, year, month])
  return (
    <div className={classes.root}>
      {days.map((day, index) => (
        <Link key={day} component={RouterLink} to={`${day}`}>
          {day}
        </Link>
      ))}

    </div>
  )
}

const mapStateToProps = state => ({
  token: state.token
})

export default connect(mapStateToProps, { })(DashboardLogDays)
