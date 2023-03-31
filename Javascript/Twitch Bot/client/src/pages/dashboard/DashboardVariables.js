import React from 'react';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {

  }
}));


export default function DashboardVariables(props) {
  const classes = useStyles();
  return (
    <div className={classes.root}>
    </div>
  )
}
