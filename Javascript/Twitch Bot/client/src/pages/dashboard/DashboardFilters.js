import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { fetchFilters, editFilter } from '../../actions';
import Filter from '../../components/dashboard/Filter'
import { useSnackbar } from 'notistack';

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));

function DashboardFilters(props) {
  const classes = useStyles();
  const { token, filters, fetchFilters, editFilter } = props
  const [loading, setLoading] = React.useState(false)

  const { enqueueSnackbar } = useSnackbar();
  // ?: Not sure if I want to preventDuplicate snackbars
  const snackbarError = { variant: 'error', preventDuplicate: false }
  const snackbarSuccess = { variant: 'success', preventDuplicate: false }

  function handleBooleanChange(event, filter) {
    void (async () => {
      setLoading(true)
      const [success, err] = await editFilter(token, filter._id, {enabled: event.target.checked, options: filter.options})
      setLoading(false)
      if (!success) {
        enqueueSnackbar(err.message, snackbarError)
      } else {
        enqueueSnackbar('Filter successfully updated!', snackbarSuccess)
      }
    })();
  }

  function handleSubmit(filter) {
    void (async () => {
      setLoading(true)
      const [success, err] = await editFilter(token, filter._id, {enabled: filter.enabled, options: filter.options})
      setLoading(false)
      if (!success) {
        enqueueSnackbar(err.message, snackbarError)
      } else {
        enqueueSnackbar('Filter successfully updated!', snackbarSuccess)
      }
    })();
  }

  React.useEffect(() => {
    fetchFilters(token)
  }, [token])

  return (
    <div className={classes.root}>
      {/* 
        for filter in filters create a <Filter options=options/>
        in the filter create a form and modal with its specific options
      */}
      {filters.map(filter => (
        <Filter loading={loading} key={filter._id} data={filter} handleSubmit={handleSubmit} handleBooleanChange={handleBooleanChange}></Filter>
      ))}
    </div>
  )
}

const mapStateToProps = state => ({
  token: state.token,
  filters: state.filters
})

export default connect(mapStateToProps, { fetchFilters, editFilter })(DashboardFilters)
