mongoose = require 'mongoose'
Schema = mongoose.Schema
utils = require '../services/utils'

generatePath = (name) ->
  this.path = utils.createSlug(name)
  name

WorkSchema = new Schema
  title: type: String, required: true, set: generatePath
  shortdescription: type: String, required: true
  path: type: String, required: true
  description: type: String,  required: true
  images: [
    title: type: String
    file: type: String, required: true
    created: type: Date, default: Date.now
  ]
  tags: [String]
  url: String
  created: Date
  updated: type: Date, default: Date.now

WorkSchema.methods.toObjWithoutId = () ->
  obj = this.toObject()
  delete obj._id
  return obj

module.exports = mongoose.model 'Work', WorkSchema