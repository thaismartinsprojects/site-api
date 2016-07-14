'use strict'

mongoose = require 'mongoose'
Schema = mongoose.Schema

ContactSchema = new Schema
  name: type: String, required: true
  email: type: String, required: true
  phone: type: String, required: true
  message: type: String, required: true
  created: type: Date, default: Date.now

module.exports = mongoose.model 'Contact', ContactSchema