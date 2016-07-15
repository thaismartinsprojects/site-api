'use strict'

coffee = require 'coffee-script/register'
coffee = require 'coffee-script/register'
express = require 'express'
bodyParser = require 'body-parser'
mongoose = require 'mongoose'
expressValidator = require 'express-validator'
config = require './config'
path = require 'path'
cors = require 'cors'
response = require './services/response'
request = require './services/request'
chat = require './services/websocket'
jwt = require 'jsonwebtoken'

app = express()
app.set 'port', config.port
app.set 'host', config.host

mongoose.connect config.database, (err) ->
  console.log('Error to connect mongodb: ' + err) if err

app.use cors({'origin': true, 'allowedHeaders': "Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With, x-access-token", 'credentials': true})
app.use bodyParser.urlencoded({ extended: true })
app.use bodyParser.json()
app.use expressValidator()

app.use (req, res, next) ->
  res.type = response.messages
  res.with = response.with
  next()
  return

#app.use (req, res, next) ->
#  token = req.headers['x-access-token']
#  if not token?
#    user = jwt.decode(token);
#    req.user = request.generateUserData(user.code)
#  next()
#  return
socket = require 'socket.io'
server = require('http').Server(app)
server.listen(9000, app.get('host'));
chat.listen(server)

app.use '/api', require './routes'

app.listen app.get('port'), () ->
  console.log('App listening on ' + app.get('host') + ':' + app.get('port'))