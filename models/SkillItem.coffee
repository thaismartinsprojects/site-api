mongoose = require 'mongoose'
Schema = mongoose.Schema

SkillItemSchema = new Schema
  title: type: String, required: true
  icon: type: String,  required: true
  created: Date
  updated: type: Date, default: Date.now

SkillItemSchema.methods.toObjWithoutId = () ->
  obj = this.toObject()
  delete obj._id
  return obj

module.exports = mongoose.model 'SkillItem', SkillItemSchema