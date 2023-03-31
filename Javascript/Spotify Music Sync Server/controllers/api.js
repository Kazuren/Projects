const axios = require('axios')
const querystring = require('querystring')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcrypt')
const Host = require('../models/host')
const Admin = require('../models/admin')

const host_details = async (req, res, next) => {
  try {
    const id = req.params.id

    const host = await Host.findOne({ user_id: id }).exec()

    if (host) {
      return res.status(200).json({host, success: true})
    }

    return res.status(404).json({success: false})
  } catch (err) {
    console.log(err)
  }
}

const admin = async (req, res, next) => {

}

const login = async (req, res, next) => {
  const username = req.body.username.toLowerCase()
  const password = req.body.password

  const admin = await Admin.findOne( { username: username }).exec()

  if (!admin) {
    return res.status(404).json({ success: false, reason: `Wrong username or password` })
  }

  const match = await bcrypt.compare(password, admin.password)

  if (!match) {
    return res.status(404).json({ success: false, reason: `Wrong username or password` })
  }

  const payload = { username: username }

  const token = jwt.sign(payload, process.env.JWT_PRIVATE_KEY)

  res.send({ token })
}

const callback = async (req, res, next) => {
  try {
    const token = req.query.state
    const payload = jwt.verify(token, process.env.JWT_PRIVATE_KEY)
    const username = payload.username

    if (username !== 'sjow' && username !== 'kazuren') {
      return res.status(403).json({success: false})
    }

    const response = await axios.post('https://accounts.spotify.com/api/token',
      querystring.stringify({
        grant_type: 'authorization_code',
        code: req.query.code,
        redirect_uri: `${process.env.SERVER_DOMAIN}/api/callback`
      }),
      {
        headers: {
          'Authorization': 'Basic ' + (Buffer.from(process.env.SPOTIFY_CLIENT_ID + ':' + process.env.SPOTIFY_CLIENT_SECRET).toString('base64')),
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      }
    )
    const access_token = response.data.access_token
    const { data } = await axios.get('https://api.spotify.com/v1/me', {
      headers: {
        'Authorization': `Bearer ${access_token}`
      }
    })

    let host = await Host.findOne({user_id: data.id}).exec()

    if (host) {
      // update access_token & refresh_token and then redirect
      return res.redirect(`${process.env.CLIENT_DOMAIN}`)
    }

    host = new Host({
      user_id: data.id,
      username: data.display_name,
      access_token: response.data.access_token,
      refresh_token: response.data.refresh_token
    })

    await host.save()

    res.redirect(`${process.env.CLIENT_DOMAIN}`)
  } catch (err) {
    console.log(err.response)
  }
}

module.exports = {
  callback,
  host_details,
  login,
  admin
}
