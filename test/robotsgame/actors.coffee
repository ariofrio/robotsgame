actors = require '../../lib/robotsgame/actors'

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
  it 'can be activated', ->
    @it.should.have.property('activated')
  it 'begins deactivated', ->
    @it.activated.should.be.false

  it 'can be rotated', ->
    @it.should.have.property('rotating')
  it 'begins not rotating', ->
    @it.rotating.should.be.false

