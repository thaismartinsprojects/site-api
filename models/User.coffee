mongoose = require 'mongoose'
Schema = mongoose.Schema
jwt = require 'jsonwebtoken'
bcrypt = require 'bcrypt'
config = require '../config'
salt = bcrypt.genSaltSync(10)

generatePassword = (password) ->
  bcrypt.hashSync(password, salt);

UserSchema   = new Schema
  name: type: String, required: true
  email: type: String, unique: true, required: true
  user: type: String, required: true
  token: String
  password: type: String, required: true, set: generatePassword
  created: type: Date, default: Date.now

UserSchema.methods.comparePassword = (password) ->
  return false unless this.password
  bcrypt.compareSync(password, this.password)

UserSchema.methods.generateToken = () ->
  return false unless this.password
  jwt.sign(
    {'user': this.user, 'email': this.email, 'name': this.name},
    config.jwt.secret,
    {expiresIn: config.jwt.expires})

module.exports = mongoose.model 'User', UserSchema