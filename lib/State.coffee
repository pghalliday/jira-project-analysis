moment = require 'moment'
Day = require './Day'
Issue = require './Issue'

class State
  constructor: (days, @statusMap, @initialStatus) ->
    now = moment()
    @days = (new Day(moment(now).subtract(day, 'days')) for day in [(days - 1)..0])
    @issues = []
    @dayColumns = Day.columns
    @issueColumns = Issue.columns

  addIssue: (rawIssue) =>
    issue  = new Issue rawIssue, @statusMap, @initialStatus
    @issues.push issue
    day.addIssue(issue) for day in @days

module.exports = State
