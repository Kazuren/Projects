const jwt = require('jsonwebtoken')

module.exports = function verifyToken(req, res, next) {
  const OAuthHeader = req.headers['authorization'];
  if (OAuthHeader) {
    const OAuth = OAuthHeader.split(' ')
    const OAuthToken = OAuth[1]

    try {
      const decoded = jwt.verify(OAuthToken, process.env.JWT_PRIVATE_KEY)

      console.log(decoded)
      res.locals.payload = decoded

      next()
    } catch (err) {
      res.status(403).json({ success: false })
    }
    
  } else {
    // Forbidden
    res.status(403).json({ success: false })
  }
}
