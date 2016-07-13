express = require 'express'
router = express.Router()
auth = require '../services/auth'
Item = require '../models/SkillItem'

# ADD NEW SKILL ITEM
router.post '/', auth.isAuthenticated, (req, res) ->
  item = new Item(req.body)
  item.created = new Date();
  item.save (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.createSuccess, item);

# UPDATE EXISTENT SKILL ITEM
router.put '/:id', auth.isAuthenticated, (req, res) ->
  item = new Item(req.body)
  Item.findOneAndUpdate {_id: req.params.id}, item.toObjWithoutId(), (err, itemUpdated) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.updateSuccess, itemUpdated);

# GET ALL SKILLS ITEM
router.get '/', auth.isAuthenticated, (req, res) ->
  Item.find (err, itemsFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, itemsFound) if itemsFound.length > 0
    res.with(res.type.itemsNotFound)

# GET SPECIFIC SKILL ITEM
router.get '/:id', auth.isAuthenticated, (req, res) ->
  Item.find {_id: req.params.id}, (err, itemFound) ->
    return res.with(res.type.dbError, err) if err
    return res.with(res.type.foundSuccess, skillsFound) if itemFound
    res.with(res.type.itemNotFound)

# DELETE SKILL ITEM
router.delete '/:id', auth.isAuthenticated, (req, res) ->
  Item.findOneAndRemove {'_id': req.params.id}, (err) ->
    return res.with(res.type.dbError, err) if err
    res.with(res.type.deleteSuccess)

module.exports = router