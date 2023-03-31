const jwt = require("jsonwebtoken");

async function verifyUser(req, res, next) {
  try {
    const AuthHeader = req.headers['authorization'];

    if (!AuthHeader) {
      return res.status(403).json({ err: { message: "Please provide an Authorization Header" } })
    }

    const token = AuthHeader.split(' ')[1]

    const decoded = jwt.verify(token, process.env.JWT_PRIVATE_KEY);
    res.locals.user = decoded;
    return next()
  } catch (err) {
    return res.status(403).json({ err: { message: "Invalid token" } })
  }
}

module.exports = verifyUser
