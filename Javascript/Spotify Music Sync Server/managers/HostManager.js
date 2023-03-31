const querystring = require('querystring')
const scheduler = require('node-schedule')
const axios = require('axios')
const WebSocket = require('ws')
const Host = require("../models/host")

class HostManager {
  constructor() {
    this.hosts = {}
    this.active_hosts = {}
    this.progress = 0
    this.duration = 0
    this.active = false
    this.progressInterval = null
    this.pinger = null
  }

  async fetchHosts() {
    const hosts = await Host.find().exec()
    hosts.forEach(host => {
      // refresh their tokens as well
      this.hosts[host.user_id] = host
    })

    for (const host of hosts) {
      await this.refreshToken(host)
    }
  }

  async pingHost(host) {
    // GET https://api.spotify.com/v1/me/player/currently-playing
    try {
      const response = await axios.get('https://api.spotify.com/v1/me/player/currently-playing', {
        headers: {
          'Authorization': `Bearer ${host.access_token}`
        }
      })
      if (response.status === 204) {
        return
      }

      if (response.status === 502) {
        console.log(response.status)
        return
      }

      const data = response.data
      const artists = data.item.artists.map(artist => {
        return artist.name
      })

      let image = null
      if (data && data.item && data.item.album && data.item.album.images && data.item.album.images.length > 0) {
        image = data.item.album.images[data.item.album.images.length - 1]
      }

      this.active_hosts[host.user_id] = {
        active: data.is_playing,
        album: data.item.album.name,
        song: data.item.name,
        progress: data.progress_ms,
        duration: data.item.duration_ms,
        artists: artists,
        uri: data.item.uri,
        image: image
      }

      this.progress = data.progress_ms
      this.duration = data.item.duration_ms
      this.active = data.is_playing

      clearInterval(this.progressInterval)
      this.progressInterval = setInterval(this.increaseProgress, 100)

      return this.active_hosts[host.user_id]
    } catch(err) {
      console.log(err)
    }
  }

  getHosts() {
    return this.hosts
  }

  getActiveHosts() {
    return Object.values(this.active_hosts)
  }

  increaseProgress() {
    if (this.active) {
      this.progress = Math.min(this.progress + 100, this.duration)
    }
  }

  async refreshToken(host) {
    try {
      const response = await axios.post('https://accounts.spotify.com/api/token', 
        querystring.stringify({
          grant_type: 'refresh_token',
          refresh_token: host.refresh_token
        }),
        {
          headers: {
            'Authorization': 'Basic ' + (Buffer.from(process.env.SPOTIFY_CLIENT_ID + ':' + process.env.SPOTIFY_CLIENT_SECRET).toString('base64')),
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        }
      )
      const access_token = response.data.access_token
      const updated_host = await Host.findOneAndUpdate(
        { user_id: host.user_id },
        { access_token: access_token },
        { new: true }
      ).exec()

      this.hosts[host.user_id] = updated_host

      return response.data.access_token
    }
    catch(err) {
      console.log(err)
    }
  }

  async pingSpotify(wss) {
    try {
      let pingSooner = false
      const host = Object.values(this.hosts)[0]
      const data = await this.pingHost(host)

      const active_track = this.getActiveHosts()[0]

      wss.clients.forEach(client => {
        if(client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({...active_track, progress: this.progress}))
        }
      })

      if (!data || !data.duration || !data.progress) {
        this.pinger = setTimeout(() => this.pingSpotify(wss), 5000)
        return
      }
      const duration = data.duration / 1000
      const progress = data.progress / 1000

      if (duration - progress <= 5 && data.active) {
        pingSooner = true
        this.pinger = setTimeout(() => this.pingSpotify(wss), (duration - progress + 0.5) * 1000);
      }
      if (!pingSooner) {
        this.pinger = setTimeout(() => this.pingSpotify(wss), 5000)
      }
    } catch(err) {
      clearTimeout(this.pinger)
      this.pinger = setTimeout(() => this.pingSpotify(wss), 5000)
    }
  }

  async setup(wss) {
    await this.fetchHosts()

    const hosts = Object.values(this.hosts)
    for (const host of hosts) {
      await this.pingHost(host)
    }

    this.progressInterval = setInterval(this.increaseProgress, 100)
    wss.on('connection', ws => {
      const active_track = this.getActiveHosts()[0]
      ws.send(JSON.stringify({...active_track, progress: this.progress}))
    })
    this.pingSpotify(wss)

    this.refresher = scheduler.scheduleJob('*/45 * * * *', (fireDate) => {
      // refresh access tokens
      const hosts = Object.values(this.hosts)
      for (const host of hosts) {
        this.refreshToken(host)
      }
    })
  }
}

module.exports = new HostManager()
