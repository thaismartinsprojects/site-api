express = require 'express'
router = express.Router()
auth = require '../services/auth'
Skill = require '../models/Skill'

# ADD NEW SKILL
router.post '/', auth.isAuthenticated, (req, res) ->
  skill = new Skill(req.body)
  skill.created = new Date();
  skill.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, skill);

# UPDATE EXISTENT SKILL
router.put '/:id', auth.isAuthenticated, (req, res) ->
  skill = new Skill(req.body)
  Skill.findOneAndUpdate({_id: req.params.id}, skill.toObjWithoutId()).populate('items').exec (err, skillUpdated) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.updateSuccess, skillUpdated);

# GET ALL SKILLS
router.get '/', auth.isAuthenticated, (req, res) ->
  Skill.find().populate('items').exec (err, skillsFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, skillsFound) if skillsFound.length > 0
    res.with(res.type.itemsNotFound)

# GET SPECIFIC SKILL
router.get '/:id', auth.isAuthenticated, (req, res) ->
  Skill.find({_id: req.params.id}).populate('items').exec (err, skillFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, skillFound) if skillFound
    res.with(res.type.itemNotFound)

module.exports = router