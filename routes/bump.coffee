express = require('express')
router = express.Router()


router.post "/:channel", (req, res) ->
  channel = req.params.channel
  time = Date.now() / 1000
  location = null
  data = req.rawBody

  console.log "Bump @ ", time

  data_or_id channel, time, location, data, (d) ->
    res.send d if d
    res.sendStatus(404) if not d

router.post "/:channel/:time/:location?", (req, res) ->
  channel = req.params.channel
  time = req.params.time
  location = req.params.location
  data = req.rawBody

  data_or_id channel, time, location, data, (d) ->
    res.send d if d
    res.sendStatus(404) if not d

router.get "/:channel/:id", (req, res) ->
  channel = req.params.channel
  id = req.params.id

  # console.log "Get for " + id

  db_find_by_id channel, id, (err, db_data) ->
    if db_data
      res.send(db_data)
    else
      res.sendStatus(404)

data_or_id = (channel, time, location, data, callback) ->

  db_find channel, time, location, data, (err, db_data) ->
    if db_data
      callback(db_data)
    else if data
      db_store channel, time, location, data, (err, db_id) ->
        callback(db_id)
    else
      callback(null)

db_find_by_id = (channel, id, callback) ->
  bump_counter = "bump:"+channel+":"

  b_id = bump_counter+id
  redis.hget b_id, "data", (err, data) ->
    callback(err, data)


db_find = (channel, time, location, data, callback) ->
  bumps_time = "bumps:"+channel
  ti1 = time - 10
  ti2 = time + 10

  # Range search
  # console.log "zrangebyscore ", bumps_time, ti1, ti2
  redis.zrangebyscore bumps_time, ti1, ti2, (err, items) ->
    if err or not items or items.length is 0
      callback(err, null)
      return

    # Check now location ? / set intersect ?

    # For now, take the latest
    item_id = items[items.length - 1]

    # Matched + data or id
    db_matched channel, item_id, data, (err, d) ->
      callback err, d


# Will return data
db_matched = (channel, id, data, callback) ->
  # console.log "db_matched ", id

  bump_counter = "bump:"+channel+":"
  bumps_time = "bumps:"+channel

  hasData = (if (data) then true else false)

  multi = redis.multi()

  # Remove from times set
  # console.log "zrem ", bumps_time, id
  multi.zrem(bumps_time, id)

  # Remove from location set ?
  # multi.zrem(bumps_time, id)

  time_m = Date.now() / 1000
  multi.hset(bump_counter+id, "matched", time_m)

  if hasData
    # console.log "hset data", data
    multi.hset(bump_counter+id, "data", data)

  multi.exec (err, e_data) ->
    # console.log "exec "
    if hasData
      callback err, id
    else
      b_id = bump_counter+id
      # console.log "hget ", b_id
      redis.hget b_id, "data", (err, d) ->
        # console.log "e,d ", err, d
        callback err, d

db_store = (channel, time, location, data, callback) ->
  item =
    time: time
    location: location
    data: data

  bump_counter = "bump:"+channel+":"
  bumps_time = "bumps:"+channel

  # Counter
  redis.incr bump_counter+"id", (err, bump_id) ->
    # console.log "bump_id = ", bump_id

    multi = redis.multi()

    # set hash
    multi.hmset bump_counter + bump_id, item

    # set ordered set
    # console.log "zadd ", bumps_time, time, bump_id
    multi.zadd bumps_time, time, bump_id
    multi.exec (err, data) ->
      callback err, String(bump_id)


module.exports = router
