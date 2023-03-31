import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { connect } from 'react-redux'
import { AppBar, Toolbar, Typography, IconButton, ListItemText, ListItemIcon, ListItemAvatar, Avatar, Button, Menu, MenuItem, Divider } from '@material-ui/core';
import MenuIcon from '@material-ui/icons/Menu';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';
import { navigate } from "@reach/router"
import { SIDEBAR_WIDTH } from '../../pages/dashboard/constants'
import { deleteUser, deleteToken, deleteBot } from '../../actions'

const drawerWidth = SIDEBAR_WIDTH;

const useStyles = makeStyles((theme) => ({
  appBar: {
    [theme.breakpoints.up('sm')]: {
      width: `calc(100% - ${drawerWidth}px)`,
      marginLeft: drawerWidth,
    },
  },
  navBar: {
    display: 'flex',
    justifyContent: 'space-between',
    backgroundColor: theme.palette.primary.main,
    [theme.breakpoints.up('sm')]: {
      justifyContent: 'flex-end'
    }
  },
  menuButton: {
    marginRight: theme.spacing(2),
    [theme.breakpoints.up('sm')]: {
      display: 'none',
    },
  },
  dropdownButton: {
    textTransform: "initial"
  },
  img: {
    borderRadius: '50%',
    width: '24px',
    height: '24px',
    marginRight: theme.spacing(1)
  },
  dropdown: {
    borderRadius: 0,
    backgroundColor: theme.palette.background.paperLight,
  },
  divider: {
    marginTop: theme.spacing(1),
    marginBottom: theme.spacing(1)
  },
  dropdownAvatar: {
    width: '24px',
    height: '24px'
  }
}));


function Navbar(props) {
  const classes = useStyles();
  const {handleDrawerToggle, user, deleteUser, deleteToken, deleteBot} = props
  const [anchorEl, setAnchorEl] = React.useState(null);

  function handleClick(event) {
    setAnchorEl(event.currentTarget);
  };

  function handleClose() {
    setAnchorEl(null);
  };
  function logout() {
    navigate('/', { replace: true })
    deleteUser()
    deleteToken()
    deleteBot()
  }

  return (
    <AppBar position="fixed" className={classes.appBar}>
      <Toolbar variant="dense" className={classes.navBar}>
        <IconButton
          color="inherit"
          aria-label="open drawer"
          edge="start"
          onClick={handleDrawerToggle}
          className={classes.menuButton}
        >
          <MenuIcon />
        </IconButton>
        <Button onClick={handleClick} className={classes.dropdownButton}>
          <img className={classes.img} alt="profile" src={user.profile_image_url}/>
          <Typography display="inline" variant="body1" noWrap>
            {user.display_name}
          </Typography>
        </Button>
        <Menu
          classes={{
            list: classes.dropdownList,
            paper: classes.dropdown
          }}
          anchorEl={anchorEl}
          keepMounted
          open={Boolean(anchorEl)}
          onClose={handleClose}
          elevation={0}
          getContentAnchorEl={null}
          anchorOrigin={{
            vertical: 'bottom',
            horizontal: 'center',
          }}
          transformOrigin={{
            vertical: 'top',
            horizontal: 'center',
          }}
        >
          <MenuItem onClick={handleClose}>
            <ListItemAvatar>
              <Avatar className={classes.dropdownAvatar} alt="profile" src={user.profile_image_url} />
            </ListItemAvatar>
            <ListItemText>
              Account Name 1
            </ListItemText>
          </MenuItem>
          <MenuItem onClick={handleClose}>
            <ListItemAvatar>
              <Avatar className={classes.dropdownAvatar} alt="profile" src={user.profile_image_url} />
            </ListItemAvatar>
            <ListItemText>
              Long Account Name 2
            </ListItemText>
          </MenuItem>
          {/* accounts I can manage minus selected, logout */}
          <Divider className={classes.divider}/>
          <MenuItem onClick={logout}>
            <ListItemIcon>
              <ExitToAppIcon/>
            </ListItemIcon>
            <ListItemText>
              Logout
            </ListItemText>
          </MenuItem>
        </Menu>
      </Toolbar>
    </AppBar>
  )
}

const mapStateToProps = state => ({
  user: state.user,
})

export default connect(mapStateToProps, { deleteUser, deleteToken, deleteBot })(Navbar)
