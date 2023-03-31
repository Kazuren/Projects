const mongoose = require('mongoose')
const Schema = mongoose.Schema

var EmailTokenSchema = new Schema({
  email: { type: String, required: true },
  token: { type: Object, required: true }
});


module.exports = mongoose.model('EmailToken', EmailTokenSchema);