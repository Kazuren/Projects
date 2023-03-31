const mongoose = require('mongoose')
const Schema = mongoose.Schema

var EmailTemplateSchema = new Schema({
  name: { type: String, required: true, index: { unique: true } },
  subject: { type: String, required: true },
  loaded: { type: Boolean, default: false }
});


module.exports = mongoose.model('EmailTemplate', EmailTemplateSchema);