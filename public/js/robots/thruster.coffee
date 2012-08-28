Actuator = require './actuator'
_.extend(this, require 'box2d')

class Thruster extends Actuator
  constructor: (@battle, @robot) ->
    @body = @battle.createBody
      shapes: [
        type: 'box'
        density: 2
        extents: {x: robotRadius/4, y: robotRadius/8}
        localPosition: {x: -robotRadius/4/2, y: 0} # TODO: tweak
      ]
      position: @robot.body.GetOriginPosition()
      userData: actor: this

    jointDef = new b2RevoluteJointDef()
    jointDef.body1 = @robot.body
    jointDef.body2 = @body
    jointDef.anchorPoint = @body.GetOriginPosition()
    @joint = @battle.world.CreateJoint(jointDef)

  defaults:
    force: 0
    angularVelocity: 0

  execute: ->
    @joint.SetMotorSpeed(@angularVelocity)

  step: ->
    # TODO: Correct vector and position
    @body.ApplyForce(
      new b2Vec2( # force vector
        @force * Math.cos(@body.GetRotation()),
        @force * Math.sin(@body.GetRotation())
      ), @body.GetOriginPosition() # source position
    )

