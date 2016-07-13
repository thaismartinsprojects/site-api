express = require 'express'
router = express.Router()
auth = require '../services/auth'
User = require '../models/User'
Group = require '../models/UserGroup'
utils = require '../services/utils'

# GET ALL USERS
router.get '/', auth.isAuthenticated, (req, res) ->
  User.find().populate('group').exec (err, usersFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, usersFound) if usersFound.length > 0
    res.with(res.type.itemsNotFound)

# GET SPECIFIC USER
router.get '/:id', auth.isAuthenticated, (req, res) ->
  User.findOne({'_id': req.params.id}).populate('group').exec (err, userFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, userFound) if userFound
    res.with(res.type.itemNotFound)

# ADD NEW USERS
router.post '/group', (req, res) ->
  Group.findOne {type: utils.createSlug(req.body.type)}, (err, groupFound) ->
    return res.with(res.type.itemExists) if groupFound
    group = new Group(req.body);
    group.save (err) ->
      return res.with(res.type.dbError, err) if err
      res.with(res.type.createSuccess, group)

# ADD NEW USERS
router.post '/', (req, res) ->
  User.findOne {email: req.body.email}, (err, userFound) ->
    return res.with(res.type.itemExists) if userFound
    user = new User(req.body);
    user.save (err) ->
      return res.with(res.type.dbError, err) if err
      user.token = user.generateToken()
      res.with(res.type.createSuccess, user)

# DO LOGIN
router.post '/auth', (req, res) ->
  req.checkBody('password', 'Password is required').notEmpty()
  req.checkBody('user', 'User is required').notEmpty()

  errors = req.validationErrors(true);
  return res.with(res.type.fieldsMissing, {'errors': errors}) if errors

  user = new User(req.body);
  User.findOne {user: req.body.user}, (err, userFound) ->
    return res.with(res.type.itemNotFound) unless userFound?
    if (user.comparePassword(req.body.password))
      return res.with(res.type.loginSuccess, {'token': user.generateToken()})
    res.with(res.type.wrongPassword)

# GET DELETE USER
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  User.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.deleteSuccess)

module.exports = router