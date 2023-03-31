const tmi = require('tmi.js')
const ChatLogger = require('./ChatLogger')
const { CommandManager, FilterManager, WarningManager } = require('./managers')
const { DateTime, Duration } = require('luxon');

const client = new tmi.client({
  identity: {
    username: 'kazubot',
    password: process.env.OAUTH_TOKEN,
  },
  options: {
    debug: true
  },
  channels: []
});

client.createBot = bot => {
  client.users[bot.username] = {
    last_hundred_messages: []
  }
}

client.deleteBot = bot => {
  delete client.users[bot.username]
}

client.init = async (bots) => {
  client.users = {}

  Object.values(bots).forEach(async bot => {
    try {
      const data = await client.join(bot.username)
      client.createBot(bot)
      console.log(data)
      ChatLogger.addStream(bot.username)
    } catch (err) {
      // OK THIS ACTUALLY WORKS POGU
      // TODO: try reconnecting
      console.log("Error is:", err)
    }
  })
}

client.on('chat', (channel, userstate, message, self) => {
  // remove the "#" from variable channel so it matches username
  const channel_name = channel.replace(/^#/g, '')
  if(!self) {
    // If not a bot message then keep its timestamp in an array
    const duration = Duration.fromMillis(userstate['tmi-sent-ts']).as('seconds')

    // keep track of the last hundred messages to calculate messages in the last five minutes
    let messages = client.users[channel_name].last_hundred_messages

    if (messages.length >= 100) {
      messages.shift()
    }
    messages.push(duration)

    client.users[channel_name].last_hundred_messages = messages

    const commands = CommandManager.getCommands()[userstate['room-id']] || {}
    Object.values(commands).some(command => {
      const args = message.split(" ")
      if (command.name === args[0].toLowerCase()) {
        const isBroadcaster = userstate.badges !== null && 'broadcaster' in userstate.badges
        const isSubscriber = userstate.badges !== null && 'subscriber' in userstate.badges
        const isVIP = userstate.badges !== null && 'vip' in userstate.badges
        const isModerator = userstate.badges !== null && 'moderator' in userstate.badges

        if (!isBroadcaster && CommandManager.onCooldown(command.bot_id, command._id, userstate.username)) {
          // client.say(channel, 'Command is on cooldown Okayga')
          return true
        }
        void (async () => {
          const response = await CommandManager.parseResponse(command.response, {channel, userstate, message}, args)
          client.say(channel, response)
          //TODO: maybe change later and add cooldown anyways?
          if (!isBroadcaster) // if it is the broadcaster DONT add cooldown
            CommandManager.addCooldown(command.bot_id, command._id, userstate.username, command.user_cooldown, command.global_cooldown)
        })();

        return true
      }
    })


    const filters = FilterManager.getFilters()[userstate['room-id']] || {}
    // for each filter run its "onMessage()" func
    // and if the filter times out the user then skip the rest of the filters
    void (async () => {
      try {
        for (const filter of Object.values(filters)) {
          const success = await filter.onMessage(client, channel, userstate, message, WarningManager)
          if (success) { break }
        }
      } catch (err) {
        console.log(err)
      }
    })();
  }

  // fix this to use Luxon(DateTime) and have a better format
  const time = userstate['tmi-sent-ts'] ? new Date(parseInt(userstate['tmi-sent-ts'])) : new Date()// new Date(parseInt(userstate['tmi-sent-ts']))

  ChatLogger.write(channel_name, `[${time}] ${userstate['display-name']}: ${message}\n`)
});

client.on('connected', (address, port) => {
  console.log(address, port)
});

client.on('disconnected', (reason) => {
  console.log(reason)
});

client.on('roomstate', (channel, state) => {
  // console.log(channel, state)
})

client.connect();

module.exports = client
