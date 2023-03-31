import React, { useEffect } from 'react';
import { navigate } from "@reach/router"
import { connect } from 'react-redux'
import { Navbar, Sidebar } from '../../components/dashboard'
import { fetchUser } from '../../actions'
import { Paper, Toolbar } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import HomeIcon from '@material-ui/icons/Home';
import ChatIcon from '@material-ui/icons/Chat';
import StorageIcon from '@material-ui/icons/Storage';
import BlockIcon from '@material-ui/icons/Block';
import PageviewIcon from '@material-ui/icons/Pageview';
import ScheduleIcon from '@material-ui/icons/Schedule';
import NotesIcon from '@material-ui/icons/Notes';

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
  },
  content: {
    flexGrow: 1,
    padding: theme.spacing(3),
    minHeight: '100vh'
  },
}));


function Dashboard(props) {
  const [mobileOpen, setMobileOpen] = React.useState(false);

  const routes = [
    {name: 'Dashboard', path: '/dashboard', icon: <HomeIcon/>},
    {name: 'Commands', path: '/dashboard/commands', icon: <ChatIcon/>},
    {name: 'Timers', path: '/dashboard/timers', icon: <ScheduleIcon/>},
    {name: 'Filters', path: '/dashboard/filters', icon: <BlockIcon/>},
    {name: 'Keywords', path: '/dashboard/keywords', icon: <PageviewIcon/>},
    {name: 'Variables', path: '/dashboard/variables', icon: <NotesIcon/>},
    {name: 'Chat Logs', path: '/dashboard/logs', icon: <StorageIcon/>},
  ]

  function handleDrawerToggle() {
    setMobileOpen(!mobileOpen);
  };


  const {user, token, bot, fetchUser, children, location} = props
  const classes = useStyles();
  // if exists and is enabled then have button say => "Part Channel"
  // keep info in local storage to prevent unnecessary calls to api

  useEffect(() => {
    if (!(token && bot)) {
      navigate('/', { replace: true })
      return
    }
    if (!user) {
      fetchUser(token).then(success => {
        if (!success) { navigate('/', { replace: true }) }
      })
    }
    // React Hook useEffect has a missing dependency: 'user'.
    // Either include it or remove the dependency array  react-hooks/exhaustive-deps
    // eslint-disable-next-line
  }, [token, bot, fetchUser])

  return (
    <div className={classes.root}>
      {user ?
        <React.Fragment>
          <Navbar handleDrawerToggle={handleDrawerToggle}/>

          <Sidebar routes={routes} path={location.pathname} handleDrawerToggle={handleDrawerToggle} mobileOpen={mobileOpen}/>
          <Paper elevation={0} square className={classes.content}>
            <Toolbar variant="dense" />
            {children}
          </Paper>
        </React.Fragment> : null
      }
    </div>
  )
}

const mapStateToProps = state => ({
  user: state.user,
  token: state.token,
  bot: state.bot
})

export default connect(mapStateToProps, { fetchUser })(Dashboard)
