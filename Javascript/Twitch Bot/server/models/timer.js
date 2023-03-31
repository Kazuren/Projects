const mongoose = require('mongoose')
const Schema = mongoose.Schema

const timerSchema = new Schema({
  bot_id: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  response: {
    type: String,
    required: true
  },
  chat_lines: {
    type: Number,
    required: true,
    default: 10,
    min: 0
  },
  enabled: {
    type: Boolean,
    required: true,
    default: true
  },
  interval: {
    type: Number,
    min: 1,
    max: 1440,
    required: true
  }
}, { timestamps: true })

timerSchema.index({ bot_id: 1, name: 1 }, { unique: true })

const Timer = mongoose.model('Timer', timerSchema)

module.exports = Timer
