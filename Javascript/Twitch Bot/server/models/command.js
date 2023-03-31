const mongoose = require('mongoose')
const Schema = mongoose.Schema

const commandSchema = new Schema({
  bot_id: {
    type: String,
    required: true
  },
  count: {
    type: Number,
    required: true,
    default: 0
  },
  name: {
    type: String,
    required: true
  },
  response: {
    type: String,
    required: true
  },
  enabled: {
    type: Boolean,
    required: true,
    default: true
  },
  user_cooldown: {
    type: Number,
    required: true,
    default: 15
  },
  global_cooldown: {
    type: Number,
    required: true,
    default: 5
  },
  command_mode: {
    type: String,
    required: true,
    default: 'Online and Offline'
  },
  userlevel: {
    type: String,
    required: true,
    default: 'Everyone'
  }
}, { timestamps: true })

commandSchema.index({ bot_id: 1, name: 1 }, { unique: true })

const Command = mongoose.model('Command', commandSchema)

module.exports = Command
