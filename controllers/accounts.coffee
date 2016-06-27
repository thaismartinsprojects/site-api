express = require 'express'
router = express.Router()
auth = require '../services/auth'
User = require '../models/User'

# GET ALL USERS
router.get '/', auth.isAuthenticated, (req, res) ->
  User.find (err, usersFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, usersFound) if usersFound
    res.with(res.type.itemsNotFound)

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

module.exports = router