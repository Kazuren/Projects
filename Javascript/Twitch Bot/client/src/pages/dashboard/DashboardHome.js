import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import JoinChannelButton from '../../components/dashboard/JoinChannelButton'

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));


export default function DashboardHome(props) {
  const classes = useStyles();
  return (
    <div className={classes.root}>
      <JoinChannelButton/>
    </div>
  )
}
