import React from 'react';
import { connect } from 'react-redux';
import { joinChannel, partChannel } from '../../actions'
import { Button } from '@material-ui/core';

function JoinChannelButton({ token, bot, joinChannel, partChannel}) {
  async function handleJoin(e) {
    bot.joined ? await partChannel(token) : await joinChannel(token)
  }

  const color = bot.joined ? 'secondary' : 'primary'
  return (
    <Button onClick={handleJoin} size='medium' color={color} variant="outlined" disableElevation>
      { bot.joined ? 'Part Channel' : 'Join Channel'}
    </Button>
  )
}

const mapStateToProps = state => ({
  token: state.token,
  bot: state.bot
})

export default connect(mapStateToProps, { joinChannel, partChannel })(JoinChannelButton)
