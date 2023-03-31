const scheduler = require('node-schedule');
const Bot = require('./models/bot')
const Command = require('./models/command')
const Filter = require('./models/filter')
const { DateTime, Duration } = require('luxon')
const { getAppAccessToken, createSub, createDueDate, roundCurrentTime, Queue } = require('./helpers')

function isUnique(arr) {
  return arr.length === new Set(arr).size;
}

function getUniqueReferences(command) {
  const commands = []
  let regex = /\$\((.*?)\)/g;
  let found_variables = [];
  let found;
  while (found = regex.exec(command.response)) {
    found_variables.push(found[1])
  }

  for (const _var of found_variables) {
    const [name, command] = _var.split(' ')
    if (name === "references") {
      commands.push(`!${command.replace(/^!/g, '')}`)
    }
  }
  return [...new Set(commands)]
}

function containsCircularReference(commands, ref, refs=[ref]) {
  const command = commands.find(command => command.name === refs[refs.length - 1]);
  const pointers = getUniqueReferences(command)
  if (!isUnique(refs)) {
    return true
  }
  if (pointers.length === 0) {
    return !isUnique(refs)
  }
  for (const pointer of pointers) {
    return containsCircularReference(commands, refs[refs.length - 1], [...refs, pointer])
  }

  return false
}

// create a command manager for each client? PepoThink
class CommandManager {
  constructor() {
    this.commands = {}
    this.cooldowns = {}
  }
  async fetchCommands() {
    const commands = await Command.find().exec()
    commands.forEach(command => {
      this.addCommand(command)
    })
    return this.commands
  }
  getCommands() {
    return this.commands
  }
  addCommand(command) {
    if (typeof this.commands[command.bot_id] === 'undefined') {
      this.commands[command.bot_id] = {}
    }

    this.commands[command.bot_id][command._id] = command
  }
  removeCommand(bot_id, id) {
    delete this.commands[bot_id][id]
  }

