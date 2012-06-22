actors = require './actors'

actors.Game.prototype.control =
  initialize: ->
    @that.robots = [new actors.Robot, new actors.Robot]

actors.Robot.prototype.control =
  initialize: ->
    @that.thruster = new actors.Thruster

actors.Thruster.prototype.control =
  activated: false
  activate: ->
    @activated = true
  deactivate: ->
    @activated = false


