express = require('express')
router = express.Router()

router.get '/', (req, res) ->

  what = ["bumps:counter:total", "bumps:counter:matched", "bumps:counter:miss"]
  redis.mget what, (err, data) ->
    if data and data.length > 2
      res.send "" + data[0] + " / " + data[1] + " / " + data[2]
    else
      res.end "K"

router.post '/', (req, res) ->
  data = req.rawBody
  res.send data

router.get '/bumpsdata/:channel', (req, res) ->
  channel = req.params.channel
  what = "bump:"+channel+":*"
  redis.keys what, (err, keys) ->
    multi = redis.multi()
    for key in keys
      console.log("hget "+key)
      multi.hget key, "data"

    multi.exec (err, data) ->
      console.dir data
      res.send data

module.exports = router
