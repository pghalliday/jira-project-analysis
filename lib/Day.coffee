_ = require 'underscore'

__movingAverageAccumulator = (field, days) ->
  (state, issueStats) ->
    if issueStats and issueStats.resolvedDays in [0..(days - 1)]
      state.push issueStats[field]
    if not state.length
      null
    else
      (
        _.reduce state, (total, value) -> total + value
      ) / state.length

__fields =
  open:
    description: 'open'
    initialState: ->
      count: 0
    accumulator: (state, issueStats) ->
      state.count++ if issueStats and issueStats.open
      state.count
  technicalDebt:
    description: 'technical debt'
    initialState: ->
      total: 0
    accumulator: (state, issueStats) ->
      state.total += issueStats.technicalDebt if issueStats
      state.total
  leadTimeMA7:
    description: 'lead time MA7'
    initialState: -> []
    accumulator: __movingAverageAccumulator 'leadTime', 7
  cycleTimeMA7:
    description: 'cycle time MA7'
    initialState: -> []
    accumulator: __movingAverageAccumulator 'cycleTime', 7
  deferredTimeMA7:
    description: 'deferred time MA7'
    initialState: -> []
    accumulator: __movingAverageAccumulator 'deferredTime', 7

__typeField = (type, field) ->
  'type:' + type + ':' + field

__typeDescription = (type, description) ->
  'type:' + type + ' ' + description

module.exports = (Issue) ->
  class Day
    @columns =
      date: 'date'

    for field, params of __fields
      description = params.description
      @columns[field] = description
      for type in Issue.types
        @columns[__typeField type, field] = __typeDescription type, description

    constructor: (@_date) ->
      @date = @_date.format 'YYYY/MM/DD'
      @_fieldStates = {}
      for field, params of __fields
        accumulator = params.accumulator
        initialState = params.initialState
        @_fieldStates[field] = initialState()
        @[field] = accumulator @_fieldStates[field]
        for type in Issue.types
          filteredField = __typeField type, field
          @_fieldStates[filteredField] = initialState()
          @[filteredField] = accumulator @_fieldStates[filteredField]

    addIssue: (issue) =>
      issueStats =
        open: issue.openOnDate @_date
        technicalDebt: issue.technicalDebtOnDate @_date
        resolvedDays: issue.resolvedDays @_date
        leadTime: issue.leadTime
        cycleTime: issue.cycleTime
        deferredTime: issue.deferredTime
      for field, params of __fields
        accumulator = params.accumulator
        @[field] = accumulator @_fieldStates[field], issueStats
        for type in Issue.types
          if type is issue.type or type is issue.parentType
            filteredField = __typeField type, field
            @[filteredField] = accumulator(
              @_fieldStates[filteredField]
              issueStats
            )
