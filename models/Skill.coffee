mongoose = require 'mongoose'
Schema = mongoose.Schema
Item = require './SkillItem'

SkillSchema = new Schema
  title: type: String, required: true
  description: type: String,  required: true
  items: [ type: Schema.Types.ObjectId, ref: 'SkillItem' ]
  created: Date
  updated: type: Date, default: Date.now

SkillSchema.methods.toObjWithoutId = () ->
  obj = this.toObject()
  delete obj._id
  return obj

SkillSchema.methods.populateItems = (callback) ->

  items = []
  if this.items.length > 0
    for item in this.items
      Item.find {'_id': item}, (err, itemFound) ->
        items.push(itemFound)

  this.items = items;
  callback()

module.exports = mongoose.model 'Skill', SkillSchema