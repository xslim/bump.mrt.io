express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  res.send "K"

router.post '/', (req, res) ->
  data = req.rawBody
  res.send data

module.exports = router
