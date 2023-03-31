const mongoose = require('mongoose')
const Schema = mongoose.Schema

const botSchema = new Schema({
  user_id: {
    type: String,
    required: true,
    unique: true
  },
  username: {
    type: String,
    required: true,
  },
  joined: {
    type: Boolean,
    default: false,
    required: true
  },

}, { timestamps: true })

const Bot = mongoose.model('Bot', botSchema)

module.exports = Bot

// commands
// timers
// blacklisted words(can be regex)
