chai = require 'chai'
chai.should()
expect = chai.expect

moment = require 'moment'
State = require '../lib/State'

describe 'State', ->
  before ->
    @now = moment()
    @days = 30
    @Day = class
      constructor: (@date) ->
        @issues = []
      addIssue: (issue) =>
        @issues.push issue
    @Issue = class
      constructor: (@rawIssue) ->
    @state = new State @now, @days, @Day, @Issue

  it 'should initialise days', ->
    @state.days.length.should.equal 30
    for i in [1..30]
      day = @state.days[30 - i]
      day.issues.should.deep.equal []
      day.date.isSame(moment(@now).subtract(i - 1, 'days')).should.be.true

  it 'should initialise issues', ->
    @state.issues.should.deep.equal []

  describe '#addIssue', ->
    it 'should update the issues and days lists', ->
      @state.addIssue 'Issue1'
      @state.issues.length.should.equal 1
      issue = @state.issues[0]
      issue.rawIssue.should.equal 'Issue1'
      for i in [1..30]
        day = @state.days[30 - i]
        day.issues.length.should.equal 1
        day.issues[0].should.equal issue
      @state.addIssue 'Issue2'
      @state.issues.length.should.equal 2
      issue = @state.issues[1]
      issue.rawIssue.should.equal 'Issue2'
      for i in [1..30]
        day = @state.days[30 - i]
        day.issues.length.should.equal 2
        day.issues[1].should.equal issue
