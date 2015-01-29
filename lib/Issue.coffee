_ = require 'underscore'
moment = require 'moment'

class Issue
  constructor: (rawIssue) ->
    @key = rawIssue.key
    @_statuses = []
    @_processCreated Issue._initialStatus, moment rawIssue.fields.created
    @_processChange(change) for change in rawIssue.changelog.histories
    @_processClosed(
      moment rawIssue.fields.resolutiondate
    ) if rawIssue.fields.status.name in Issue._doneStatuses

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
    @_statusOnDate(date) in Issue._openStatuses

  resolvedWithin: (date, days) =>
    start = moment(date).subtract days, 'days'
    if @_closed then @_closed.isBetween(start, date) else false

Issue.setStatusMap = (statusMap) ->
  @_initialStatus = statusMap.todo[0]
  @_openStatuses = statusMap.todo.concat statusMap.inProgress
  @_todoStatuses = statusMap.todo
  @_inProgressStatuses = statusMap.inProgress
  @_doneStatuses = statusMap.done

Issue.columns =
  key: 'key'
  created: 'created'
  closed: 'closed'
  leadTime: 'lead time'

module.exports = Issue
