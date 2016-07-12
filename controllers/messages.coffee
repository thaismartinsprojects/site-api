express = require 'express'
router = express.Router()
auth = require '../services/auth'
Message = require '../models/Message'

# ADD NEW MESSAGE
router.post '/', auth.isAuthenticated, (req, res) ->
  message = new Message(req.body);
  message.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, message)

# UPDATE EXISTENT MESSAGE
router.put '/:id', auth.isAuthenticated, (req, res) ->
  message = new Message(req.body);
  Message.findOneAndUpdate({_id: req.params.id}, message.toObjWithoutId()).populate('user').exec (err, messageUpdate) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.updateSuccess, messageUpdate);

# GET ALL MESSAGES
router.get '/', auth.isAuthenticated, (req, res) ->
  Message.find().populate('user').exec (err, messagesFound) ->
    return res.with(res.type.dbError) if err
    return res.with(res.type.foundSuccess, messagesFound)  if messagesFound.length > 0
    res.with(res.type.itemsNotFound)

# GET SPECIFIC MESSAGE
router.get '/:id', auth.isAuthenticated, (req, res) ->
  Message.find({_id: req.params.id}).populate('user').exec (err, messageFound) ->
    return res.with(res.type.dbError) if err
    return res.with(res.type.foundSuccess, messageFound)  if messageFound
    res.with(res.type.itemNotFound)

module.exports = router