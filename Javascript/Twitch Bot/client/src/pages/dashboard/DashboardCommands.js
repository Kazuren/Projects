import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Button, Modal, Paper, TextField } from '@material-ui/core';
import { connect } from 'react-redux'
import { fetchCommands, createCommand, editCommand, deleteCommands } from '../../actions'

import CommandTable from '../../components/dashboard/CommandTable'
import CommandForm from '../../components/dashboard/CommandForm'

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
  {field: 'user_cooldown', headerName: 'User cooldown (s)', sortable: true, numeric: true},
  {field: 'global_cooldown', headerName: 'Global cooldown (s)', sortable: true, numeric: true},
  {
    field: 'command_mode', 
    headerName: 'Mode', 
    sortable: true,
    sortFunc: (a, b, orderBy) => {
      const values = {'Online and Offline': 3, 'Online only': 2, 'Offline only': 1}
      let modeA = a[orderBy]
      let modeB = b[orderBy]
      return values[modeA] - values[modeB]
    }
  },
  {
    field: 'userlevel',
    headerName: 'Userlevel', 
    sortable: true,
    sortFunc: (a, b, orderBy) => {
      const values = {Everyone: 1, Subscriber: 2, VIP: 3, Moderator: 4, Broadcaster: 5}
      let userlevelA = a[orderBy]
      let userlevelB = b[orderBy]
      return values[userlevelA] - values[userlevelB]
    }
  },
  {field: 'enabled', headerName: 'Enabled', switch: true, sortable: true},
]
const searchableKeys = [
  'name', 'response'
]

function searchRows(rows, query) {
  return rows.filter(obj => Object.keys(obj).filter(key => searchableKeys.includes(key)).some(key => obj[key].toLowerCase().includes(query.toLowerCase())));
}

function DashboardCommands(props) {
  const classes = useStyles();
  const { token, commands, fetchCommands, createCommand, deleteCommands, editCommand } = props
  const [open, setOpen] = React.useState(false)
  const [openEditModal, setOpenEditModal] = React.useState(false)
  const [query, setQuery] = React.useState('')
  const [command, setCommand] = React.useState(null)

  React.useEffect(() => {
    // if commands don't exist in redux store or commands.length === 0
    // call api through redux async action to fetch all commands
    fetchCommands(token)
  }, [token, fetchCommands])

  function handleOpen() {
    setOpen(true)
  }

  function handleClose() {
    setOpen(false)
  }

  // TODO: make this not hardcoded maybe
  function handleBooleanChange(event, field, command) {
    // replace the first "!" if we are editing the command 
    // otherwise we have an extra "!"
    editCommand(token, command._id, {name: command.name.replace(/^!/g, ''), enabled: !command.enabled, response: command.response, userCooldown: command.user_cooldown, globalCooldown: command.global_cooldown, commandMode: command.command_mode, userlevel: command.userlevel})
  }

  function handleQueryChange(e) {
    setQuery(e.target.value)
  }

  function handleSubmit(name, enabled, response, userCooldown, globalCooldown, commandMode, userlevel) {
    createCommand(token, {name, enabled, response, userCooldown, globalCooldown, commandMode, userlevel})
    handleClose()
  }

  function handleDelete(commands) {
    deleteCommands(token, commands)
  }

  function handleEditSubmit(name, enabled, response, userCooldown, globalCooldown, commandMode, userlevel) {
    editCommand(token, command._id, {name, enabled, response, userCooldown, globalCooldown, commandMode, userlevel})
    handleCloseEditModal()
  }

  function handleOpenEditModal(command_ids) {
    const command_id = command_ids[0]
    const command = commands.find(command => command._id === command_id)

    setOpenEditModal(true)
    setCommand(command)
  }
  function handleCloseEditModal() {
    setOpenEditModal(false)
    setCommand(null)
  }

  // reimplement DataGrid with sorting with Table
  return (
    <React.Fragment>
      <div className={classes.root}>
        <div className={classes.toolbar}>
          <Button onClick={handleOpen} color="primary" variant="outlined" size="medium" disableElevation>
            Create Command
          </Button>
          <TextField 
            onChange={handleQueryChange} 
            placeholder="eg. !youtube" 
            label="Search for a command..." 
            size="small" 
            variant="outlined"
            value={query}
          />
        </div>
        <CommandTable title="Commands" handleEdit={handleOpenEditModal} handleDelete={handleDelete} handleBooleanChange={handleBooleanChange} id={'_id'} rows={searchRows(commands, query)} columns={columns}/>
      </div>
      <Modal open={open} onClose={handleClose}>
        <Paper elevation={0} square className={classes.modal}>
          <CommandForm handleSubmit={handleSubmit}/>
        </Paper>
      </Modal>
      <Modal open={openEditModal} onClose={handleCloseEditModal}>
        <Paper elevation={0} square className={classes.modal}>
          <CommandForm submitText='Edit Command' command={command} handleSubmit={handleEditSubmit}/>
        </Paper>
      </Modal>
    </React.Fragment>
  )
}

const mapStateToProps = state => ({
  token: state.token,
  commands: state.commands
})

export default connect(mapStateToProps, { fetchCommands, createCommand, editCommand, deleteCommands })(DashboardCommands)
