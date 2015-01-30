_ = require 'underscore'

module.exports = ->
  class Day
    @columns =
      date: 'date'
      open: 'open'
      leadTime7DayMovingAverage: 'lead time (7 day moving average)'

    constructor: (@_date) ->
      @date = @_date.format 'YYYY/MM/DD'
      @open = 0
      @_leadTimes7Day = []
      @leadTime7DayMovingAverage = null

    addIssue: (issue) =>
      @_updateleadTime7DayMovingAverage issue
      @_updateOpen issue

    _updateleadTime7DayMovingAverage: (issue) =>
      if issue.resolvedWithin(@_date, 7)
        @_leadTimes7Day.push issue.leadTime
        @leadTime7DayMovingAverage = (
          _.reduce(
            @_leadTimes7Day
            (total, leadTime) -> total + leadTime
          )
        ) / @_leadTimes7Day.length

    _updateOpen: (issue) =>
      if issue.openOnDate(@_date)
        @open++
