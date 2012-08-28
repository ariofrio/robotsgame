Robot = require './robot'
Twenty = require './twenty'

module.exports = class Renderer
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
    # Make sure the browser doesn't resize our drawing (it's gross).
    @canvas.width = window.getComputedStyle(@canvas).width
    @canvas.height = window.getComputedStyle(@canvas).height

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

