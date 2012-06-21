Controller = require '../../lib/robotsgame/controller'

describe 'Controller', ->
  describe '#constructor', ->
    it 'should by default have 2 robots', ->
      c = new Controller
      c.should.have.property('robots').with.lengthOf(2)


