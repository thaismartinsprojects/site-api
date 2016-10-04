var Group, User, auth, config, express, fs, jwt, multer, nodemailer, router, upload, uploadPath, utils,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

express = require('express');

router = express.Router();

auth = require('../services/auth');

User = require('../models/User');

Group = require('../models/UserGroup');

utils = require('../services/utils');

fs = require('fs');

multer = require('multer');

uploadPath = './public/uploads/users';

upload = multer({
  'dest': uploadPath
});

nodemailer = require('nodemailer');

jwt = require('jsonwebtoken');

config = require('../config');

router.post('/auth', function(req, res) {
  var errors, query;
  req.checkBody('password', 'Password is required').notEmpty();
  req.checkBody('origin', 'Origin is required').notEmpty();
  if (req.body.origin === 'admin') {
    req.checkBody('username', 'Username is required').notEmpty();
    query = {
      username: req.body.username
    };
  } else {
    req.checkBody('email', 'Email is required').notEmpty();
    query = {
      email: req.body.email
    };
  }
  errors = req.validationErrors(true);
  if (errors) {
    return res["with"](res.type.fieldsMissing, {
      'errors': errors
    });
  }
  return User.findOne(query).populate('group').exec(function(err, userFound) {
    var ref;
    if ((userFound == null) || userFound.group.type !== req.body.origin) {
      return res["with"](res.type.itemNotFound);
    }
    if (!userFound.comparePassword(req.body.password)) {
      return res["with"](res.type.wrongPassword);
    }
    if ((req.body.token != null) && (ref = req.body.token, indexOf.call(userFound.pushToken, ref) < 0)) {
      User.findOneAndUpdate({
        email: decoded.email
      }, {
        $push: {
          token: req.body.token
        }
      });
    }
    return res["with"]({
      'token': userFound.generateToken(),
      'code': userFound._id
    });
  });
});

router.get('/', auth.isAuthenticated, function(req, res) {
  return User.find({}, '-password').populate('group').exec(function(err, usersFound) {
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    return res["with"](usersFound);
  });
});

router.get('/:id', auth.isAuthenticated, function(req, res) {
  return User.findOne({
    '_id': req.params.id
  }, '-password').populate('group').exec(function(err, userFound) {
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    if (userFound) {
      return res["with"](userFound);
    }
    return res["with"](res.type.itemNotFound);
  });
});

router.post('/', function(req, res) {
  return User.findOne({
    email: req.body.email
  }, function(err, userFound) {
    var type, user;
    if (userFound) {
      return res["with"](res.type.itemExists);
    }
    user = new User(req.body);
    type = 'admin';
    if (req.body.group != null) {
      type = req.body.group;
    }
    return Group.findOne({
      'type': type
    }, function(err, groupFound) {
      if (err) {
        return res["with"](res.type.dbError, err);
      }
      if (groupFound) {
        user.group = groupFound._id;
      }
      return user.save(function(err) {
        if (err) {
          return res["with"](res.type.dbError, err);
        }
        user.token = user.generateToken();
        return user.populate('group', function(err, userSaved) {
          return res["with"](userSaved.withoutPassword());
        });
      });
    });
  });
});

router.put('/:id', auth.isAuthenticated, upload.single('photo'), function(req, res) {
  return User.findOne({
    _id: req.params.id
  }, function(err, userFound) {
    var type, user;
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    if (userFound == null) {
      return res["with"](res.type.itemNotFound);
    }
    user = new User(req.body);
    type = 'admin';
    if (req.body.group != null) {
      type = req.body.group;
    }
    return Group.findOne({
      'type': type
    }, function(err, groupFound) {
      if (err) {
        return res["with"](res.type.dbError, err);
      }
      if (groupFound) {
        user.group = groupFound._id;
      }
      return User.findOneAndUpdate({
        _id: req.params.id
      }, {
        $set: user.forUpdate()
      }, {
        "new": true
      }).populate('group').exec(function(err, userUpdated) {
        if (err) {
          return res["with"](res.type.dbError, err);
        }
        userUpdated.token = user.generateToken();
        return res["with"](userUpdated.withoutPassword());
      });
    });
  });
});

router["delete"]('/:id', auth.isAuthenticated, function(req, res) {
  return User.findOneAndRemove({
    '_id': req.params.id
  }, function(err) {
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    return res["with"](res.type.deleteSuccess);
  });
});

module.exports = router;
