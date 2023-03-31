import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { _fetchLogFile } from '../../api'

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));


function DashboardLogFile(props) {
  const classes = useStyles();
  const { token, year, month, day } = props
  const [ file, setFile ] = React.useState([])

  React.useEffect(() => {
    async function fetchFile() {
      const file = await _fetchLogFile(token, year, month, day)
      setFile(file)
    }
    fetchFile()
  }, [token, year, month, day])
  return (
    <div className={classes.root}>
      {file}
    </div>
  )
}

const mapStateToProps = state => ({
  token: state.token,
})

export default connect(mapStateToProps, { })(DashboardLogFile)
