const express = require('express')
const { verifyToken, verifyUser } = require('../middleware')
const api = require('../controllers/api')

const router = express.Router()

router.get('/bot', verifyToken, verifyUser, api.bot_details)


router.get('/logs', verifyToken, verifyUser, api.logs)
router.get('/logs/:year', verifyToken, verifyUser, api.logs)
router.get('/logs/:year/:month', verifyToken, verifyUser, api.logs)
router.get('/logs/:year/:month/:day', verifyToken, verifyUser, api.logs)

// limit requests somehow so people cant spam client.join/client.part
router.post('/bot', verifyToken, verifyUser, api.bot_create)
router.put('/bot/join', verifyToken, verifyUser, api.bot_join)
router.put('/bot/part', verifyToken, verifyUser, api.bot_part)

router.get('/commands', verifyToken, verifyUser, api.commands)
router.post('/commands', verifyToken, verifyUser, api.commands_create)
router.delete('/commands', verifyToken, verifyUser, api.commands_delete)
router.put('/commands/:id', verifyToken, verifyUser, api.commands_edit)

router.get('/timers', verifyToken, verifyUser, api.timers)
router.post('/timers', verifyToken, verifyUser, api.timers_create)
router.delete('/timers', verifyToken, verifyUser, api.timers_delete)
router.put('/timers/:id', verifyToken, verifyUser, api.timers_edit)

router.get('/filters', verifyToken, verifyUser, api.filters)
router.put('/filters/:id', verifyToken, verifyUser, api.filters_edit)

module.exports = router
