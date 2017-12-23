express = require 'express'
proxy = require 'express-http-proxy'
fs = require 'fs'
app = express()
require('dotenv').config()

is_true = (input) ->
  return input is true || input is 'TRUE' || input is 'true'

in_port = process.env.PROXY_PORT || 3000
out_port = process.env.HA_PORT || 8123
forward_host = process.env.HA_HOST || localhost
forward_ui = is_true process.env.FORWARD_UI
forward_api = is_true process.env.FORWARD_API

# Load the white and black lists
try
  allowed_url_file = fs.readFileSync 'allowed', {encoding: 'utf8'}
catch
  # do nothing if file doesn't exist
allowed_urls = []
if allowed_url_file
  allowed_urls.push u.trim() for u in allowed_url_file.split('\n') when u.trim() isnt ''
try
  blocked_url_file = fs.readFileSync 'blocked', {encoding: 'utf8'}
catch
  # do nothing if file doesn't exist
blocked_urls = []
if blocked_url_file
  blocked_urls.push u.trim() for u in blocked_url_file.split('\n') when u.trim() isnt ''

app.use '/', proxy "#{forward_host}:#{out_port}",
  filter: (req, res) ->
    fullUrl = req.protocol + '://' + req.hostname + req.originalUrl
    console.log req.method, 'request:', req.originalUrl

    # Check our blacklist first
    blocked = blocked_url for blocked_url in blocked_urls when req.originalUrl is blocked_url
    if blocked?
      console.log 'Request in blocked list'
      return false

    # Check our whitelist
    allowed = allowed_url for allowed_url in allowed_urls when req.originalUrl is allowed_url
    if allowed?
      console.log 'Request in allowed list'
      return true

    # Check our less specific rules...
    if (req.originalUrl.indexOf('/api/') is 0) # Hitting /api endpoint
      console.log 'API request', if forward_api then 'allowed' else 'denied'
      return forward_api
    else
      console.log 'UI request', if forward_ui then 'allowed' else 'denied'
      return forward_ui

    # Most secure to reject by default
    return false

app.listen (in_port), () ->
  console.log "Proxy is running on port #{in_port}!"
  console.log "UI Requests are", if forward_ui then 'allowed' else 'denied'
  console.log "API Requests are", if forward_api then 'allowed' else 'denied'
  console.log "Allowed URLs loaded: #{allowed_urls.length}"
  console.log "Blocked URLs loaded: #{blocked_urls.length}"
