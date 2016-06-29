mongoose = require 'mongoose'
Schema = mongoose.Schema

SkillSchema = new Schema
  name: type: String, required: true
  description: type: String,  required: true
  items: [{
    name: String,
    icon: String
  }]
  created: Date
  updated: type: Date, default: Date.now

SkillSchema.methods.toObjWithoutId = () ->
  obj = this.toObject()
  delete obj._id
  return obj

module.exports = mongoose.model 'Skill', SkillSchema