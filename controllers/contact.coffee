express = require 'express'
router = express.Router()
Contact = require '../models/Contact'
auth = require '../services/auth'
logger = require '../services/logger'
auth = require '../services/auth'

# ADD NEW MESSAGE
router.post '/', (req, res) ->
  contact = new Contact()
  contact.message = req.body.message
  contact.name = req.body.name
  contact.phone = req.body.phone
  contact.email = req.body.email
  contact.created = Date.now()

  contact.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, contact)

# DELETE MESSAGE
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  Contact.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.deleteSuccess)

module.exports = router