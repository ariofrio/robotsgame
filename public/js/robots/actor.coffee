Box2D = require 'box2d'

module.exports = class Actor
  ###
  createFixture: (shape, options) ->
    if not _.isObject(options)
      options = density: options
    fixtureDef = new Box2D.b2FixtureDef()
    for key, value of options
      fixtureDef["set_#{key}"](value)
    @body.CreateFixture(fixtureDef)
  ###

  start: ->
  turn: ->
  step: ->

