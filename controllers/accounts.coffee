express = require 'express'
router = express.Router()
auth = require '../services/auth'
User = require '../models/User'
Group = require '../models/UserGroup'
Company = require '../models/Company'
utils = require '../services/utils'
fs = require 'fs'
multer = require 'multer'
uploadPath = './public/uploads/users'
upload = multer({ 'dest': uploadPath })
nodemailer = require 'nodemailer'
jwt = require 'jsonwebtoken'
config = require '../config'


# DO LOGIN
router.post '/auth', (req, res) ->

  req.checkBody('password', 'Password is required').notEmpty()
  req.checkBody('origin', 'Origin is required').notEmpty()

  if req.body.origin == 'admin'
    req.checkBody('username', 'Username is required').notEmpty()
    query = {username: req.body.username}
  else
    req.checkBody('email', 'Email is required').notEmpty()
    query = {email: req.body.email}

  errors = req.validationErrors(true);
  return res.with(res.type.fieldsMissing, {'errors': errors}) if errors

  User.findOne(query).populate('group').exec (err, userFound) ->
    return res.with(res.type.itemNotFound) if not userFound? or userFound.group.type != req.body.origin
    return res.with(res.type.wrongPassword) if !userFound.comparePassword(req.body.password)

    if req.body.token? and req.body.token not in userFound.pushToken
      User.findOneAndUpdate({email: decoded.email}, {$push: {token: req.body.token}})

    res.with({'token': userFound.generateToken(), 'code': userFound._id})

# GET ALL USERS
router.get '/', auth.isAuthenticated, (req, res) ->
  User.find({}, '-password').populate('group').populate('companies').exec (err, usersFound) ->
    return res.with(res.type.dbError, err) if err
    res.with(usersFound)

# GET SPECIFIC USER
router.get '/:id', auth.isAuthenticated, (req, res) ->
  User.findOne({'_id': req.params.id}, '-password').populate('group').populate('companies').exec (err, userFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(userFound) if userFound
    res.with(res.type.itemNotFound)

# ADD NEW USER
router.post '/', (req, res) ->
  User.findOne {email: req.body.email}, (err, userFound) ->
    return res.with(res.type.itemExists) if userFound

    user = new User(req.body);
    type = 'admin'
    type = req.body.group if req.body.group?

    Group.findOne {'type': type}, (err, groupFound) ->
        return res.with(res.type.dbError, err) if err
        user.group = groupFound._id if groupFound
        user.save (err) ->
          return res.with(res.type.dbError, err) if err
          user.token = user.generateToken()
          user.populate 'group', (err, userSaved) ->
            res.with(userSaved.withoutPassword())

# UPDATE EXISTENT USER
router.put '/:id', auth.isAuthenticated, upload.single('photo'), (req, res) ->
  User.findOne {_id: req.params.id}, (err, userFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.itemNotFound) unless userFound?

    user = new User(req.body)
    
    type = 'admin'
    type = req.body.group if req.body.group?

    Group.findOne {'type': type}, (err, groupFound) ->
      return res.with(res.type.dbError, err) if err
      user.group = groupFound._id if groupFound
      User.findOneAndUpdate({_id: req.params.id}, {$set: user.forUpdate()}, {new: true}).populate('group').exec (err, userUpdated) ->
        return res.with(res.type.dbError, err) if err
        userUpdated.token = user.generateToken()
        res.with(userUpdated.withoutPassword())

# DELETE USER
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  User.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    Company.findOneAndRemove {user: req.params.id}, (err, companyFounded) ->
      return res.with(res.type.dbError, err) if err
      Coupon.findOneAndRemove {'company': companyFounded._id}, (err) ->
        return res.with(res.type.dbError, err) if err
        res.with(res.type.deleteSuccess)

module.exports = router