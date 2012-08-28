Actor = require './actor'
Thruster = require './thruster'
dotter = require './util/dotter'
Twenty = {circle} = require './twenty'
{robotRadius: r, fieldWidth: w, fieldHeight: h} = require './settings'

module.exports = class Robot extends Actor
  constructor: (@battle, @script) ->
    @body = new Twenty.Body @battle.world,
      position: {x: Math.random()*(w-r), y: Math.random()*(h-r)}

    @body.fixture circle(r), 1               # chassis
    @body.fixture circle(r/8, r/2, r/4), 0   # right eye
    @body.fixture circle(r/8, r/2, -r/4), 0  # left eye

    @worker = new Worker(@script)
    @actions = {}

    # Set up actuators and make them actors
    @actuators = [new Thruster(@battle, this)]
    @battle.actors.push(actor) for actor in @actuators

  start: ->
    @worker.onmessage = (ev) =>
      @actions = dotter.toTree(ev.data)

  turn: ->
    # execute actions from previous turn
    for actuator in @actuators
      actuator.executePartialActions(@actions[actuator.getName()])

    # send updated sensor information
    @worker.postMessage({})

