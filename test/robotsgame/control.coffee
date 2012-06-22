actors = require '../../lib/robotsgame/actors'
require '../../lib/robotsgame/control'

describe 'Game', ->
  beforeEach -> @it = new actors.Game
  it 'has two robots by default', ->
    @it.should.have.property('robots').with.lengthOf(2)

describe 'Robot', ->
  beforeEach -> @it = new actors.Robot
  it 'has a thruster', ->
    @it.should.have.property('thruster')

describe 'Thruster', ->
  beforeEach -> @it = new actors.Thruster
  it 'begins deactivated', ->
    @it.control.activated.should.be.false
  it 'can be activated', ->
    @it.control.activate()
    @it.control.activated.should.be.true
  it 'can be deactivated', ->
    @it.control.deactivate()
    @it.control.activated.should.be.false