  async parseResponse(response, data, args, checkReferences=true) {
    const variables = [
      {name: 'references', params: true, func: async (name, ref) => {
        const commands = Object.values(this.commands[data.userstate['room-id']])
        ref = `!${ref.replace(/^!/g, '')}`
        for (const command of commands) {
          if (command.name === ref) {
            if (checkReferences) {
              if (containsCircularReference(commands, ref)) {
                return undefined
              }
            }
            const response = await this.parseResponse(command.response, data, args, false)
            return response
          }
        }
      }},
      {text: '$(channel)', data: data.channel.replace(/^#/g, '')},
      {text: '$(user)', func: () => {
        if (args[1]) {
          return args[1]
        }
        return data.userstate['display-name']
      }},
      {text: '$(sender)', data: data.userstate['display-name']},
      {text: '$(addcommand)', func: async () => {
        if (!args[1] || !args[2]) {
          return `Usage: ${args[0]} <command> <response>`
        }

        const command_name = `!${args[1].replace(/^!/g, '')}`
        const command_response = args.slice(2).join(' ')
        
        const _command = new Command({
          bot_id: data.userstate['room-id'],
          name: command_name,
          response: command_response
        })
        try {
          const command = await _command.save()
          this.addCommand(command)
          return `added command "${command_name}"`
        } catch (err) {
          if (err.code === 11000) 
            return 'command already exists'
          else
            return 'an error occured, try again later.'
        }
      }},
      {text: '$(editcommand)', func: async () => {
        if (!args[1] || !args[2]) {
          return `Usage: ${args[0]} <command> <response>`
        }
        const command_name = `!${args[1].replace(/^!/g, '')}`
        const command_response = args.slice(2).join(' ')

        try { 
          const command = await Command.findOneAndUpdate({ 
            bot_id: data.userstate['room-id'], 
            name: command_name
          }, { response: command_response }, { new: true }).exec()
          if(!command) {
            return 'command does not exist'
          }
          this.addCommand(command)
          return `edited command "${command_name}"`
        } catch (err) {
          return 'an error occured, try again later.'
        }
      }},
      {text: '$(deletecommand)', func: async () => {
        if (!args[1]) {
          return `Usage: ${args[0]} <command>`
        }
        const command_name = `!${args[1].replace(/^!/g, '')}`

        try {
          const command = await Command.findOneAndDelete({
            bot_id: data.userstate['room-id'],
            name: command_name
          }).exec()
          if(!command) {
            return 'command does not exist'
          }
          this.removeCommand(command.bot_id, command._id)
          return `deleted command "${command_name}"`
        } catch (err) {
          return 'an error occured, try again later.'
        }
      }},
      {text: '$(0)', data: args[0]},
      {text: '$(1)', data: args[1] || ''},
      {text: '$(2)', data: args[2] || ''},
      {text: '$(3)', data: args[3] || ''},
      {text: '$(4)', data: args[4] || ''},
      {text: '$(5)', data: args[5] || ''},
      {text: '$(6)', data: args[6] || ''},
      {text: '$(7)', data: args[7] || ''},
      {text: '$(8)', data: args[8] || ''},
      {text: '$(9)', data: args[9] || ''},
    ]

    let parsed_response = response
    for (const variable of variables) {
      if (variable.params) {
        // catches $( anything in between )
        let regex = /\$\((.*?)\)/g;
        let found_variables = [];
        let found;
        while (found = regex.exec(parsed_response)) {
          found_variables.push(found[1])
        }
        for (const _var of found_variables) {
          const name = _var.split(' ')[0]
          if (variable.name === name) {
            const isAsync = variable.func.constructor.name === "AsyncFunction";
            if (isAsync) {
              const data = await variable.func(..._var.split(' '))
              parsed_response = parsed_response.replace(`$(${_var})`, data)
              continue
            }
            parsed_response = parsed_response.replace(`$(${_var})`, variable.func(..._var.split(' ')))
            continue
          }
        }
        continue
      }
      if (!parsed_response.includes(variable.text)) {
        continue
      }
      if (typeof variable.func !== 'undefined') {
        const isAsync = variable.func.constructor.name === "AsyncFunction";
        if (isAsync) {
          const data = await variable.func()
          parsed_response = parsed_response.replace(variable.text, data)
          continue
        }
        parsed_response = parsed_response.replace(variable.text, variable.func())
        continue
      }
      parsed_response = parsed_response.replace(variable.text, variable.data)
    }

    return parsed_response
  }
  addCooldown(bot_id, id, user, user_cooldown, global_cooldown) {
    if (typeof this.cooldowns[bot_id] === 'undefined') {
      this.cooldowns[bot_id] = {}
    }
    if (typeof this.cooldowns[bot_id][id] === 'undefined') {
      this.cooldowns[bot_id][id] = {global_cooldown: true}
    }
    this.cooldowns[bot_id][id].global_cooldown = true
    this.cooldowns[bot_id][id][user] = true

    setTimeout(() => {
      this.cooldowns[bot_id][id].global_cooldown = false
    }, global_cooldown * 1000)

    if (global_cooldown >= user_cooldown) {
      this.cooldowns[bot_id][id][user] = false
      return
    }

    setTimeout(() => {
      this.cooldowns[bot_id][id][user] = false
    }, user_cooldown * 1000)
  }
  onCooldown(bot_id, id, user) {
    // if the command doesn't exist in the cooldowns object then it hasn't been called once
    if (typeof this.cooldowns[bot_id] === 'undefined') {
      return false
    }
    if (typeof this.cooldowns[bot_id][id] === 'undefined') {
      return false
    }

    // if the user exists it means he has called the command before 
    // so we have to check if his cooldown has passed as well as the global cooldown
    if (typeof this.cooldowns[bot_id][id][user] !== 'undefined') {
      return this.cooldowns[bot_id][id].global_cooldown || this.cooldowns[bot_id][id][user]
    }


    // if the user doesn't exist yet then just check if the global cooldown has passed
    return this.cooldowns[bot_id][id].global_cooldown
  }
}

class BotManager {
  constructor() {
    this.bots = {}
  }

  async fetchBots() {
    // get app access token
    // const { access_token } = await getAppAccessToken()
    const bots = await Bot.find({ joined: true }).exec()
    bots.forEach(bot => {
      this.addBot(bot)
      // https://dev.twitch.tv/docs/eventsub
      // sub to stuff for the bot
      // get all subs
      // delete all not enabled subs
      // TODO: leave this for paid users and another purpose with maximum 10k users
      // createSub(access_token, bot, 'channel.update')
    })
    return this.bots
  }

  getBots() {
    return this.bots
  }

  addBot(bot) {
    this.bots[bot.user_id] = bot
  }
  removeBot(bot) {
    delete this.bots[bot.user_id]
  }
}

class TimerManager {
  constructor(command_manager) {
    this.timers = {}
    this.queues = {}
    this.command_manager = command_manager
  }
  async parseResponse(response, timer, checkReferences=true) {

    const variables = [
      {name: 'references', params: true, func: async (name, ref) => {
        const commands = Object.values(this.command_manager.getCommands()[timer.bot_id])
        ref = `!${ref.replace(/^!/g, '')}`
        for (const command of commands) {
          if (command.name === ref) {
            if (checkReferences) {
              if (containsCircularReference(commands, ref)) {
                return undefined
              }
            }
            const response = await this.parseResponse(command.response, timer, false)
            return response
          }
        }
      }},
      {text: '$(channel)', data: timer.bot.username},
    ]

    let parsed_response = response
    for (const variable of variables) {
      if (variable.params) {
        // catches $( anything in between )
        let regex = /\$\((.*?)\)/g;
        let found_variables = [];
        let found;
        while (found = regex.exec(parsed_response)) {
          found_variables.push(found[1])
        }
        for (const _var of found_variables) {
          const name = _var.split(' ')[0]
          if (variable.name === name) {
            const isAsync = variable.func.constructor.name === "AsyncFunction";
            if (isAsync) {
              const data = await variable.func(..._var.split(' '))
              parsed_response = parsed_response.replace(`$(${_var})`, data)
              continue
            }
            parsed_response = parsed_response.replace(`$(${_var})`, variable.func(..._var.split(' ')))
            continue
          }
        }
        continue
      }
      if (!parsed_response.includes(variable.text)) {
        continue
      }
      if (typeof variable.func !== 'undefined') {
        const isAsync = variable.func.constructor.name === "AsyncFunction";
        if (isAsync) {
          const data = await variable.func()
          parsed_response = parsed_response.replace(variable.text, data)
          continue
        }
        parsed_response = parsed_response.replace(variable.text, variable.func())
        continue
      }
      parsed_response = parsed_response.replace(variable.text, variable.data)
    }

    return parsed_response
  }

  async fetchTimers() {
    const bots = await Bot.aggregate([{
      $lookup: {
        from: 'timers',
        localField: 'user_id',
        foreignField: 'bot_id',
        as: 'timers'
      }
    }]).exec()

    bots.forEach(bot => {
      bot.timers.forEach(timer => {
        if (timer.enabled) {
          this.addTimer({...timer, bot: {username: bot.username}})
        }
      })
    })
    return this.timers
  }

  setup(client) {
    function compareDates(a, b) {
      const dateA = DateTime.fromISO(a.createdAt.toISOString())
      const dateB = DateTime.fromISO(b.createdAt.toISOString())
      if (dateA > dateB) {
        return 1
      }
      if (dateB > dateA) {
        return -1
      }
      return 0
    }

    this.timeout = scheduler.scheduleJob('*/1 * * * *', (fireDate) => {
      const now = roundCurrentTime()
      const users = Object.keys(this.timers)
      for (const user of users) {
        // sort the timers so they run in order of which they were created 
        // if they were to run on the same minute
        const queue = this.queues[user]
        const timers = Object.values(this.timers[user]).sort(compareDates)

        for (const timer of timers) {
          // queue all the timers that are due now
          const due_date = DateTime.fromISO(timer.due_date)
          if (due_date <= now) {
            // if timer not already in the queue then queue it
            if (!queue.includes(timer)) {
              queue.enqueue(timer)
            }
          }
        }
        if (!queue.isEmpty()) {
          const timer = queue.dequeue()
          this.runTimer(timer, client, queue)
        }
      }
    })
  }

  runTimer(timer, client, queue) {
    const now = roundCurrentTime().toSeconds()
    // Filter to only keep the last five minutes of messages
    const chat_lines = client.users[timer.bot.username].last_hundred_messages.filter(message => {
      return now - message < 300
    }).length

    if(chat_lines < timer.chat_lines) {
      // if there are not enough chat lines to run the timer then
      // check if there is another timer in the queue and try running that one
      // put this timer in the queue to try again in 1 min
      if (!queue.isEmpty()) {
        this.runTimer(queue.dequeue(), client, queue)
      }
      queue.enqueue(timer)
      return
    }

    // moves the due date to a later date
    this.addTimer(timer)

    void (async () => {
      const response = await this.parseResponse(timer.response, timer)
      client.say(`#${timer.bot.username}`, response)
    })();
  }

  addTimer(timer) {
    const _timer = {...timer, due_date: createDueDate(timer.interval).toISO()}
    if (typeof this.timers[timer.bot_id] === 'undefined') {
      this.timers[timer.bot_id] = {}
    }
    if (typeof this.queues[timer.bot_id] === 'undefined') {
      this.queues[timer.bot_id] = new Queue()
    }

    this.timers[timer.bot_id][timer._id] = _timer
  }
  removeTimer(bot_id, id) {
    if (this.timers[bot_id]) {
      if(this.timers[bot_id][id]) {

        const timer = this.timers[bot_id][id]

        const queue = this.queues[timer.bot_id]
        const index = queue.indexOf(timer)
        if (index > -1) {
          queue.remove(index, 1)
        }

        delete this.timers[bot_id][id]
      }
    }
  }
  editTimer(timer) {
    this.removeTimer(timer.bot_id, timer._id)

    if (timer.enabled) {
      this.addTimer(timer)
    }
  }
}

// TODO: 
// make a users object for each channel 
// to track for each user which commands 
// he has used and if they have a delay or not 
// and to check if the user has got a warning for each filter
// so we can give an actual timeout instead of a warning timeout

class BaseFilter {
  constructor(filter) {
    this.name = filter.name
    this.enabled = filter.enabled
    this.options = filter.options
    this.warning_length = 12 // in hours
    this.last_announcement = DateTime.fromMillis(0).toISO() // 1 January 1970 00:00:00 UTC
  }

  async timeout(client, channel, userstate, warning_manager) {
    try {
      const channel_name = channel.replace(/^#/g, '')
      const username = userstate.username
      const display_name = userstate['display-name']
      const botname = client.userstate[channel]['display-name']

      const warning_exists = this.options.warning ? warning_manager.has(username, channel_name, this.name) : true

      if (!warning_exists && this.options.warning) {
        const due_date = DateTime.local().plus({hours: this.warning_length}).toISO()
        warning_manager.addWarning(username, channel_name, this.name, due_date)
      }

      const length = warning_exists ? this.options.length : this.options.warning_length
      const reason = this.options.reason.replace('$(sender)', display_name)
      if (this.options.announce) {
        const now = DateTime.local()
        const last_announcement = DateTime.fromISO(this.last_announcement)
        const cooldown = Duration.fromObject({seconds: this.options.cooldown})
        if (last_announcement.plus(cooldown) <= now) {
          this.last_announcement = now.toISO()
          await client.say(channel, `${reason}${!warning_exists ? " [warning]" : ""}`)
        }
      }
      await client.timeout(channel, username, length, `${reason}${!warning_exists ? " [warning]" : ""} - automated by ${botname}`)
      return true
    } catch (err) {
      console.log(err)
    }
  }

  async onMessage(client, channel, userstate, msg, warning_manager) {
    const isBroadcaster = userstate.badges !== null && 'broadcaster' in userstate.badges
    const isSubscriber = userstate.badges !== null && 'subscriber' in userstate.badges
    const isVIP = userstate.badges !== null && 'vip' in userstate.badges
    const isModerator = userstate.badges !== null && 'moderator' in userstate.badges

    switch (this.name) {
      // IF A FILTER ENDS UP TIMING OUT SOMEONE 
      // THEN WE DONT HAVE TO GO THROUGH THE REST OF THE FILTERS
      // iterating max of 10 times for each message? yikes
      case "caps":
        const message_length = msg.length // ?: maybe don't count spaces? check how fossabot & nightbot do it
        const uppercase_characters = msg.replace(/[^A-Z]/g, '').length

        // if user matches the exempt userlevel; break
        if (isSubscriber && this.options.userlevel === 'subscriber') { break }
        if (isVIP && this.options.userlevel === 'vip') { break }
        if (isBroadcaster || isModerator) { break }

        if (message_length < this.options.minimum) { break }
        if (this.options.mode === 'static') {
          if (uppercase_characters <= this.options.number) { break }

          const success = await this.timeout(client, channel, userstate, warning_manager)
          return success
        } else {
          const percentage = uppercase_characters / message_length * 100
          if (percentage < this.options.number) { break }

          const success = await this.timeout(client, channel, userstate, warning_manager)
          return success
        }
      case "links":
      case "clips":
      case "emotes":
      case "length": // possibly useless?
      case "repetition":
      case "symbol":
      case "actions":
      case "spam":
      case "zalgo":
      default:
        break
    }
  }
}

class FilterManager {
  constructor() {
    this.filters = {}
  }

  async createDefaultFilters(bot_id, filters=[]) {
    // filters = Array with all the existing filters
    // create each filter if it doesn't exist so for example
    // if 'caps' not in filters then create it and save it
    if (!filters.includes('caps')) {
      const capsFilter = new Filter({
        bot_id: bot_id,
        display_name: 'Caps Filter', // could probably hard code this in client
        description: 'Timeout users for excessive use of capital letters', // could probably hard code this in client
        name: 'caps',
        enabled: false,
        options: {
          // Filter settings
          mode: 'percentage', // 'static'
          minimum: 8,
          number: 90, // max caps allowed or max percentage allowed
  
          // Timeout options
          length: 600, // max = 86400
          reason: '$(sender), Please stop spamming caps.', // add [warning] at the end if it's a warning
          userlevel: 'moderator', // minimum required userlevel to be exempt for the filter [Moderator, VIP, Subscriber]
          // Announcement options
          announce: true,
          cooldown: 30, // max = 86400
          // Warning options
          warning: true,
          warning_length: 30 // max = 86400
        }
      })
      await capsFilter.save()
    }
  }

  async fetchFilters() {
    const filters = await Filter.find({ enabled: true }).exec()
    filters.forEach(filter => {
      this.addFilter(filter)
    })
    return this.filters
  }
  getFilters() {
    return this.filters
  }
  addFilter(filter) {
    if (typeof this.filters[filter.bot_id] === 'undefined') {
      this.filters[filter.bot_id] = {}
    }

    this.filters[filter.bot_id][filter._id] = new BaseFilter(filter)
  }
  removeFilter(bot_id, id) {
    if (this.filters[bot_id]) {
      if (this.filters[bot_id][id]) {
        delete this.filters[bot_id][id]
      }
    }
  }
  editFilter(filter) {
    this.removeFilter(filter.bot_id, filter._id)

    if (filter.enabled) {
      this.addFilter(filter)
    }
  }
}

class WarningManager {
  constructor() {
    // dummy data
    this.warnings = {
      'kazuren_': [
        {
          user: 'kekw',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 1}).toISO()
        },
        {
          user: 'kekw1',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 2}).toISO()
        },
        {
          user: 'kekw2',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 3}).toISO()
        },
        {
          user: 'kekw3',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 4}).toISO()
        },
      ],
      'kazurenbot': [
        {
          user: 'kekw',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 1}).toISO()
        },
        {
          user: 'kekw1',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 2}).toISO()
        },
        {
          user: 'kekw2',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 3}).toISO()
        },
        {
          user: 'kekw3',
          filter: 'caps',
          due_date: DateTime.local().plus({minutes: 4}).toISO()
        },
      ]
    }
  }

  addWarning(user, channel, filter, due_date) {
    if (typeof this.warnings[channel] === 'undefined') {
      this.warnings[channel] = {}
    }
    this.warnings[channel].push({user, filter, due_date})
  }

  has(user, channel, filter) {
    const warnings = this.warnings[channel]
    const warningIndex = warnings.findIndex(warning => {
      return warning.user === user && warning.filter === filter
    })

    if (warningIndex === -1) {
      return false
    }

    const warning = warnings[warningIndex]

    const now = DateTime.local()
    const due_date = DateTime.fromISO(warning.due_date)
    // if warning is due
    if (due_date <= now) {
      // delete warning
      this.warnings[channel] = this.warnings[channel].filter((warning, index) => index !== warningIndex)
      return false
    }

    return true
  }

  setup() {
    // ? Doing it this way leads to warnings lasting up to 59.99 seconds more in memory
    // example: warning is due at 15min & 1 seconds, 
    // you check at 15 min if it's due and it's not
    // and you check at 16 min and it's due
    // but that's fixed by checking if the due date has passed anyways 
    // when we check if the user has a warning
    this.timeout = scheduler.scheduleJob('*/1 * * * *', (fireDate) => {
      const now = roundCurrentTime()

      for (const [channel, warnings] of Object.entries(this.warnings)) {
        let start = 0
        let end = warnings.length - 1
        let first_not_due_date_index = 1
        // binary search to find first date in the array that is not due
        while (start <= end) {
          let mid = Math.floor((start + end) / 2)
          const due_date = DateTime.fromISO(warnings[mid].due_date)

          // if due_date is due
          if (due_date <= now) {
            // check right half
            start = mid + 1
          } else {
            // check left half
            // save due date
            first_not_due_date_index = mid
            end = mid - 1
          }
        }
        // remove the warnings that have passed the due date
        this.warnings[channel] = this.warnings[channel].slice(first_not_due_date_index)
      }
    })
  }
}

class CooldownManager {
  constructor() {
    this.users = {}
  }
}

const command_manager = new CommandManager()

module.exports = { 
  BotManager: new BotManager(), 
  CommandManager: command_manager,
  TimerManager: new TimerManager(command_manager),
  FilterManager: new FilterManager(),
  WarningManager: new WarningManager()
}
