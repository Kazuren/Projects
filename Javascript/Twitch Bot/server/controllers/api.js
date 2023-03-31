const fs = require('fs')
const Bot = require('../models/bot')
const Command = require('../models/command')
const Timer = require('../models/timer')
const Filter = require('../models/filter')
const client = require('../client')
const ChatLogger = require('../ChatLogger')
const { BotManager, CommandManager, TimerManager, FilterManager } = require('../managers')


const { getFilesAsync, getDirectoriesAsync } = require('../helpers')

const bot_details = async (req, res, next) => {
  try {
    const bot = await Bot.findOne({ user_id: res.locals.user_id }).exec()
    // !: might need to create filters in another place or always get the bot_details on login and when creating the bot
    if (bot) {
      let filters = await Filter.find({ bot_id: res.locals.user_id }, 'name').lean().exec()
      // get only the names of the filters
      filters = filters.map(filter => filter.name)

      // pass existing filter names to filter manager and create the ones that don't exist
      FilterManager.createDefaultFilters(res.locals.user_id, filters)

      return res.status(200).json({success: true, bot: bot})
    }

    return res.status(404).json({success: false})
  } catch (err) {
    console.log(err)
  }
}

const bot_create = async (req, res, next) => {
  try {
    let bot = await Bot.findOne({ user_id: res.locals.user_id }).exec()

    if (bot) {
      return res.status(200).json({success: true, bot: bot})
    }

    bot = new Bot({
      user_id: res.locals.user_id,
      username: res.locals.username
    })
  
    const result = await bot.save()

    // create filters for the bot
    FilterManager.createDefaultFilters(res.locals.user_id)

  
    return res.status(200).json({success: true, bot: result})
  } catch (err) {
    console.log(err)
  }
}

const bot_join = async (req, res, next) => {
  try {
    const data = await client.join(res.locals.username)

    const bot = await Bot.findOneAndUpdate(
      { user_id: res.locals.user_id },
      { joined: true },
      {
        new: true
      }
    ).exec()

    BotManager.addBot(bot)
    ChatLogger.addStream(bot.username)
    client.createBot(bot)

    return res.status(200).json({success: true, bot: bot})
  } catch (err) {
    console.log(err)
  }
}

const bot_part = async (req, res, next) => {
  try {
    const data = await client.part(res.locals.username)

    const bot = await Bot.findOneAndUpdate(
      { user_id: res.locals.user_id },
      { joined: false },
      {
        new: true
      }
    ).exec()

    BotManager.removeBot(bot)
    ChatLogger.removeStream(bot.username)
    client.deleteBot(bot)

    return res.status(200).json({success: true, bot: bot})
  } catch (err) {
    console.log(err)
  }
}

const bot_change = async (req, res, next) => {
  try {
    const bot = await Bot.findOneAndUpdate(
      { user_id: res.locals.user_id },
      req.body,
      {
        new: true
      }
    ).exec()
  
    if (!bot) {
      return res.status(404).json({success: false})
    }
  
    return res.status(200).json({success: true, bot: bot})
  } catch (err) {
    console.log(err)
  }
}

const logs = async (req, res, next) => {
  try {
    let dirents = null
    let year = null
    let month = null
    let day = null
    const regex = /[^a-z0-9]/gi // sanitize input

    // sanitize user input
    if (req.params.year) { year = req.params.year.replace(regex, '_') }
    if (req.params.month) { month = req.params.month.replace(regex, '_') }
    if (req.params.day) { day = req.params.day.replace(regex, '_') }

    if (day) {
      console.log(day)
      //const file = `${year}-${month}-${day}.log`

      // Check if file exists
      await fs.promises.access(`./logs/${res.locals.username}/${year}/${month}/${day}.log`);

      // send file? stream file? // might need to be ../logs
      return res.status(200).sendFile(`./logs/${res.locals.username}/${year}/${month}/${day}.log`, { root: './'})

    } else if (month) {
      dirents = await getFilesAsync(`./logs/${res.locals.username}/${year}/${month}`)
    } else if (year) {
      dirents = await getDirectoriesAsync(`./logs/${res.locals.username}/${year}`)
    } else {
      dirents = await getDirectoriesAsync(`./logs/${res.locals.username}`)
    }
    return res.status(200).json({success: true, dirents: dirents})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
    // The check failed
  }
}

