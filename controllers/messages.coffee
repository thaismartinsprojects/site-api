express = require 'express'
router = express.Router()
auth = require '../services/auth'
Message = require '../models/Message'

# ADD NEW MESSAGE
router.post '/', auth.isAuthenticated, (req, res) ->
  message = new Message(req.body);
  message.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(message)

# UPDATE EXISTENT MESSAGE
router.put '/:id', auth.isAuthenticated, (req, res) ->
  message = new Message(req.body);
  Message.findOneAndUpdate({_id: req.params.id}, message.toObjWithoutId()).populate('user').exec (err, messageUpdate) ->
    return res.with(res.type.dbError, err) if err
    res.with(messageUpdate);

# GET ALL MESSAGES
router.get '/', auth.isAuthenticated, (req, res) ->
  console.log(req.user)
  Message.find().sort({'created': -1}).populate('user').exec (err, messagesFound) ->
    return res.with(res.type.dbError) if err
    res.with(messagesFound)

# GET SPECIFIC MESSAGE
router.get '/:id', auth.isAuthenticated, (req, res) ->
  Message.find({_id: req.params.id}).sort({'created': -1}).populate('user').exec (err, messageFound) ->
    return res.with(res.type.dbError) if err
    return res.with(messageFound)  if messageFound
    res.with(res.type.itemNotFound)

# DELETE MESSAGE
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  Message.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.deleteSuccess)

module.exports = router