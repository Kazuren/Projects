const mongoose = require('mongoose')
const Schema = mongoose.Schema

const filterSchema = new Schema({
  bot_id: {
    type: String,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  display_name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  enabled: {
    type: Boolean,
    required: true,
    default: false
  },
  options: {
    type: Object,
    required: true
  }
})

filterSchema.index({ bot_id: 1, name: 1 }, { unique: true })

const Filter = mongoose.model('Filter', filterSchema)

module.exports = Filter