const commands = async (req, res, next) => {
  try {
    const commands = await Command.find({ bot_id: res.locals.user_id }).lean().exec()
    return res.status(200).json({success: true, commands: commands})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const commands_create = async (req, res, next) => {
  try {
    // lowercase the name and remove whitespace
    const _command = new Command({
      bot_id: res.locals.user_id,
      name: `!${req.body.name.replace(/\s/g, '').toLowerCase()}`,
      response: req.body.response,
      enabled: req.body.enabled,
      user_cooldown: req.body.userCooldown,
      global_cooldown: req.body.globalCooldown,
      command_mode: req.body.commandMode,
      userlevel: req.body.userlevel
    })

    const command = await _command.save()

    CommandManager.addCommand(command)
  
    return res.status(200).json({success: true, command: command})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const commands_delete = async (req, res, next) => {
  try {
    const ids = req.body.ids
    await Command.deleteMany({_id: ids}).exec()

    ids.forEach(id => {
      CommandManager.removeCommand(res.locals.user_id, id)
    })
    return res.status(200).json({success: true, command_ids: ids})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const commands_edit = async (req, res, next) => {
  try {
    const id = req.params.id
    // lowercase the name and remove whitespace
    const command = await Command.findByIdAndUpdate(id, {
      bot_id: res.locals.user_id,
      name: `!${req.body.name.replace(/\s/g, '').toLowerCase()}`,
      response: req.body.response,
      enabled: req.body.enabled,
      user_cooldown: req.body.userCooldown,
      global_cooldown: req.body.globalCooldown,
      command_mode: req.body.commandMode,
      userlevel: req.body.userlevel
    }, 
    {
      new: true,
      lean: true
    }).exec()

    CommandManager.addCommand(command)

    return res.status(200).json({success: true, command: command})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const timers = async (req, res, next) => {
  try {
    // lean because we only need the js object and not the mongoose document
    const timers = await Timer.find({ bot_id: res.locals.user_id }).lean().exec()
    return res.status(200).json({success: true, timers: timers})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const timers_create = async (req, res, next) => {
  try {
    const interval = Math.floor(Number(req.body.interval))
    const _timer = new Timer({
      bot_id: res.locals.user_id,
      name: req.body.name,
      response: req.body.response,
      chat_lines: req.body.chatLines,
      enabled: req.body.enabled,
      interval: interval
    })

    const timer = await _timer.save()

    // toObject because we only need the js object and not the mongoose document
    TimerManager.addTimer({...timer.toObject(), bot: {username: res.locals.username}})
  
    return res.status(200).json({success: true, timer: timer})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const timers_delete = async (req, res, next) => {
  try {
    const ids = req.body.ids
    await Timer.deleteMany({_id: ids}).exec()

    ids.forEach(id => {
      TimerManager.removeTimer(res.locals.user_id, id)
    })
    return res.status(200).json({success: true, timer_ids: ids})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const timers_edit = async (req, res, next) => {
  try {
    const id = req.params.id
    // lowercase the name
    const timer = await Timer.findByIdAndUpdate(id, {
      // bot_id: res.locals.user_id,
      name: req.body.name,
      response: req.body.response,
      chat_lines: req.body.chatLines,
      enabled: req.body.enabled,
      interval: Math.floor(Number(req.body.interval))
    }, 
    {
      new: true,
      lean: true
    }).exec()
    // lean because we only need the js object and not the mongoose document
    TimerManager.editTimer({...timer, bot: {username: res.locals.username}})

    return res.status(200).json({success: true, timer: timer})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const filters = async (req, res, next) => {
  try {
    const filters = await Filter.find({ bot_id: res.locals.user_id }).lean().exec()
    return res.status(200).json({success: true, filters: filters})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}

const filters_edit = async (req, res, next) => {
  try {
    // !: only allow editing of filters whose bot_id matches the user_id
    const id = req.params.id
    // lowercase the name
    // find by id AND bot_id
    const filter = await Filter.findByIdAndUpdate(id, {
      // bot_id: res.locals.user_id,
      enabled: req.body.enabled,
      options: req.body.options
    }, 
    {
      new: true,
      lean: true
    }).exec()
    // lean because we only need the js object and not the mongoose document
    FilterManager.editFilter(filter)

    return res.status(200).json({success: true, filter: filter})
  } catch (error) {
    return res.status(404).json({success: false, error: error})
  }
}


module.exports = {
  bot_details,
  bot_create,
  bot_join,
  bot_part,
  logs,
  commands,
  commands_create,
  commands_delete,
  commands_edit,
  timers,
  timers_create,
  timers_delete,
  timers_edit,
  filters,
  filters_edit
}
