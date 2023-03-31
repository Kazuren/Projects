import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import clsx from 'clsx';
import { Button, Divider, 
  TextField, FormControlLabel, Checkbox,
  InputAdornment, Tooltip, Typography, MenuItem 
} from '@material-ui/core';
import HelpOutlineIcon from '@material-ui/icons/HelpOutline';
import { useSnackbar } from 'notistack';

const useStyles = makeStyles((theme) => ({
  form: {
  },
  formBody: {
    padding: theme.spacing(2),
    display: 'flex',
    flexDirection: 'column'
  },
  formFooter: {
    display: 'flex',
    justifyContent: 'flex-end',
    padding: theme.spacing(2)
  },
  checkboxLabel: {
    margin: 0
  },
  formTextField: {
    flexBasis: 0,
    flexGrow: 1,
  },
  marginRight: {
    marginRight: theme.spacing(2)
  },
  formGroup: {
    display: 'flex',
    marginBottom: theme.spacing(2),
    '&:last-child': {
      marginBottom: 0
    },
  }
}));

export default function CommandForm(props) {
  const classes = useStyles();
  // replace the first "!" if we are editing the command 
  // otherwise we have an extra "!"

  const [name, setName] = React.useState(props?.command?.name.replace(/^!/g, '') || '')
  const [enabled, setEnabled] = React.useState(typeof props?.command?.enabled !== 'undefined' ? props?.command?.enabled : true)
  const [response, setResponse] = React.useState(props?.command?.response || '')
  const [userCooldown, setUserCooldown] = React.useState(typeof props?.command?.user_cooldown !== 'undefined' ? props?.command?.user_cooldown : 15)
  const [globalCooldown, setGlobalCooldown] = React.useState(typeof props?.command?.global_cooldown !== 'undefined' ? props?.command?.global_cooldown : 5)
  const [commandMode, setCommandMode] = React.useState(props?.command?.command_mode || 'Online and Offline')
  const [userlevel, setUserlevel] = React.useState(props?.command?.userlevel || 'Everyone')

  const { enqueueSnackbar } = useSnackbar();

  function handleNameChange(e) {
    // remove whitespace from command name
    setName(e.target.value.replace(/\s/g, ''))
  }
  function handleEnabledChange(e) {
    setEnabled(e.target.checked)
  }
  function handleResponseChange(e) {
    setResponse(e.target.value)
  }
  function handleUserCooldownChange(e) {
    const re = /^[0-9\b]+$/;
    const cooldown = e.target.value.replace(/^0+/, '')
    if (cooldown === '') {setUserCooldown(0)}
    else if (re.test(cooldown)) {
      setUserCooldown(cooldown)
    }
  }
  function handleGlobalCooldownChange(e) {
    const re = /^[0-9\b]+$/;
    const cooldown = e.target.value.replace(/^0+/, '')
    if (cooldown === '') {setGlobalCooldown(0)}
    else if (re.test(cooldown)) {
      setGlobalCooldown(cooldown)
    }
  }
  function handleCommandModeChange(e) {
    setCommandMode(e.target.value)
  }
  function handleUserlevelChange(e) {
    setUserlevel(e.target.value)
  }

  function handleSubmit() {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if(name === '') {
      enqueueSnackbar(`Command name can't be empty!`, snackbarOptions)
      return
    }
    if(response === '') {
      enqueueSnackbar(`Command response can't be empty!`, snackbarOptions)
      return
    }
    props.handleSubmit(name, enabled, response, userCooldown, globalCooldown, commandMode, userlevel)
  }

  return (
    <form className={classes.form} noValidate autoComplete="off">
      <div className={classes.formBody}>
        <div className={classes.formGroup}>
          <TextField 
            label="Command name" 
            variant="outlined"
            className={classes.formTextField}
            InputProps={{
              startAdornment: <InputAdornment position="start">!</InputAdornment>
            }}
            onChange={handleNameChange}
            value={name}
          />
          <FormControlLabel control={<Checkbox onChange={handleEnabledChange} checked={enabled} color="primary" />} 
            label="Enabled"
            className={classes.checkboxLabel}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField
            className={classes.formTextField}
            label="Command response" 
            variant="outlined"
            onChange={handleResponseChange}
            value={response}
            InputProps={{
              endAdornment: <InputAdornment position="end">
                <Tooltip className={classes.tooltip} placement="top" arrow title={
                  <React.Fragment>
                    <Typography>Special use case: $(user), $(channel), $(uptime)</Typography>
                  </React.Fragment>
                }>
                  <HelpOutlineIcon color="secondary"/>
                </Tooltip>
              </InputAdornment>
            }}
            InputLabelProps={{ shrink: true }}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="User cooldown" 
            variant="outlined"
            onChange={handleUserCooldownChange}
            value={userCooldown}
            className={clsx(classes.formTextField, classes.marginRight)}
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
            InputProps={{
              endAdornment: <InputAdornment position="end">secs.</InputAdornment>
            }}
          />
          <TextField 
            label="Global cooldown" 
            variant="outlined"
            onChange={handleGlobalCooldownChange}
            value={globalCooldown}
            className={classes.formTextField}
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
            InputProps={{
              endAdornment: <InputAdornment position="end">secs.</InputAdornment>
            }}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="Command mode" 
            variant="outlined"
            select
            value={commandMode}
            onChange={handleCommandModeChange}
            className={clsx(classes.formTextField, classes.marginRight)}
          >
            <MenuItem value={'Online and Offline'}>Online and Offline</MenuItem>
            <MenuItem value={'Online only'}>Online only</MenuItem>
            <MenuItem value={'Offline only'}>Offline only</MenuItem>
          </TextField>
          <TextField 
            label="Minimum userlevel" 
            variant="outlined"
            select
            className={classes.formTextField}
            value={userlevel}
            onChange={handleUserlevelChange}
          >
            {/* TODO: CHANGE TO LOWERCASE VALUES */}
            <MenuItem value={'Everyone'}>Everyone</MenuItem>
            <MenuItem value={'Subscriber'}>Subscriber</MenuItem>
            <MenuItem value={'VIP'}>VIP</MenuItem>
            <MenuItem value={'Moderator'}>Moderator</MenuItem>
            <MenuItem value={'Broadcaster'}>Broadcaster</MenuItem>
          </TextField>
        </div>
      </div>
      <Divider/>
      <div className={classes.formFooter}>
        <Button onClick={handleSubmit} color="primary" variant="text" disableElevation>{props.submitText || 'Create Command'}</Button>
      </div>
    </form>
  )
}
