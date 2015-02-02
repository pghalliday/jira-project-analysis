chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.should()
expect = chai.expect
chai.use sinonChai

moment = require 'moment'
Day = require '../lib/Day'

describe 'Day', ->
  before ->
    @moment = moment()
    @Day = Day()
    @day = new @Day @moment

  it 'should export columns', ->
    @Day.columns.should.deep.equal
      date: 'date'
      open: 'open'
      leadTime7DayMovingAverage: 'lead time (7 day moving average)'
      cycleTime7DayMovingAverage: 'cycle time (7 day moving average)'
      deferredTime7DayMovingAverage: 'deferred time (7 day moving average)'

  it 'should initialise display date', ->
    @day.date.should.equal @moment.format 'YYYY/MM/DD'

  it 'should initialise open count', ->
    @day.open.should.equal 0

  it 'should initialise lead time 7 day moving average', ->
    expect(@day.leadTime7DayMovingAverage).to.be.null

  it 'should initialise cycle time 7 day moving average', ->
    expect(@day.cycleTime7DayMovingAverage).to.be.null

  it 'should initialise deferred time 7 day moving average', ->
    expect(@day.deferredTime7DayMovingAverage).to.be.null

  describe '#addIssue', ->
    it 'should correctly accumulate fields', ->
      now = moment()
      day = new @Day now
      issue =
        leadTime: 5
        cycleTime: 3
        deferredTime: 2
        resolvedWithin: sinon.spy -> true
        openOnDate: sinon.spy -> false
      day.addIssue issue
      issue.openOnDate.should.have.been.calledOnce
      day.open.should.equal 0
      issue.resolvedWithin.should.have.been.calledOnce
      issue.resolvedWithin.should.have.been.calledWithExactly now, 7
      day.leadTime7DayMovingAverage.should.equal 5
      day.cycleTime7DayMovingAverage.should.equal 3
      day.deferredTime7DayMovingAverage.should.equal 2
      issue =
        leadTime: 3
        cycleTime: 1
        deferredTime: 2
        resolvedWithin: sinon.spy -> true
        openOnDate: sinon.spy -> false
      day.addIssue issue
      issue.openOnDate.should.have.been.calledOnce
      day.open.should.equal 0
      issue.resolvedWithin.should.have.been.calledOnce
      issue.resolvedWithin.should.have.been.calledWithExactly now, 7
      day.leadTime7DayMovingAverage.should.equal 4
      day.cycleTime7DayMovingAverage.should.equal 2
      day.deferredTime7DayMovingAverage.should.equal 2
      issue =
        leadTime: 20
        cycleTime: 7
        deferredTime: 13
        resolvedWithin: sinon.spy -> false
        openOnDate: sinon.spy -> true
      day.addIssue issue
      issue.openOnDate.should.have.been.calledOnce
      day.open.should.equal 1
      issue.resolvedWithin.should.have.been.calledOnce
      issue.resolvedWithin.should.have.been.calledWithExactly now, 7
      day.leadTime7DayMovingAverage.should.equal 4
      day.cycleTime7DayMovingAverage.should.equal 2
      day.deferredTime7DayMovingAverage.should.equal 2
      issue =
        leadTime: 20
        cycleTime: 5
        deferredTime: 15
        resolvedWithin: sinon.spy -> false
        openOnDate: sinon.spy -> true
      day.addIssue issue
      issue.openOnDate.should.have.been.calledOnce
      day.open.should.equal 2
      issue.resolvedWithin.should.have.been.calledOnce
      issue.resolvedWithin.should.have.been.calledWithExactly now, 7
      day.leadTime7DayMovingAverage.should.equal 4
      day.cycleTime7DayMovingAverage.should.equal 2
      day.deferredTime7DayMovingAverage.should.equal 2
