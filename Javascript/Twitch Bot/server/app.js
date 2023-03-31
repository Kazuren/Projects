require('dotenv').config();

const morgan = require('morgan')
const helmet = require('helmet')
const mongoose = require('mongoose')
const cors = require('cors')
const express = require('express');

const api = require('./routes/api')
//const webhooks = require('./routes/webhooks')

const client = require('./client')
const { BotManager, CommandManager, TimerManager, FilterManager, WarningManager } = require('./managers');


let corsOptions = {
  origin: 'http://localhost:3000',
  optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
}

// express app
const app = express()

// connect to mongodb
const dbURI = 'mongodb+srv://kazuren:L9fPQF3dkc4brcNh@kazubot.vza1u.mongodb.net/kazubot?retryWrites=true&w=majority'

app.use(express.json())
app.use(helmet())
app.use(cors(corsOptions))
app.use(morgan('dev'))

app.use('/api', api)

//app.use('/webhooks', webhooks)

app.use((req, res, next) => {
  res.status(404).end()
})

void (async () => {
  await mongoose.connect(dbURI, {
    useNewUrlParser: true, 
    useUnifiedTopology: true,
    useCreateIndex: true,
    useFindAndModify: false
  })

  const bots = await BotManager.fetchBots()
  const commands = await CommandManager.fetchCommands()
  const filters = await FilterManager.fetchFilters()
  await client.init(bots)
  // timers only active after client is ready
  const timers = await TimerManager.fetchTimers()
  TimerManager.setup(client)
  WarningManager.setup()

  app.listen(5000)

})();
