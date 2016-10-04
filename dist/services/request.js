'use strict';
var User;

User = require('../models/User');

module.exports = {
  generateUserData: function(userId) {
    var user;
    if (userId) {
      user = null;
      User.find({
        '_id': userId
      }).populate('group').exec(function(err, userFound) {
        if (err) {
          return user = new Error(err);
        }
        if (userFound) {
          return user = userFound;
        }
        return user = new Error('Fail to validate.');
      });
      return user;
    }
  }
};
