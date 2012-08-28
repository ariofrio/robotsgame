Actor = require './actor'
deepExtend = require './util/deepExtend'

# An actor that the robot can send messages to (e.g. its engines, weapons, etc.)
module.exports = class Actuator extends Actor

  # The name, in lowerCamelCase, of the actuator class.
  # http://blog.magnetiq.com/post/514962277/finding-out-class-names-of-javascript-objects
  getName: ->
    className = @constructor.toString().match(/function\s*(\w+)/)[1]
    className.substr(0, 1).toLowerCase() + className.substr(1)

  defaults: {}
  execute: ->
  executePartialActions: (actions) ->
    # TODO: Unsafe! Robot script can overwrite this.* members.
    deepExtend(this, @defaults, actions)
    @execute()

