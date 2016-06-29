express = require 'express'
router = express.Router()
auth = require '../services/auth'
Skill = require '../models/Skill'

# GET ALL SKILLS
router.get '/', auth.isAuthenticated, (req, res) ->
  Skill.find (err, skillFound) ->
    return res.with(res.type.dbError) if err
    if skillFound then res.with(res.type.foundSuccess, skillFound) else res.with(res.type.itemNotFound)

# GET SPECIFIC SKILL
router.get '/:id', auth.isAuthenticated, (req, res) ->
  Skill.find {_id: req.params._id}, (err, skillsFound) ->
    return res.with(res.type.dbError) if err
    return res.with(res.type.foundSuccess, skillsFound) if skillsFound.length > 0
    res.with(res.type.itemNotFound)

# ADD NEW SKILL
router.post '/', auth.isAuthenticated, (req, res) ->
  
  skill = new Skill(req.body)
  skill.created = new Date();

  skill.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, skill);

module.exports = router

# UPDATE EXISTENT SKILL
router.put '/:id', auth.isAuthenticated, (req, res) ->

  skill = new Skill(req.body)
  skill.findOneAndUpdate {_id: req.params.id}, skill.toObjWithoutId(),  (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, skill);

module.exports = router