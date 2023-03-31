import React from "react";
import { makeStyles } from '@material-ui/core/styles';
import styled from 'styled-components';


const Bar = styled.div`
  width: ${props => props.completed || 0}%;
`;

const useStyles = makeStyles((theme) => ({
  containerStyles: {
    height: '6px',
    width: '100%',
    backgroundColor: theme.palette.background.paper,
    borderRadius: '6px',
  },
  fillerStyles: {
    height: '100%',
    backgroundColor: theme.palette.background.paperLight,
    borderRadius: 'inherit',
    textAlign: 'right',
    transition: 'width 0.2s ease-in-out',
  },
}));

const ProgressBar = (props) => {
  const classes = useStyles()
  const { completed } = props
  return (
    <div className={classes.containerStyles}>
      <Bar className={classes.fillerStyles} completed={completed}></Bar>
    </div>
  );
};

export default ProgressBar;
