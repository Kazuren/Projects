const mongoose = require('mongoose')
const Schema = mongoose.Schema

var EmailHistorySchema = new Schema({
  name: { type: String },
  domain: { type: String, required: true, index: { unique: true } },
  emails: { type: [String], required: true },
  page: { type: Number, required: true }
}, { timestamps: true });


module.exports = mongoose.model('EmailHistory', EmailHistorySchema);