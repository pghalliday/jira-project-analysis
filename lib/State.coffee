moment = require 'moment'

class State
  constructor: (@now, days, @Day, @Issue) ->
    @days = (
      new @Day(
        moment(@now).subtract(day, 'days')
      ) for day in [(days - 1)..0]
    )
    @issues = []

  addIssue: (rawIssue) =>
    issue  = new @Issue rawIssue, @now
    @issues.push issue
    day.addIssue(issue) for day in @days

module.exports = State
