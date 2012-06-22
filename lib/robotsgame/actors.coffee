
class Actor
  gaits: ['control']
  constructor: ->
    for gait in @gaits
      @[gait].that = @
      @[gait].initialize?()

class Game extends Actor
class Robot extends Actor
class Thruster extends Actor

module.exports = {Actor, Game, Robot, Thruster}
