const { validateUser } = require('../helpers')

// Depends on verifyToken
// maybe change that in the future

module.exports = async function verifyUser(req, res, next) {
  try {
    const data = await validateUser(res.locals.token)
    if (data.client_id !== process.env.CLIENT_ID) {
      res.status(403).json({ success: false })
    }
    res.locals.user_id = data.user_id
    res.locals.username = data.login
    next()
  }
  catch (err) {
    res.status(403).json({ err: err, success: false })
  }
}
