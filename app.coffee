express = require 'express'
app = express()

require('dotenv').config()

app.get '/', (req, res) ->
  res.send 'Hello world'

in_port = process.env.PROXY_PORT || 3000
app.listen (in_port), () ->
  console.log "Proxy is running on port #{in_port}!"
