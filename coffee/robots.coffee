# Timing/accuracy settings
turnsPerSecond = 10   # speed of simulation
stepsPerTurn = 6      # ?
iterationsPerStep = 1 # more iterations lets Box2D be more accurate

# 
robotRadius = 1
wallThickness = 10
fieldWidth = 30
fieldHeight = 30

_.mixin {
  dotterize: (object, prefix="") ->
    pairs = {}
    for key, value of object
      if _.isObject(value)
        _.extend(pairs, _.dotterize(value, key + "."))
      else
        pairs[prefix + key] = value
    pairs
  
  undotterize: (pairs) ->
    final = {}
    for path, value of pairs
      object = final
      for segment in path.split(".")[...-1]
        object = (object[segment] ?= {})
      object[path.split(".").pop()] = value
    final
}

# Manages the battle logic and coordinates the Physics simulation
class Battle
  constructor: (robotScripts) ->
    # Set up world, no gravity, allow bodies to sleep when
    # they come to rest.
    boundingBox = new b2AABB()
    boundingBox.minVertex.Set(-1000, -1000)
    boundingBox.maxVertex.Set(1000 + fieldWidth, 1000 + fieldHeight)
    @world = new b2World(boundingBox, new b2Vec2(0, 0), true)

    # Create the actors we have at the beginning of the battle.
    @actors = [new Arena(this)]
    for script in robotScripts
      @actors.push(new Robot(this, script))

  start: ->
    actor.start() for actor in @actors
    @time = 0
    @interval = setInterval(@step, 1.0/turnsPerSecond/stepsPerTurn)

  step: =>
    @turn() if @time % stepsPerTurn == 0
    @time++

    actor.step() for actor in @actors

    # Remove the actors for removed bodies: TODO
    @world.Step(1.0/turnsPerSecond/stepsPerTurn, iterationsPerStep)

  turn: ->
    actor.turn() for actor in @actors

  # Wrapper around B2 stuffs for cleaner codez
  createBody: (body) ->
    bodyDef = new b2BodyDef()
    if body.shapes?
      for shape in body.shapes
        shapeDef = switch shape.type
          when 'circle' then new b2CircleDef()
          when 'box' then new b2BoxDef()
          else throw 'Error: unknown shape type'
        delete shape.type
        _.deepExtend(shapeDef, shape)
        bodyDef.AddShape(shapeDef)
    delete body.shapes
    _.deepExtend(bodyDef, body)
    @world.CreateBody(bodyDef)


class Actor
  start: ->
  turn: ->
  step: ->

class Robot extends Actor
  constructor: (@battle, @script) ->
    @worker = new Worker(@script)
    @actions = {}

    @body = @battle.createBody
      shapes: [
        { # chassis
          type: 'circle'
          density: 1
          radius: robotRadius
        }, { # right eye
          type: 'circle'
          density: 0
          radius: robotRadius/8
          localPosition: {x: robotRadius/2, y: robotRadius/4}
        }, { # left eye
          type: 'circle'
          density: 0
          radius: robotRadius/8
          localPosition: {x: robotRadius/2, y: -robotRadius/4}
        }
      ]
      position:
        x: Math.random()*(fieldWidth-robotRadius)
        y: Math.random()*(fieldHeight-robotRadius)
      linearVelocity: {y: 0.1}
      linearDamping: 0
      angularDamping: 0.05
      userData: actor: this

    # Set up actuators and make them actors
    @actuators = [new Thruster(@battle, this)]
    @battle.actors.push(actor) for actor in @actuators

  start: ->
    @worker.onmessage = (ev) =>
      @actions = _.undotterize(ev.data)

  # Every turn, the previous turn's actions are executed
  # and the robot gets updated sensor information.
  turn: ->
    for actuator in @actuators
      actuator.executePartialActions(@actions[actuator.getName()])
    @worker.postMessage(@getSensors())

  getSensors: -> {}

class Actuator extends Actor
  # The name, in lowerCamelCase, of the actuator class.
  #
  # http://blog.magnetiq.com/post/514962277/finding-out-class-names-of-javascript-objects
  getName: ->
    className = @constructor.toString().match(/function\s*(\w+)/)[1]
    className.substr(0, 1).toLowerCase() + className.substr(1)

  defaults: {}
  execute: ->
  executePartialActions: (actions) ->
    # TODO: Unsafe! Robot script can overwrite this.* members.
    _.deepExtend(this, @defaults, actions)
    @execute()

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

class Bullet extends Actor
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

class Arena extends Actor
  constructor: (@battle) ->
    bodyDef = new b2BodyDef()
    bodyDef.userData = actor: this
    wall = (width, height, x, y) =>
      shapeDef = new b2BoxDef()
      shapeDef.localPosition.Set(x, y)
      shapeDef.extents.Set(width/2, height/2)
      bodyDef.AddShape(shapeDef)
    wall(fieldWidth, wallThickness, fieldWidth/2, -wallThickness/2)               # top
    wall(fieldWidth, wallThickness, fieldWidth/2, fieldHeight + wallThickness/2)  # bottom
    wall(10, fieldHeight, -wallThickness/2, fieldHeight/2)             # left
    wall(10, fieldHeight, fieldWidth + wallThickness/2, fieldHeight/2) # right
    @body = @battle.world.CreateBody(bodyDef)


class Renderer
  constructor: (@battle) ->
    @canvas = document.getElementById('field')
    @ctx = @canvas.getContext('2d')

  start: ->
    f = =>
      @tick()
      @animation = requestAnimationFrame(f)
    @animation = requestAnimationFrame(f)
  stop: ->
    cancelAnimationFrame(@animation)

  scaleFactor: ->
    [@canvas.width / fieldWidth,
      @canvas.height / fieldHeight ]

  tick: =>
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @ctx.save()
    @ctx.scale(@scaleFactor()...)

    b = @battle.world.m_bodyList
    while b
      s = b.GetShapeList()
      while s != null
        @drawShape(s)
        s = s.GetNext()
      b = b.m_next

    @ctx.restore()

  drawShape: (shape) =>
    @ctx.beginPath()
    switch shape.m_type
      when b2Shape.e_circleShape
        @ctx.arc(shape.m_position.x, shape.m_position.y,
          shape.m_radius, 0, 2*Math.PI, false)
      when b2Shape.e_polyShape
        tV = b2Math.AddVV(shape.m_position, b2Math.b2MulMV(shape.m_R, shape.m_vertices[0]))
        @ctx.moveTo(tV.x, tV.y)
        i = 0
        while i < shape.m_vertexCount
          v = b2Math.AddVV(shape.m_position, b2Math.b2MulMV(shape.m_R, shape.m_vertices[i]))
          @ctx.lineTo(v.x, v.y)
          i++
        @ctx.lineTo(tV.x, tV.y)
      else
        console.warn('unknown b2 shape')

    @ctx.fillStyle =
      if shape.m_body.m_userData.actor instanceof Robot
        "rgba(0, 0, 255, 0.5)"
      # else if shape.m_body.actor instanceof Bullet
        # "rgba(255, 0, 0, 0.5)"
      else
        "rgba(100, 100, 100, 0.5)"
    @ctx.fill()

class Frontend
  constructor: ->
    @battle = new Battle(["/js/simple-robot.js", "/js/simple-robot.js"])
    @renderer = new Renderer(@battle)
  start: ->
    @battle.start()
    @renderer.start()

document.addEventListener "DOMContentLoaded", ->
  window.frontend = new Frontend()
  window.frontend.start()
, false
