Box2D = require 'box2d'

util =
  set: (target, mixin) ->
    for key, value in mixin
      target["set_#{key}"] value
  vector: (v) ->
    if _.isArray(v)
      new Box2D.b2Vec2(v...)
    else
      new Box2D.b2Vec2(v.x, v.y)

# An entity represents an important Box2D object
class Entity
  constructor: -> throw "this is an abstract class"
  set: (mixin) -> util.set(@delegate, mixin)

class World extends Entity
  constructor: (gravity, sleep) ->
    @delegate = new Box2D.b2World(util.vector(gravity), sleep)

  body: (args...) -> new Body(this, args...)
  step: (args...) -> @delegate.Step(args...)

class Body extends Entity
  constructor: (parent, opts) ->
    def = new Box2D.b2BodyDef()
    util.set(def, opts)
    @delegate = parent.delegate.CreateBody(def)

  fixture: (args...) -> new Fixture(this, args...)

class Shape extends Entity
  constructor: -> throw "must not instantiate astract class"
  @circle: (args...) -> new CircleShape(args...)
  @polygon: (args...) -> new PolygonShape(args...)
  @poly: (args...) -> @polygon(args...)
  @box: (args...) -> new BoxShape(args...)

class CircleShape extends Shape
  constructor: (radius, p) ->
    @delegate = new Box2D.b2CircleShape
    @set {radius, p}

  set: (mixin) ->
    mixin.m_radius = mixin.radius
    mixin.m_p = mixin.p
    delete mixin.radius
    delete mixin.p
    super(mixin)

class PolygonShape extends Shape
  constructor: (vertices) ->
    @delegate = new Box2D.b2PolygonShape
    set {vertices}

  set: (mixin) ->
    vertices = mixin.vertices
    @delegate.Set(util.vector(v) for v in vertices) if vertices?
    delete mixin.vertices
    super mixin

class BoxShape extends PolygonShape
  constructor: (size, p, angle) -> # optional, see `set`
    super null
    set {size, p, angle}

  set: (mixin) ->
    {size, p, angle} = mixin
    if size?
      p ?= [0, 0]
      angle ?= 0
      @delegate.SetAsBox util.vector(size), util.vector(p), angle
    else if p? or angle?
      throw "cannot set the position or the angle if size is not set at the same time"
    delete mixin.size
    delete mixin.p
    delete mixin.angle
    super mixin

module.exports = {Entity, World, Body, Shape, CircleShape, PolygonShape, BoxShape}
