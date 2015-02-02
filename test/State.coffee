chai = require 'chai'
chai.should()
expect = chai.expect

moment = require 'moment'
State = require '../lib/State'

describe 'State', ->
  beforeEach ->
    @now = moment()
    @days = 30
    @Day = class
      constructor: (@date) ->
        @issues = []
      addIssue: (issue) =>
        @issues.push issue
    @Issue = class
      @types = ['type']
      @priorities = ['priority']
      @resolutions = ['resolution']
      @labels = ['label']
      @components = ['component']
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
    it 'should update the issues list', ->
      @state.addIssue 'Issue1'
      @state.issues.length.should.equal 1
      issue = @state.issues[0]
      issue.rawIssue.should.equal 'Issue1'
      @state.addIssue 'Issue2'
      @state.issues.length.should.equal 2
      issue = @state.issues[1]
      issue.rawIssue.should.equal 'Issue2'

  describe '#applyIssuesToDays', ->
    it 'should update the days list', ->
      @state.addIssue 'Issue1'
      @state.addIssue 'Issue2'
      @state.applyIssuesToDays()
      @Day.types.should.deep.equal ['type']
      @Day.priorities.should.deep.equal ['priority']
      @Day.resolutions.should.deep.equal ['resolution']
      @Day.labels.should.deep.equal ['label']
      @Day.components.should.deep.equal ['component']
      for i in [1..30]
        day = @state.days[30 - i]
        day.issues.length.should.equal 2
        day.issues[0].rawIssue.should.equal 'Issue1'
        day.issues[1].rawIssue.should.equal 'Issue2'
