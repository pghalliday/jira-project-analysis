chai = require 'chai'
chai.should()

moment = require 'moment'
Day = require '../lib/Day'

describe 'Day', ->
  it 'should pass', ->
    day = new Day moment()
    day.should.be.ok
