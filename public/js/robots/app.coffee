Battle = require './battle'
Renderer = require './renderer'

class App
  constructor: ->
    script = "/js/robots/examples/simple-robot.js"
    @battle = new Battle([script, script])
    @renderer = new Renderer(@battle)
  start: ->
    @battle.start()
    @renderer.start()

require('ready') ->
  window.app = new App()
  window.app.start()
