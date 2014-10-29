express = require("express")
bodyParser = require("body-parser")
crypto = require("crypto")


app = express()

port = process.env.PORT or 9000

# REDIS
if process.env.REDISTOGO_URL
  conn_url = process.env.REDISTOGO_URL
  rtg   = require("url").parse(conn_url)
  redis = require("redis").createClient(rtg.port, rtg.hostname)
else
  redis = require("redis").createClient()

redis.on "error", (err) ->
  console.log "Error ", err

if rtg
  redis.auth(rtg.auth.split(":")[1])

GLOBAL.redis = redis

# app.set "views", __dirname + "/views"
# app.set "view engine", "jade"
# app.set "root", __dirname
# app.use express.favicon()
# app.use express.logger("dev")
# app.use stylus.middleware(src: __dirname + "/public")
app.use express.static(__dirname + "/public")

app.use (req, res, next) ->
  data = ""
  req.setEncoding "utf8"
  req.on "data", (chunk) ->
    data += chunk
  req.on "end", ->
    req.rawBody = data
    next()

# app.use bodyParser.urlencoded({ extended: false })
# app.use bodyParser.json()
# app.use bodyParser.text()
# app.use bodyParser.text({type: "application/x-*"})
# app.use bodyParser.raw()

app.use '/', require('./routes/main')
app.use '/bump', require('./routes/bump')
app.use '/redis', require('./routes/redis')

app.listen(port)
console.log "Starting on ", port
