const express = require('express')
const { verifyUser } = require('../middleware')
const api = require('../controllers/api.js')

const router = express.Router()

router.post('/login', api.user_login)
//router.post('/register', api.user_register)
router.get('/email/data', verifyUser, api.email_data)
router.post('/email/send', verifyUser, api.email_send)
router.post('/email/test', verifyUser, api.email_test)
router.get('/email/history', verifyUser, api.email_history)
router.get('/email/tasks', verifyUser, api.email_tasks)

router.get('/email/template/names', verifyUser, api.email_get_template_names)
router.post('/email/template', verifyUser, api.email_save_template)
router.put('/email/template', verifyUser, api.email_load_template)
router.post('/email/template/delete', verifyUser, api.email_delete_template)

module.exports = router