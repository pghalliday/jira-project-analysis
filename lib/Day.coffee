__movingAverageAccumulatorInitialState = ->
  total: 0
  count: 0

__movingAverageAccumulator = (field, days) ->
  (state, issueStats) ->
    if issueStats
      resolvedDays = issueStats.resolvedDays
      if resolvedDays in [0..(days - 1)]
        state.total += issueStats[field]
        state.count++
    if state.count
      state.total / state.count
    else
      null

__fields =
  open:
    initialState: ->
      count: 0
    accumulator: (state, issueStats) ->
      state.count++ if issueStats and issueStats.open
      state.count
  technicalDebt:
    initialState: ->
      total: 0
    accumulator: (state, issueStats) ->
      state.total += issueStats.technicalDebt if issueStats
      state.total
  leadTimeMA7:
    initialState: __movingAverageAccumulatorInitialState
    accumulator: __movingAverageAccumulator 'leadTime', 7
  cycleTimeMA7:
    initialState: __movingAverageAccumulatorInitialState
    accumulator: __movingAverageAccumulator 'cycleTime', 7
  deferredTimeMA7:
    initialState: __movingAverageAccumulatorInitialState
    accumulator: __movingAverageAccumulator 'deferredTime', 7

__field = (filter, name, field) ->
  filter + '.' + name + '.' + field

module.exports = (Issue) ->
  class Day
    @columns = [
      'date'
    ]

    for field, params of __fields
      @columns.push field
      for type in Issue.types
        @columns.push __field 'type', type, field
      for priority in Issue.priorities
        @columns.push __field 'priority', priority, field
      for component in Issue.components
        @columns.push __field 'component', component, field

    constructor: (@_date) ->
      @date = @_date.format 'YYYY/MM/DD'
      @_fieldStates = {}
      for field, params of __fields
        accumulator = params.accumulator
        initialState = params.initialState
        @_fieldStates[field] = initialState()
        @[field] = accumulator @_fieldStates[field]
        for type in Issue.types
          filteredField = __field 'type', type, field
          @_fieldStates[filteredField] = initialState()
          @[filteredField] = accumulator @_fieldStates[filteredField]
        for priority in Issue.priorities
          filteredField = __field 'priority', priority, field
          @_fieldStates[filteredField] = initialState()
          @[filteredField] = accumulator @_fieldStates[filteredField]
        for component in Issue.components
          filteredField = __field 'component', component, field
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
            filteredField = __field 'type', type, field
            @[filteredField] = accumulator(
              @_fieldStates[filteredField]
              issueStats
            )
        for priority in Issue.priorities
          if priority is issue.priority or priority is issue.parentPriority
            filteredField = __field 'priority', priority, field
            @[filteredField] = accumulator(
              @_fieldStates[filteredField]
              issueStats
            )
        for component in Issue.components
          if issue.affectsComponent component
            filteredField = __field 'component', component, field
            @[filteredField] = accumulator(
              @_fieldStates[filteredField]
              issueStats
            )
