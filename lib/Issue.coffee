_ = require 'underscore'
moment = require 'moment'

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
      components: 'components'
      labels: 'labels'

    constructor: (rawIssue, @now) ->
      @key = rawIssue.key
      @type = rawIssue.fields.issuetype.name
      @priority = rawIssue.fields.priority.name
      @_statuses = []
      @_processCreated __initialStatus, moment rawIssue.fields.created
      @_processChange(change) for change in rawIssue.changelog.histories
      @_processClosed(
        rawIssue.fields.resolutiondate
        rawIssue.fields.resolution
      ) if rawIssue.fields.status.name in __doneStatuses

    _processCreated: (initialStatus, date) =>
      @_created = date
      @technicalDebt = @now.diff @_created, 'days'
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
      @resolution = resolution.name if resolution
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
