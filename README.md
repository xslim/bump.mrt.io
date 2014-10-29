# bump.mrt.io
NodeJS Server for Bump integration

## API

### POST a bump data
POST `/bump/:channel/:time/:location?`, where 
- `channel` is a "room"
- `time` is in seconds
- `location` is optional, as `lat,lon`

Responce: `id` of bump

Example:
`curl -X POST -d "test_data" http://bump.mrt.io/bump/test/1414542826` 

### GET a data
POST `/bump/:channel/:time/` or GET `/bump/:channel/:id`
Responce: `data` of bump

Example:
`curl -X POST -d http://bump.mrt.io/bump/test/1414542827`


## Features, TODO
- [x] REDIS
- [x] Time filtering
- [ ] location based filtering
- [ ] input validation
- [ ] stats
