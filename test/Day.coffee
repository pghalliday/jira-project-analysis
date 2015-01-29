chai = require 'chai'
chai.should()
expect = chai.expect

moment = require 'moment'
Day = require '../lib/Day'

describe 'Day', ->
  beforeEach ->
    @moment = moment()
    @day = new Day @moment

  it 'should initialise fields', ->
    @day.should.be.ok
    @day.displayDate.should.equal @moment.format 'YYYY/MM/DD'
    @day.open.should.equal 0
    expect(@day.leadTime7DayMovingAverage).to.be.null

  describe '#addIssue', ->
    it 'should ', ->
