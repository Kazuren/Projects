const express = require('express')
const { verifyToken } = require('../middleware')
const api = require('../controllers/api')

const router = express.Router()

router.get('/callback', api.callback)
router.get('/host/:id', api.host_details)
router.post('/login', api.login)
router.get('/admin', verifyToken, api.admin)


module.exports = router
