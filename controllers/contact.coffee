express = require 'express'
router = express.Router()
auth = require '../services/auth'
Contact = require '../models/Contact'
fs = require 'fs'
nodemailer = require 'nodemailer'
smtpTransport = require 'nodemailer-smtp-transport'

# ADD NEW MESSAGE
router.post '/', (req, res) ->

  transporter = nodemailer.createTransport smtpTransport(
    service: "gmail"
    auth:
      user: "thaismartinsweb@gmail.com"
      pass: "thatha14"
  )

  emailbodyfilepath = __dirname + '/../public/emails/contact.html'
  emailHtml = fs.readFileSync(emailbodyfilepath,'utf8')

  mailOptions =
    from: '"Thais Martins" <contato@thaismartins.co>'
    to: 'thamartins@msn.com, contato@thaismartins.co'
    subject: '[thaismartins.co] Contato do Site'
    text: 'Hello world text!'
    html: emailHtml

  transporter.sendMail mailOptions, (err) ->
    return console.log(err) if err
    contact = new Contact(req.body);
    contact.save (err) ->
      return res.with(res.type.dbError, err) if err
      res.with(res.type.createSuccess, contact)

# DELETE MESSAGE
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  Contact.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.deleteSuccess)

module.exports = router