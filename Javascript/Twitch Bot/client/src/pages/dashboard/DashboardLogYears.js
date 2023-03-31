import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { _fetchLogYears } from '../../api'
import { Link } from '@material-ui/core';
import { Link as RouterLink } from '@reach/router'

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));


function DashboardLogYears(props) {
  const classes = useStyles();
  const { token } = props
  const [ years, setYears ] = React.useState([])

  React.useEffect(() => {
    // don't call setYears if component gets unmounted
    async function fetchYears() {
      const years = await _fetchLogYears(token)
      setYears(years)
    }
    fetchYears()
  }, [token])
  return (
    <div className={classes.root}>
      {years.map((year, index) => (
        <Link key={year} component={RouterLink} to={`${year}`}>
          {year}
        </Link>
      ))}
    </div>
  )
}

const mapStateToProps = state => ({
  token: state.token
})

export default connect(mapStateToProps, {})(DashboardLogYears)
