mongoose = require 'mongoose'
Schema = mongoose.Schema

MessageSchema = new Schema
  to: type: Schema.Types.ObjectId, ref: 'User', required: true
  from: type: Schema.Types.ObjectId, ref: 'User', required: true
  message: type: String, required: true
  created: type: Date, default: Date.now
  visualized: type: Boolean, default: false

MessageSchema.methods.toObjWithoutId = () ->
  obj = this.toObject()
  delete obj._id
  return obj

module.exports = mongoose.model 'Message', MessageSchema