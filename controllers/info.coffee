express = require 'express'
router = express.Router()
auth = require '../services/auth'
Info = require '../models/Info'

# ADD NEW MESSAGE
router.post '/', auth.isAuthenticated, (req, res) ->
  info = new Info(req.body);
  info.created = new Date()
  info.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, info)

# UPDATE EXISTENT MESSAGE
router.put '/:id', auth.isAuthenticated, (req, res) ->
  info = new Info(req.body);
  Info.findOneAndUpdate {_id: req.params.id}, info.toObjWithoutId(), (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.updateSuccess, info);

# GET ALL MESSAGES
router.get '/', auth.isAuthenticated, (req, res) ->
  Info.find().sort('created', -1).limit(1).execFind (err, infosFound) ->
    return res.with(res.type.dbError) if err
    return res.with(res.type.foundSuccess, infosFound)  if infosFound.length > 0
    res.with(res.type.itemsNotFound)

module.exports = router