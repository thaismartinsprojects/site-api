mongoose = require 'mongoose'
Schema = mongoose.Schema
jwt = require 'jsonwebtoken'
bcrypt = require 'bcrypt'
config = require '../config'
salt = bcrypt.genSaltSync(10)
Group = require './UserGroup'

generatePassword = (password) ->
  bcrypt.hashSync(password, salt);

setGroup = (callback, obj) ->
  Group.findOne {'type': 'administrador'}, (err, groupFound) ->
    obj.group = groupFound._id
    callback()

UserSchema = new Schema
  name: type: String, required: true
  email: type: String, unique: true, required: true
  user: type: String, required: true, unique: true
  group: type: Schema.Types.ObjectId, ref: 'UserGroup', required: true
  token: String
  photo: String
  password: type: String, required: true, set: generatePassword
  created: type: Date, default: Date.now

UserSchema.pre 'validate', (next) ->
  if not this.group?
    setGroup(next, this)

UserSchema.methods.comparePassword = (password) ->
  return false unless this.password
  bcrypt.compareSync(password, this.password)

UserSchema.methods.generateToken = () ->
  return false unless this.password
  jwt.sign(
    {'code': this._id, 'user': this.user, 'email': this.email, 'name': this.name},
    config.jwt.secret,
    {expiresIn: config.jwt.expires})

module.exports = mongoose.model 'User', UserSchema