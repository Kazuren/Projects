import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { _fetchLogMonths } from '../../api'
import { Link } from '@material-ui/core';
import { Link as RouterLink } from '@reach/router'

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));


function DashboardLogMonths(props) {
  const classes = useStyles();
  const { token, year } = props
  const [ months, setMonths ] = React.useState([])

  React.useEffect(() => {
    async function fetchMonths() {
      const months = await _fetchLogMonths(token, year)
      setMonths(months)
    }
    fetchMonths()
  }, [token, year])
  return (
    <div className={classes.root}>
      {months.map((month, index) => (
        <Link key={month} component={RouterLink} to={`${month}`}>
          {month}
        </Link>
      ))}
    </div>
  )
}

const mapStateToProps = state => ({
  token: state.token,
})

export default connect(mapStateToProps, { })(DashboardLogMonths)
