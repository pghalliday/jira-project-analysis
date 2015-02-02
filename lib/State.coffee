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
    @issues.push new @Issue rawIssue

  applyIssuesToDays: =>
    @Day.types = @Issue.types
    @Day.priorities = @Issue.priorities
    @Day.resolutions = @Issue.resolutions
    @Day.labels = @Issue.labels
    @Day.components = @Issue.components
    for issue in @issues
      day.addIssue(issue) for day in @days

module.exports = State
