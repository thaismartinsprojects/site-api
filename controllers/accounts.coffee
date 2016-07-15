express = require 'express'
router = express.Router()
auth = require '../services/auth'
User = require '../models/User'
Group = require '../models/UserGroup'
utils = require '../services/utils'
fs = require 'fs'
multer = require 'multer'
upload = multer({ 'dest': './public/uploads/users' })

# ADD NEW GROUP
router.post '/groups', (req, res) ->
  Group.findOne {type: utils.createSlug(req.body.type)}, (err, groupFound) ->
    return res.with(res.type.itemExists) if groupFound
    group = new Group(req.body);
    group.save (err) ->
      return res.with(res.type.dbError, err) if err
      res.with(group)

# GET ALL GROUPS
router.get '/groups', auth.isAuthenticated, (req, res) ->
  Group.find (err, groupsFound) ->
    return res.with(res.type.dbError, err) if err
    res.with(groupsFound)

# GET ALL USERS
router.get '/', auth.isAuthenticated, (req, res) ->
  User.find({}, '-password').populate('group').exec (err, usersFound) ->
    return res.with(res.type.dbError, err) if err
    res.with(usersFound)

# GET SPECIFIC USER
router.get '/:id', auth.isAuthenticated, (req, res) ->
  User.findOne({'_id': req.params.id}, '-password').populate('group').exec (err, userFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(userFound) if userFound
    res.with(res.type.itemNotFound)

# ADD NEW USER
router.post '/', (req, res) ->
  User.findOne {email: req.body.email}, (err, userFound) ->
    return res.with(res.type.itemExists) if userFound
    user = new User(req.body);
    user.created = new Date
    user.save (err) ->
      return res.with(res.type.dbError, err) if err
      user.token = user.generateToken()
      res.with(user)

# UPDATE EXISTENT USER
router.put '/:id', auth.isAuthenticated, upload.single('photo'), (req, res) ->
  User.findOne {_id: req.params.id}, (err, userFound) ->
    return res.with(res.type.itemNotFound) if err

    user = new User(req.body)

    dataToUpdate = {}
    dataToUpdate.name = user.name if user.name? and userFound.name != user.name
    dataToUpdate.email = user.email if user.email? and userFound.email != user.email
    dataToUpdate.group = user.group if user.group? and userFound.group != user.group
    dataToUpdate.username = user.username if user.username? and userFound.username != user.username
    dataToUpdate.password = user.password if user.password? and !userFound.comparePassword(user.password)

    if(req.file)
      path = './public/uploads/users'
      fs.mkdirSync(path, '0766') unless fs.existsSync(path)
      dataToUpdate.photo = req.file.filename

    for key, value of dataToUpdate
      userFound[key] = value

    User.update {_id: req.params.id}, {$set: dataToUpdate}, (err) ->
      return res.with(res.type.dbError, err) if err
      res.with(userFound)

# DO LOGIN
router.post '/auth', (req, res) ->
  req.checkBody('password', 'Password is required').notEmpty()
  req.checkBody('username', 'Username is required').notEmpty()

  errors = req.validationErrors(true);
  return res.with(res.type.fieldsMissing, {'errors': errors}) if errors

  user = new User(req.body);
  User.findOne {username: req.body.username}, (err, userFound) ->
    return res.with(res.type.itemNotFound) unless userFound?
    if (user.comparePassword(req.body.password))
      return res.with({'token': user.generateToken(), 'code': userFound._id})
    res.with(res.type.wrongPassword)

# DELETE USER
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  User.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.deleteSuccess)

module.exports = router