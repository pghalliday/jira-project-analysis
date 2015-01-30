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

    constructor: (rawIssue) ->
      @key = rawIssue.key
      @_statuses = []
      @_processCreated __initialStatus, moment rawIssue.fields.created
      @_processChange(change) for change in rawIssue.changelog.histories
      @_processClosed(
        moment rawIssue.fields.resolutiondate
      ) if rawIssue.fields.status.name in __doneStatuses

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

    _processClosed: (date) =>
      @_closed = date
      @closed = date.format 'YYYY/MM/DD'
      @leadTime = @_closed.diff @_created, 'days'

    _statusOnDate: (date) =>
      iteratee = (status, change) ->
        status = change.status if date.isAfter change.date
        status
      _.reduce @_statuses, iteratee, null

    openOnDate: (date) =>
      @_statusOnDate(date) in __openStatuses

    resolvedWithin: (date, days) =>
      start = moment(date).subtract days, 'days'
      if @_closed then @_closed.isBetween(start, date) else false
