'use strict'

express = require 'express'
router = express.Router()

router.use '/works', require './controllers/works'
router.use '/accounts', require './controllers/accounts'
router.use '/contact', require './controllers/contact'

module.exports = router