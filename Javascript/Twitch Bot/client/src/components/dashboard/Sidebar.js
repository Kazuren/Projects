import React from 'react';
import { makeStyles, useTheme } from '@material-ui/core/styles';
import { Link, Toolbar, Typography, Drawer, List, ListItem, ListItemIcon, ListItemText, Hidden} from '@material-ui/core';
import { Link as RouterLink } from '@reach/router'
import { SIDEBAR_WIDTH } from '../../pages/dashboard/constants'

const drawerWidth = SIDEBAR_WIDTH;

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
  },
  drawer: {
    [theme.breakpoints.up('sm')]: {
      width: drawerWidth,
      flexShrink: 0,
    },
  },
  toolbar: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: theme.palette.primary.dark,
  },
  drawerPaper: {
    width: drawerWidth,
    borderRight: 'none',
    backgroundColor: theme.palette.background.paperLight
  },
  logoname: {
    fontWeight: 800,
    letterSpacing: 1,
    color: theme.palette.secondary.main
  },
  logobot: {
    fontWeight: 800,
    letterSpacing: 1,
    color: theme.palette.text.primary
  }
}));


export default function Sidebar(props) {
  const { window, mobileOpen, handleDrawerToggle, routes, path } = props;
  const classes = useStyles();
  const theme = useTheme();

  const drawer = (
    <div>
      <Toolbar variant="dense" className={classes.toolbar}>
        <Typography className={classes.logoname} display="inline" variant="h5" noWrap>
          KAZU
        </Typography>
        <Typography className={classes.logobot} display="inline" variant="h5" noWrap>
          BOT
        </Typography>
      </Toolbar>
      <List disablePadding={true}>
        {routes.map((route, index) => (
          <Link key={route.path} component={RouterLink} to={route.path} underline="none" color="textPrimary">
            <ListItem selected={route.path === path} button key={route.name}>
              <ListItemIcon >{route.icon}</ListItemIcon>
              <ListItemText primary={route.name} />
            </ListItem>
          </Link>
        ))}
      </List>
    </div>
  );

  const container = window !== undefined ? () => window().document.body : undefined;

  return (
    <React.Fragment>
      <nav className={classes.drawer} aria-label="mailbox folders">
        {/* The implementation can be swapped with js to avoid SEO duplication of links. */}
        <Hidden smUp implementation="js">
          <Drawer
            container={container}
            variant="temporary"
            anchor={theme.direction === 'rtl' ? 'right' : 'left'}
            open={mobileOpen}
            onClose={handleDrawerToggle}
            classes={{
              paper: classes.drawerPaper,
            }}
            ModalProps={{
              keepMounted: true, // Better open performance on mobile.
            }}
          >
            {drawer}
          </Drawer>
        </Hidden>
        <Hidden xsDown implementation="js">
          <Drawer
            classes={{
              paper: classes.drawerPaper,
            }}
            variant="permanent"
            open
          >
            {drawer}
          </Drawer>
        </Hidden>
      </nav>
    </React.Fragment>
  )
}
