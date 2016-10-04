var Contact, auth, express, logger, router;

express = require('express');

router = express.Router();

Contact = require('../models/Contact');

auth = require('../services/auth');

logger = require('../services/logger');

auth = require('../services/auth');

router.get('/', auth.isAuthenticated, function(req, res) {
  return Contact.find(function(err, contactsFound) {
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    return res["with"](contactsFound);
  });
});

router.post('/', function(req, res) {
  var contact;
  contact = new Contact();
  contact.message = req.body.message;
  contact.name = req.body.name;
  contact.phone = req.body.phone;
  contact.email = req.body.email;
  contact.created = Date.now();
  return contact.save(function(err) {
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    return res["with"](res.type.createSuccess, contact);
  });
});

router["delete"]('/:id', auth.isAuthenticated, function(req, res) {
  return Contact.findOneAndRemove({
    '_id': req.params.id
  }, function(err) {
    if (err) {
      return res["with"](res.type.dbError, err);
    }
    return res["with"](res.type.deleteSuccess);
  });
});

module.exports = router;
