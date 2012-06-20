express = require 'express'
onthefly = require './onthefly'
#holmesFind = require('./holmes')('public/js')

app = express.createServer()
app.use express.logger('dev')
app.use express.static('public')
app.use onthefly('public', ['coffee', 'less'])

global.css = (name) ->
  """<link rel="stylesheet" href="/css/#{name}.css">"""
global.js = (name) ->
  """<script src="/js/#{name}.js"></script>"""

app.get '/', (req, res) ->
  res.render('index.jade', layout: false)

port = process.env.PORT || 3000
app.listen(port, -> console.log("Listening on #{port}"))
