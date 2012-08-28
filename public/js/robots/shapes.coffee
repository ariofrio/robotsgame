Box2D = require 'box2d'

module.exports =
  box: (w, h, x = 0, y = 0, angle = 0) ->
    shape = new Box2D.b2PolygonShape()
    shape.SetAsBox(w, h, x, y, angle)
    shape

