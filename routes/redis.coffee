express = require('express')
router = express.Router()

# REDIS
router.get "/flushdb", (req, res) ->
  redis.flushdb (err, data) ->
    res.writeHead 200, "Content-Type": "text/plain"
    res.end (data || err)

router.get "/keys/:what?", (req, res) ->
  what = req.params.what

  rhgetall = (key, callback) ->
    setTimeout (->
      redis.hgetall key, (err, resp) ->
        h = {}
        h[key] = resp
        callback null, h
    ), 500

  if what
    what += "*"
  else
    what = "*"

  redis.keys what, (err, data) ->
    res.send data.join("<br>")

    # async.map keys, rhgetall, (err, result) ->
      # res.end JSON.stringify(result)


module.exports = router
