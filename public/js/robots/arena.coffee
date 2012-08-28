Actor = require './actor'
Twenty = {Shape: {box}} = require './twenty'

{fieldWidth: w, fieldHeight: h, wallThickness: t} = require './settings'

module.exports = class Arena extends Actor
  constructor: (@battle) ->
    @body = new Twenty.Body(@battle.world)
    @body.fixture box([w/2, t/2], [w/2    , -t/2])   , 0 # top
    @body.fixture box([w/2, t/2], [w/2    , h + t/2]), 0 # bottom
    @body.fixture box([t/2, h/2], [-t/2   , h/2])    , 0 # left
    @body.fixture box([t/2, h/2], [w + t/2, h/2])    , 0 # right

