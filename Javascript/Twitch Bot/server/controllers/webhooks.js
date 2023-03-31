const crypto = require('crypto')

const eventsub = async (req, res, next) => {
  try {
    const hmac_message = req.header('Twitch-Eventsub-Message-Id')
      + req.header('Twitch-Eventsub-Message-Timestamp')
      // + req.rawBody
    const hmac = crypto.createHmac('sha256', process.env.EVENTSUB_SECRET)
    const data = hmac.update(hmac_message)
    const signature = data.digest('hex')
    console.log(signature)
    console.log(req.headers)
  } catch (err) {
    
  }
}


module.exports = {
  eventsub
}
