
# An actor has some kind of rendering, is affected by the physics engine,
# and contains some control logic.
class Actor
  gaits: ['control', 'physics', 'rendering']
  constructor: ->
    for gait in @gaits
      if @[gait]?
        @[gait].that = @
        @[gait].initialize?()

# The game has two robots by default. It renders the arena. It has no physics
# logic.
class Game extends Actor
  constructor: ->
    @robots = [new Robot, new Robot]
    super()

# A robot is in contact with the ground (which exerts kinetic AND static
# friction on it). It has a thruster.
class Robot extends Actor
  constructor: ->
    @thruster = new Thruster
    super()

# A thruster exerts a constant, fixed force on the robot when turned on and can
# be rotated at a constant, fixed velocity.
class Thruster extends Actor
  activated: no
  rotating: no

module.exports = {Actor, Game, Robot, Thruster}
