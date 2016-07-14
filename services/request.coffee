'use strict'

User = require '../models/User'

module.exports =
  generateUserData: (userId) ->
    if userId
      user = null
      User.find {'_id': userId}, (err, userFound) ->
        return user = new Error err if err
        return user = userFound if userFound
        user = new Error 'Fail to validate.'
      return user