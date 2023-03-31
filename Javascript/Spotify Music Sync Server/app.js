require('dotenv').config();

const http = require('http')
const morgan = require('morgan')
const helmet = require('helmet')
const mongoose = require('mongoose')
const cors = require('cors')
const express = require('express');
const WebSocket = require('ws')

const api = require('./routes/api')

const HostManager = require('./managers/HostManager')

let corsOptions = {
  origin: process.env.CORS_ORIGIN,
  optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
}

// express app
const app = express()

// connect to mongodb
const dbURI = process.env.DB_URI

app.use(express.json())
app.use(helmet())
app.use(cors())
app.use(morgan('dev'))


app.use('/api', api)


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

  const server = http.createServer(app);

  const wss = new WebSocket.Server({ server: server })
  await HostManager.setup(wss)

  server.listen(process.env.HTTP_PORT)
})();
