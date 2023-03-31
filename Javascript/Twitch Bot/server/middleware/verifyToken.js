module.exports = function verifyToken(req, res, next) {
  const OAuthHeader = req.headers['authorization'];
  if (OAuthHeader) {
    const OAuth = OAuthHeader.split(' ')
    const OAuthToken = OAuth[1]
    res.locals.token = OAuthToken
    next()
  } else {
    // Forbidden
    res.status(403).json({ success: false })
  }
}
