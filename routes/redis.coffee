express = require('express')
router = express.Router()

# REDIS
router.get "/flushdb", (req, res) ->
  redis.flushdb (err, data) ->
    res.writeHead 200, "Content-Type": "text/plain"
    res.end (data || err)

router.get "/keys", (req, res) ->

  rhgetall = (key, callback) ->
    setTimeout (->
      redis.hgetall key, (err, resp) ->
        h = {}
        h[key] = resp
        callback null, h
    ), 500

  redis.keys '*', (err, keys) ->
    res.send keys

    # async.map keys, rhgetall, (err, result) ->
      # res.end JSON.stringify(result)


module.exports = router
