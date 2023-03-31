import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import {
  Paper, Checkbox, Tooltip, IconButton, Modal, Button, CircularProgress
} from '@material-ui/core';
import EditIcon from '@material-ui/icons/Edit';

import FilterForm from './FilterForm'

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
    backgroundColor: theme.palette.background.paperLight,
    padding: theme.spacing(3),
    height: '98px',
    '&.MuiPaper-outlined': {
      borderColor: theme.palette.background.paper
    }
  },
  info: {
    flex: '1'
  },
  name: {
    fontSize: '1.25rem',
    fontWeight: '500'
  },
  desc: {
    fontSize: '0.75rem',
    color: theme.palette.text.secondary
  },
  buttons: {
    flex: '0 0 auto',
    display: 'flex',
    alignItems: 'center'
  },
  modal: {
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    position: 'absolute',
    maxWidth: '560px',
    width: '560px',
  },
}));

export default function Filter(props) {
  const classes = useStyles();
  const { data } = props
  const { display_name, description, enabled } = data
  const [open, setOpen] = React.useState(false)

  function handleBooleanChange(event) {
    props.handleBooleanChange(event, data)
  }

  function handleOpen() {
    setOpen(true)
  }

  function handleClose() {
    setOpen(false)
  }

  function handleSubmit(options) {
    props.handleSubmit({_id: data._id, enabled: data.enabled, options: options})
    handleClose()
  }

  return (
    <React.Fragment>
      <Paper square variant="outlined" className={classes.root}>
        <div className={classes.info}>
          <div className={classes.name}>{display_name}</div>
          <div className={classes.desc}>{description}</div>
        </div>
        <div className={classes.buttons}>
        {props.loading ? <CircularProgress size="32px"/> :
          <>
            <Tooltip PopperProps={{disablePortal: true}} title={`Filter is ${enabled ? 'enabled' : 'disabled'}`} arrow>
              <Checkbox onChange={handleBooleanChange} style={{ width: 48, height: 48 }} color={enabled ? 'primary' : 'default'} checked={enabled}/>
            </Tooltip>
          
            <Tooltip PopperProps={{disablePortal: true}} title="Edit" arrow>
              <IconButton onClick={handleOpen} edge="end" aria-label="edit">
                <EditIcon/>
              </IconButton>
            </Tooltip>
          </>
        }
        </div>
      </Paper>
      <Modal open={open} onClose={handleClose}>
        <Paper elevation={0} square className={classes.modal}>
          <FilterForm handleSubmit={handleSubmit} filter={data}/>
        </Paper>
      </Modal>
    </React.Fragment>
  )
}
