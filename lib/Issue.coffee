_ = require 'underscore'
moment = require 'moment'

labelFieldName = (label) -> 'label_' + label
componentFieldName = (component) -> 'component_' + component

module.exports = (statusMap) ->
  __initialStatus = statusMap.todo[0]
  __openStatuses = statusMap.todo.concat statusMap.inProgress
  __todoStatuses = statusMap.todo
  __inProgressStatuses = statusMap.inProgress
  __doneStatuses = statusMap.done

  class Issue
    @columns =
      key: 'key'
      created: 'created'
      closed: 'closed'
      leadTime: 'lead time'
      cycleTime: 'cycle time'
      deferredTime: 'deferred time'
      type: 'type'
      priority: 'priority'
      resolution: 'resolution'
    @types = []
    @priorities = []
    @resolutions = []
    @labels = []
    @components = []

    constructor: (rawIssue) ->
      @key = rawIssue.key
      fields = rawIssue.fields
      changelog = rawIssue.changelog
      @_processType fields.issuetype.name
      @_processPriority fields.priority.name
      @_processLabel label for label in fields.labels
      @_processComponent component.name for component in fields.components
      @_statuses = []
      @_processCreated __initialStatus, moment fields.created
      @_processChange(change) for change in changelog.histories
      @_processClosed(
        fields.resolutiondate
        fields.resolution
      ) if fields.status.name in __doneStatuses

    _processType: (@type) =>
      types = Issue.types
      types.push @type if types.indexOf @type is -1

    _processPriority: (@priority) =>
      priorities = Issue.priorities
      priorities.push @priority if priorities.indexOf @priority is -1

    _processLabel: (label) =>
      labels = Issue.labels
      field = labelFieldName label
      @[field] = 'yes'
      Issue.columns[field] = 'label:' + label
      labels.push label if labels.indexOf label is -1

    hasLabel: (label) => @[labelFieldName label] == 'yes'

    _processComponent: (component) =>
      components = Issue.components
      field = componentFieldName component
      @[field] = 'yes'
      Issue.columns[field] = 'component:' + component
      components.push component if components.indexOf component is -1

    affectsComponent: (component) => @[componentFieldName component] == 'yes'

    _processCreated: (initialStatus, date) =>
      @_created = date
      @created = date.format 'YYYY/MM/DD'
      @_statuses.push
        date: date
        status: initialStatus

    _processChange: (change) =>
      date = moment change.created
      @_processChangeItem(date, item) for item in change.items

    _processChangeItem: (date, item) =>
      switch item.field
        when 'status'
          @_statuses.push
            date: date
            status: item.toString

    _processClosed: (resolutiondate, resolution) =>
      if resolution
        @resolution = resolution.name
        resolutions = Issue.resolutions
        resolutions.push @resolution if resolutions.indexOf @resolution is -1
      if resolutiondate
        @_closed = moment resolutiondate
      else
        @_closed = @_lookupResolutionDate()
      @technicalDebt = 0
      @leadTime = @_closed.diff @_created, 'days'
      @cycleTime = @_calculateCycleTime()
      @deferredTime = @leadTime - @cycleTime
      @closed = @_closed.format 'YYYY/MM/DD'

    _lookupResolutionDate: =>
      resolutiondate = @_created
      index = @_statuses.length - 1
      while index >= 0 and @_statuses[index].status in __doneStatuses
        resolutiondate = @_statuses[index].date
        index--
      resolutiondate

    _calculateCycleTime: =>
      inProgress = false
      inProgressStart = null
      iteratee = (cycleTime, change) ->
        if change.status in __inProgressStatuses
          if not inProgress
            inProgress = true
            inProgressStart = change.date
        else
          if inProgress
            inProgress = false
            cycleTime += change.date.diff inProgressStart, 'days'
        cycleTime
      _.reduce @_statuses, iteratee, 0

    openOnDate: (date) =>
      if date.isBefore @_created
        false
      else
        if @_closed
          date.isBefore @_closed
        else
          true

    technicalDebtOnDate: (date) =>
      if @openOnDate date
        date.diff @_created, 'days'
      else
        0

    resolvedWithin: (date, days) =>
      start = moment(date).subtract days, 'days'
      if @_closed then @_closed.isBetween(start, date) else false
