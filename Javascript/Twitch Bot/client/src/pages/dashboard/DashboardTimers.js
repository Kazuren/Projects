import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Button, Modal, Paper, TextField } from '@material-ui/core';
import { connect } from 'react-redux'
import { fetchTimers, createTimer, editTimer, deleteTimers } from '../../actions';
import CommandTable from '../../components/dashboard/CommandTable'
import TimerForm from '../../components/dashboard/TimerForm'

const useStyles = makeStyles((theme) => ({
  root: {
  },
  modal: {
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    position: 'absolute',
    maxWidth: '560px',
    width: '560px',
  },
  toolbar: {
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: theme.spacing(2)
  }
}));

const columns = [
  {field: 'name', headerName: 'Name', sortable: true},
  {field: 'response', headerName: 'Response', sortable: true},
  {field: 'interval', headerName: 'Interval (minutes)', sortable: true},
  {field: 'chat_lines', headerName: 'Minimum chat lines', sortable: true},
  {field: 'enabled', headerName: 'Enabled', switch: true, sortable: true},
]

const searchableKeys = [
  'name', 'response'
]

function searchRows(rows, query) {
  return rows.filter(obj => Object.keys(obj).filter(key => searchableKeys.includes(key)).some(key => obj[key].toLowerCase().includes(query.toLowerCase())));
}

function DashboardTimers(props) {
  const classes = useStyles();
  const { token, timers, fetchTimers, createTimer, deleteTimers, editTimer } = props
  const [open, setOpen] = React.useState(false)
  const [openEditModal, setOpenEditModal] = React.useState(false)
  const [query, setQuery] = React.useState('')
  const [timer, setTimer] = React.useState(null)

  React.useEffect(() => {
    fetchTimers(token)
  }, [token, fetchTimers])

  function handleOpen() {
    setOpen(true)
  }

  function handleClose() {
    setOpen(false)
  }

  function handleBooleanChange(event, field, timer) {
    editTimer(token, timer._id, {name: timer.name, enabled: !timer.enabled, response: timer.response, interval: timer.interval, chatLines: timer.chat_lines})
  }

  function handleQueryChange(e) {
    setQuery(e.target.value)
  }

  function handleSubmit(name, enabled, response, interval, chatLines) {
    createTimer(token, {name, enabled, response, interval, chatLines})
    handleClose()
  }

  function handleDelete(timers) {
    deleteTimers(token, timers)
  }

  function handleEditSubmit(name, enabled, response, interval, chatLines) {
    editTimer(token, timer._id, {name, enabled, response, interval, chatLines})
    handleCloseEditModal()
  }

  function handleOpenEditModal(timer_ids) {
    const timer_id = timer_ids[0]
    const timer = timers.find(timer => timer._id === timer_id)

    setOpenEditModal(true)
    setTimer(timer)
  }
  function handleCloseEditModal() {
    setOpenEditModal(false)
    setTimer(null)
  }
  

  return (
    <React.Fragment>
      <div className={classes.root}>
        <div className={classes.toolbar}>
          <Button onClick={handleOpen} color="primary" variant="outlined" size="medium" disableElevation>
            Create Timer
          </Button>
          <TextField 
            onChange={handleQueryChange} 
            placeholder="eg. youtube" 
            label="Search for a timer..." 
            size="small" 
            variant="outlined"
            value={query}
          />
        </div>
        <CommandTable title="Timers" handleEdit={handleOpenEditModal} handleDelete={handleDelete} handleBooleanChange={handleBooleanChange} id={'_id'} rows={searchRows(timers, query)} columns={columns}/>
      </div>
      <Modal open={open} onClose={handleClose}>
        <Paper elevation={0} square className={classes.modal}>
          <TimerForm handleSubmit={handleSubmit}/>
        </Paper>
      </Modal>
      <Modal open={openEditModal} onClose={handleCloseEditModal}>
        <Paper elevation={0} square className={classes.modal}>
          <TimerForm submitText='Edit Timer' timer={timer} handleSubmit={handleEditSubmit}/>
        </Paper>
      </Modal>
    </React.Fragment>
  )
}

const mapStateToProps = state => ({
  token: state.token,
  timers: state.timers
})

export default connect(mapStateToProps, { fetchTimers, createTimer, editTimer, deleteTimers })(DashboardTimers)
