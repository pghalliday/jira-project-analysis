_ = require 'underscore'

class Day
  constructor: (@date, @statusMap) ->
    @displayDate = @date.format 'YYYY/MM/DD'
    @open = 0
    @leadTimes7Day = []
    @leadTime7DayMovingAverage = null

  addIssue: (issue) =>
    @updateleadTime7DayMovingAverage issue
    @updateOpen issue

  updateleadTime7DayMovingAverage: (issue) =>
    if issue.resolvedWithin(@date, 7)
      @leadTimes7Day.push issue.leadTime
      @leadTime7DayMovingAverage = (
        _.reduce(
          @leadTimes7Day
          (total, leadTime) => total + leadTime
        )
      ) / @leadTimes7Day.length

  updateOpen: (issue) =>
    if issue.openOnDate(@date)
      @open++

Day.columns =
  displayDate: 'date'
  open: 'open'
  leadTime7DayMovingAverage: 'lead time (7 day moving average)'

module.exports = Day
