'use strict';
var express, router;

express = require('express');

router = express.Router();

router.use('/accounts/groups', require('./controllers/groups'));

router.use('/accounts', require('./controllers/accounts'));

router.use('/contact', require('./controllers/contact'));

module.exports = router;
