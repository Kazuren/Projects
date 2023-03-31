require('dotenv').config();
const path = require('path');
const morgan = require('morgan')
const helmet = require('helmet')
const mongoose = require('mongoose')
const cors = require('cors')
const express = require('express');

const api = require('./routes/api')
//const webhooks = require('./routes/webhooks')


// express app
const app = express()
// connect to mongodb
const dbURI = process.env.DB_URI

const PORT = process.env.PORT || 3001;

app.use(express.json())
app.use(helmet())
app.use(morgan('dev'))

//app.use('/webhooks', webhooks)

// Have Node serve the files for our built React app
app.use(express.static(path.resolve(__dirname, '../client/build')));

// Handle requests to /api route
app.use('/api', api)

// All other GET requests not handled before will return our React app
app.get('*', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../client/build', 'index.html'));
});

app.use((req, res, next) => {
  res.status(404).end()
})

void (async () => {
  await mongoose.connect(dbURI)

  app.listen(PORT)
})();
