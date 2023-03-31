import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import clsx from 'clsx';
import { Button, Divider, 
  TextField, FormControlLabel, Checkbox,
  InputAdornment, Tooltip, Typography, MenuItem
} from '@material-ui/core';
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
  formTextField: {
    flexBasis: 0,
    flexGrow: 1,
  },
  formGroup: {
    display: 'flex',
    marginBottom: theme.spacing(2),
    '&:last-child': {
      marginBottom: 0
    },
  },
  checkboxLabel: {
    margin: 0
  },
  marginRight: {
    marginRight: theme.spacing(2)
  },
}));

export default function FilterForm(props) {
  const classes = useStyles();
  return (
    <form className={classes.form} noValidate autoComplete="off">
      {props.filter.name === 'caps' ? <CapsFilterForm handleSubmit={props.handleSubmit} classes={classes} filter={props.filter}/> : null}
    </form>
  )
}

function CapsFilterForm(props) {
  const {filter, classes} = props
  const [mode, setMode] = React.useState(filter.options.mode)
  const [minimum, setMinimum] = React.useState(filter.options.minimum)
  const [number, setNumber] = React.useState(filter.options.number)
  const [length, setLength] = React.useState(filter.options.length)
  const [reason, setReason] = React.useState(filter.options.reason)
  const [userlevel, setUserlevel] = React.useState(filter.options.userlevel)

  const [announce, setAnnounce] = React.useState(filter.options.announce)
  const [cooldown, setCooldown] = React.useState(filter.options.cooldown)
  const [warning, setWarning] = React.useState(filter.options.warning)
  const [warning_length, setWarningLength] = React.useState(filter.options.warning_length)

  const { enqueueSnackbar } = useSnackbar();

  function handleModeChange(e) {
    const mode = e.target.value

    if (mode === 'percentage' && Number(number) > 100) {
      setNumber(100)
    } else if (mode === 'static' && Number(number) > 500) {
      setNumber(500)
    }
    setMode(e.target.value)
  }
  function handleMinimumChange(e) {
    const re = /^[0-9\b]+$/;
    const minimum = e.target.value.replace(/^0+/, '')
    if (minimum === '') {setMinimum(0)}
    else if (re.test(minimum)) {
      if(Number(minimum) > 500) {
        setMinimum(500)
        return
      }
      setMinimum(minimum)
    }
  }
  function handleNumberChange(e) {
    const re = /^[0-9\b]+$/;
    const number = e.target.value.replace(/^0+/, '')
    if (number === '') {setNumber(0)}
    else if (re.test(number)) {
      if(Number(number) > 100 && mode === 'percentage') {
        setNumber(100)
        return
      }
      else if(Number(number) > 500 && mode === 'static') {
        setNumber(500)
        return
      }
      setNumber(number)
    }
  }
  function handleLengthChange(e) {
    const re = /^[0-9\b]+$/;
    const length = e.target.value.replace(/^0+/, '')
    if (length === '') {setLength('')}
    else if (re.test(length)) {
      if (Number(length) > 86400) {
        setLength(86400)
        return
      }
      setLength(length)
    }
  }
  function handleReasonChange(e) {
    setReason(e.target.value)
  }
  function handleUserlevelChange(e) {
    setUserlevel(e.target.value)
  }
  function handleAnnounceChange(e) {
    setAnnounce(e.target.checked)
  }
  function handleCooldownChange(e) {
    const re = /^[0-9\b]+$/;
    const cooldown = e.target.value.replace(/^0+/, '')
    if (cooldown === '') {setCooldown(0)}
    else if (re.test(cooldown)) {
      if (Number(cooldown) > 86400) {
        setCooldown(86400)
        return
      }
      setCooldown(cooldown)
    }
  }
  function handleWarningChange(e) {
    setWarning(e.target.checked)
  }
  function handleWarningLengthChange(e) {
    const re = /^[0-9\b]+$/;
    const warning_length = e.target.value.replace(/^0+/, '')
    if (warning_length === '') {setWarningLength('')}
    else if (re.test(warning_length)) {
      if (Number(warning_length) > 86400) {
        setWarningLength(86400)
        return
      }
      setWarningLength(warning_length)
    }
  }

  function handleSubmit() {
    const snackbarOptions = { variant: 'error', preventDuplicate: true }
    if (length === '') {
      enqueueSnackbar(`Timeout length can't be empty`, snackbarOptions)
      return
    }
    if (warning_length === '') {
      enqueueSnackbar(`Warning length can't be empty`, snackbarOptions)
      return
    }
    props.handleSubmit({
      mode, minimum, number, length, reason, 
      userlevel, announce, cooldown, warning, warning_length
    })
  }

  return (
    <React.Fragment>
      <div className={classes.formBody}>
        <div className={classes.formGroup}>
          <TextField
            label="Caps moderation mode"
            variant="outlined"
            select
            value={mode}
            onChange={handleModeChange}
            className={classes.formTextField}
          >
            <MenuItem value={'percentage'}>Percentage based</MenuItem>
            <MenuItem value={'static'}>Static value</MenuItem>
          </TextField>
        </div>
        <div className={classes.formGroup}>
          <TextField
            label="Min. chars in message"
            variant="outlined"
            onChange={handleMinimumChange}
            value={minimum}
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            className={clsx(classes.formTextField, classes.marginRight)}
            InputLabelProps={{ shrink: true }}
            // InputProps={{
            //   endAdornment: <InputAdornment position="end">chars.</InputAdornment>
            // }}
          />
          <TextField
            label={mode === 'percentage' ? "% message in caps" : "Max caps allowed in message"}
            variant="outlined"
            onChange={handleNumberChange}
            value={number}
            className={classes.formTextField}
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
            InputProps={ mode === 'percentage' ? {
              endAdornment: <InputAdornment position="end">%</InputAdornment>
            } : null}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="Timeout length" 
            variant="outlined"
            onChange={handleLengthChange}
            value={length}
            className={classes.formTextField}
            placeholder="600"
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
            InputProps={{
              endAdornment: <InputAdornment position="end">secs.</InputAdornment>
            }}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="Timeout reason" 
            variant="outlined"
            onChange={handleReasonChange}
            value={reason}
            className={classes.formTextField}
            InputLabelProps={{ shrink: true }}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="Exempt userlevel" 
            variant="outlined"
            select
            onChange={handleUserlevelChange}
            value={userlevel}
            className={classes.formTextField}
          >
            <MenuItem value={'moderator'}>Moderator</MenuItem>
            <MenuItem value={'vip'}>VIP</MenuItem>
            <MenuItem value={'subscriber'}>Subscriber</MenuItem>
          </TextField>
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="Announcement cooldown" 
            variant="outlined"
            onChange={handleCooldownChange}
            value={cooldown}
            className={classes.formTextField}
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
            InputProps={{
              endAdornment: <InputAdornment position="end">secs.</InputAdornment>
            }}
          />
          <FormControlLabel control={<Checkbox onChange={handleAnnounceChange} checked={announce} color="primary" />} 
            label="Enabled"
            className={classes.checkboxLabel}
          />
        </div>
        <div className={classes.formGroup}>
          <TextField 
            label="Warning timeout length" 
            variant="outlined"
            onChange={handleWarningLengthChange}
            value={warning_length}
            className={classes.formTextField}
            placeholder="30"
            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
            InputLabelProps={{ shrink: true }}
            InputProps={{
              endAdornment: <InputAdornment position="end">secs.</InputAdornment>
            }}
          />
          <FormControlLabel control={<Checkbox onChange={handleWarningChange} checked={warning} color="primary" />} 
            label="Enabled"
            className={classes.checkboxLabel}
          />
        </div>
      </div>
      <Divider/>
      <div className={classes.formFooter}>
        <Button onClick={handleSubmit} color="primary" variant="text" disableElevation>Edit filter</Button>
      </div>
    </React.Fragment>
  )
}
// TODO: make checkbox labels more intuitive
