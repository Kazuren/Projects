const mongoose = require('mongoose')
const Schema = mongoose.Schema

var EmailTaskSchema = new Schema({
  query: { type: String, required: true },
  status: { type: String, required: true },
  error: { type: String }
}, { timestamps: true });


module.exports = mongoose.model('EmailTask', EmailTaskSchema);