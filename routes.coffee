'use strict'

express = require 'express'
router = express.Router()

router.use '/accounts', require './controllers/accounts'
router.use '/works', require './controllers/works'
router.use '/messages', require './controllers/messages'
router.use '/skills/items', require './controllers/skills-items'
router.use '/skills', require './controllers/skills'
router.use '/contact', require './controllers/contact'
router.use '/info', require './controllers/info'
router.use '/files', require './controllers/files'

module.exports = router