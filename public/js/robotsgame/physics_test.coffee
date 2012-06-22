actors = require './actors'
require './physics'

describe 'Robot', ->
  beforeEach -> @it = new actors.Robot
  it "has static friction with the ground"
  it "has kinetic friction with the ground"
  it "can be pushed by it's components"

describe 'Thruster', ->
  beforeEach -> @it = new actors.Thruster
  it "moves when activated"
