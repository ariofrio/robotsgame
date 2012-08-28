Actor = require './actor'
_.extend(this, require 'box2d')

module.exports = class Bullet extends Actor
  constructor: (@battle, @owner, position, velocity) ->
    shapeDef = new b2CircleDef()
    shapeDef.density = 10
    shapeDef.radius = 0.1
    bodyDef = new b2BodyDef()
    bodyDef.AddShape(shapeDef)
    bodyDef.position.Set(position.x, position.y)
    bodyDef.linearVelocity.Set(velocity.x, velocity.y)
    bodyDef.userData = actor: this
    @body = @battle.world.CreateBody(bodyDef)

