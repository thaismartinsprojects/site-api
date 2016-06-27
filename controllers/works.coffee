express = require 'express'
router = express.Router()
auth = require '../services/auth'
Work = require '../models/Work'
fs = require 'fs'
multer = require 'multer'
upload = multer({ 'dest': './public/uploads' })

# GET ALL WORKS
router.get '/', auth.isAuthenticated, (req, res) ->
  Work.find (err, userFound) ->
    return res.with(res.type.dbError) if err
    if userFound then res.with(res.type.foundSuccess, userFound) else res.with(res.type.itemNotFound)

# GET SPECIFIC WORK
router.get '/:id', auth.isAuthenticated, (req, res) ->
  Work.find {_id: req.params._id}, (err, usersFound) ->
    return res.with(res.type.dbError) if err
    return res.with(res.type.foundSuccess, usersFound) if usersFound.length > 0
    res.with(res.type.itemNotFound)

# ADD NEW WORK
router.post '/', auth.isAuthenticated, upload.array('images'), (req, res) ->
  work = new Work(req.body)
  images = []

  if(req.files)
    newPath = './public/images/works/' + work.path + '/'
    fs.mkdirSync(newPath, '0766') unless fs.existsSync(newPath)

    req.files.forEach (file) ->
      fs.rename file.path, newPath + file.filename, (err) ->
        if !err
          image =
            'title': ''
            'file': file.filename

          images.push(image);

  work.images = images;
  work.created = new Date();

  work.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, work);

module.exports = router