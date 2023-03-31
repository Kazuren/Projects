const axios = require('axios')
const fs = require('fs')
const { DateTime } = require('luxon')

async function validateUser(token) {
  const response = await axios.get('https://id.twitch.tv/oauth2/validate', {
    headers: { Authorization: `OAuth ${token}` }
  })
  return response.data
}

async function getAppAccessToken() {
  const response = await axios.post('https://id.twitch.tv/oauth2/token',
    {},
    {
      params: {
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        grant_type: "client_credentials",
        scope: "channel:read:subscriptions bits:read channel:moderate channel:read:redemptions channel:manage:redemptions channel:read:hype_train user:read:email"
      }
    }
  )
  return response.data
}

async function createSub(token, bot, subtype) {
  try {
    const response = await axios.post('https://api.twitch.tv/helix/eventsub/subscriptions',
      {
        type: subtype,
        version: "1",
        condition: {
          broadcaster_user_id: bot.user_id
        },
        transport: {
          method: "webhook",
          callback: `${process.env.HOST_URL}/webhooks/eventsub`,
          secret: process.env.EVENTSUB_SECRET
        }
      },
      {
        headers: {
          'Client-ID': process.env.CLIENT_ID,
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    )
    console.log(response.data)
  } catch (err) {
    console.log(err)
  }
}

async function getDirectoriesAsync(source, options) {
  return new Promise((resolve, reject) => {
    return fs.readdir(source, 
      { withFileTypes: true }, 
      (err, files) => {
        if (err) { reject (err) }
        else {
          resolve(files
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name)
          )
        }
      })
  })
}

async function getFilesAsync(source, options) {
  return new Promise((resolve, reject) => {
    return fs.readdir(source, 
      { withFileTypes: true }, 
      (err, files) => {
        if (err) { reject (err) }
        else {
          resolve(files
            .filter(dirent => dirent.isFile())
            .map(dirent => dirent.name)
          )
        }
      })
  })
}

function getDirectories(source) {
  return fs.readdirSync(source, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name)
}

function getFiles(source) {
  return fs.readdirSync(source, { withFileTypes: true })
    .filter(dirent => dirent.isFile())
    .map(dirent => dirent.name)
}

function roundCurrentTime() {
  let date = DateTime.local()
  return date.set({second: 0, millisecond: 0})
}

// only works for intervals that are less than one day
function createDueDate(interval) {
  if (interval < 1) {
    return
  }

  let due_date = DateTime.fromObject({hour: 0}) // , zone: 'utc'
  const now = roundCurrentTime()
  
  while(due_date <= now) {
    due_date = due_date.plus({ minutes: interval })
  }
  return due_date
}

class Queue {
  constructor() {
    this.elements = []
  }
  enqueue(e) {
    this.elements.push(e)
  }
  dequeue() {
    return this.elements.shift()
  }
  isEmpty() {
    return this.elements.length === 0
  }
  peek() {
    return !this.isEmpty() ? this.elements[0] : undefined
  }
  length() {
    return this.elements.length
  }
  includes(e) {
    return this.elements.includes(e)
  }
  indexOf(e) {
    return this.elements.indexOf(e)
  }
  remove(index) {
    return this.elements.splice(index, 1)
  }
}

module.exports = { validateUser, getAppAccessToken, createSub, getDirectories, getDirectoriesAsync, getFiles, getFilesAsync, createDueDate, roundCurrentTime, Queue}
