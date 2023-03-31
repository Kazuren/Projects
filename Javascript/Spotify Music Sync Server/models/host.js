const mongoose = require('mongoose')
const Schema = mongoose.Schema

const hostSchema = new Schema({
  user_id: {
    type: String,
    required: true,
    unique: true
  },
  username: {
    type: String,
    required: true
  },
  access_token: {
    type: String,
    required: true
  },
  refresh_token: {
    type: String,
    required: true
  }

}, { timestamps: true })

const Host = mongoose.model('Host', hostSchema)

module.exports = Host
