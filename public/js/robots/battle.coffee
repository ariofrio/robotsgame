Arena = require './arena'
Robot = require './robot'
Twenty = require './twenty'
deepExtend = require './util/deepExtend'

# Manages the battle logic and coordinates the Physics simulation
module.exports = class Battle
  constructor: (robotScripts) ->
    # No gravity, allow bodies to sleep when they come to rest.
    @world = new Twenty.World({x: 0, y: 0}, true)

    # Create the actors we have at the beginning of the battle.
    @actors = [new Arena(this)]
    for script in robotScripts
      @actors.push(new Robot(this, script))

  start: ->
    actor.start() for actor in @actors
    @time = 0
    setInterval(@step, 1.0/turnsPerSecond/stepsPerTurn)

  step: =>
    @turn() if @time % stepsPerTurn == 0
    @time++

    actor.step() for actor in @actors
    @world.step(1.0/turnsPerSecond/stepsPerTurn, iterationsPerStep)

  turn: ->
    actor.turn() for actor in @actors

