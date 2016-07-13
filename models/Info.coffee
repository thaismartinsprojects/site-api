mongoose = require 'mongoose'
Schema = mongoose.Schema

InfoSchema = new Schema
  title: type: String, required: true
  logo: type: String
  email: type: String
  phone: type: String
  social:
    facebook: { type: String },
    twitter: { type: String },
    pinterest: { type: String },
    tumbler: { type: String },
    googleplus: { type: String },
    linkedin: { type: String },
    github: { type: String },
    bitbucket: { type: String }
  created: type: Date
  updated: type: Date, default: Date.now

InfoSchema.methods.toObjWithoutId = () ->
  obj = this.toObject()
  delete obj._id
  return obj

module.exports = mongoose.model 'Info', InfoSchema