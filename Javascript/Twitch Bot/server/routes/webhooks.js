const express = require('express')
const webhooks = require('../controllers/webhooks')

const router = express.Router()

router.post('/eventsub', webhooks.eventsub)

module.exports = router
