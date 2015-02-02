_ = require 'underscore'

module.exports = ->
  class Day
    @columns =
      date: 'date'
      open: 'open'
      leadTime7DayMovingAverage: 'lead time (7 day moving average)'
      cycleTime7DayMovingAverage: 'cycle time (7 day moving average)'
      deferredTime7DayMovingAverage: 'deferred time (7 day moving average)'

    constructor: (@_date) ->
      @date = @_date.format 'YYYY/MM/DD'
      @open = 0
      @_leadTimes7Day = []
      @_cycleTimes7Day = []
      @_deferredTimes7Day = []
      @leadTime7DayMovingAverage = null
      @cycleTime7DayMovingAverage = null
      @deferredTime7DayMovingAverage = null

    addIssue: (issue) =>
      @_update7DayMovingAverages issue
      @_updateOpen issue

    _update7DayMovingAverages: (issue) =>
      if issue.resolvedWithin(@_date, 7)
        @_leadTimes7Day.push issue.leadTime
        @leadTime7DayMovingAverage = (
          _.reduce(
            @_leadTimes7Day
            (total, leadTime) -> total + leadTime
          )
        ) / @_leadTimes7Day.length
        @_cycleTimes7Day.push issue.cycleTime
        @cycleTime7DayMovingAverage = (
          _.reduce(
            @_cycleTimes7Day
            (total, cycleTime) -> total + cycleTime
          )
        ) / @_cycleTimes7Day.length
        @_deferredTimes7Day.push issue.deferredTime
        @deferredTime7DayMovingAverage = (
          _.reduce(
            @_deferredTimes7Day
            (total, deferredTime) -> total + deferredTime
          )
        ) / @_deferredTimes7Day.length

    _updateOpen: (issue) =>
      if issue.openOnDate(@_date)
        @open++
