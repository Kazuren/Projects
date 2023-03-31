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

export default function TimerForm(props) {
  const classes = useStyles();

  const [name, setName] = React.useState(props?.timer?.name || '')
  const [enabled, setEnabled] = React.useState(typeof props?.timer?.enabled !== 'undefined' ? props?.timer?.enabled : true)
  const [response, setResponse] = React.useState(props?.timer?.response || '')
  const [interval, setInterval] = React.useState(typeof props?.timer?.interval !== 'undefined' ? props?.timer?.interval : 5)
  const [chatLines, setChatLines] = React.useState(typeof props?.timer?.chat_lines !== 'undefined' ? props?.timer?.chat_lines : 10)
  const { enqueueSnackbar } = useSnackbar();

  function handleNameChange(e) {
    setName(e.target.value)
  }
  function handleEnabledChange(e) {
    setEnabled(e.target.checked)
  }
  function handleResponseChange(e) {
    setResponse(e.target.value)
  }
  function handleIntervalChange(e) {
    const re = /^[0-9\b]+$/;
    const minutes = e.target.value.replace(/^0+/, '')
    if (minutes === '') {setInterval('')}
    else if (re.test(minutes)) {
      if (Number(minutes) > 1440) {
        setInterval(1440)
        return
      }
      setInterval(minutes)
    }
  }
  function handleChatLinesChange(e) {
    const re = /^[0-9\b]+$/;
    const lines = e.target.value.replace(/^0+/, '')
    if (lines === '') {setChatLines(0)}
    else if (re.test(lines)) {
      setChatLines(lines)
    }
  }

  function handleSubmit() {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if(name === '') {
      enqueueSnackbar(`Timer name can't be empty!`, snackbarOptions)
      return
    }
    if(response === '') {
      enqueueSnackbar(`Timer response can't be empty!`, snackbarOptions)
      return
    }
    if(interval < 1 || interval > 1440) {
      enqueueSnackbar('Timer interval needs to be between 1 and 1440!', snackbarOptions)
    }
    props.handleSubmit(name, enabled, response, interval, chatLines)
  }

  return (
    <form className={classes.form} noValidate autoComplete="off">
      <div className={classes.formBody}>
        <div className={classes.formGroup}>
          <TextField 
            label="Timer name" 
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
            label="Timer response" 
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
            label="Timer Interval" 
            variant="outlined"
            onChange={handleIntervalChange}
            value={interval}
            className={clsx(classes.formTextField, classes.marginRight)}
            placeholder="5"
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputProps={{
              endAdornment: <InputAdornment position="end">min.</InputAdornment>
            }}
            InputLabelProps={{ shrink: true }}
          />
          <TextField 
            label="Minimum chat lines" 
            variant="outlined"
            onChange={handleChatLinesChange}
            value={chatLines}
            className={classes.formTextField}
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
          />
          
        </div>
      </div>
      <Divider/>
      <div className={classes.formFooter}>
        <Button onClick={handleSubmit} color="primary" variant="text" disableElevation>{props.submitText || 'Create Timer'}</Button>
      </div>
    </form>
  )
}
