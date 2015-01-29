_ = require 'underscore'
moment = require 'moment'

class Issue
  constructor: (rawIssue, @statusMap) ->
    initialStatus = @statusMap.todo[0]
    @openStatuses = @statusMap.todo.concat @statusMap.inProgress
    @assignees = []
    @statuses = []
    @processCreated initialStatus, moment rawIssue.fields.created
    @processChange(change) for change in rawIssue.changelog.histories
    @processClosed(moment rawIssue.fields.resolutiondate) if rawIssue.fields.status.name in @statusMap.done

  processCreated: (initialStatus, date) =>
    @created = date
    @assignees.push
      date: date
      assignee: null
    @statuses.push
      date: date
      status: initialStatus

  processChange: (change) =>
    date = moment change.created
    @processChangeItem(date, item) for item in change.items

  processChangeItem: (date, item) =>
    switch item.field
      when 'status'
        @statuses.push
          date: date
          status: item.toString
      when 'assignee'
        @assignees.push
          date: date
          assignee: item.to

  processClosed: (date) =>
    @closed = date
    @leadTime = @closed.diff @created, 'days'

  statusOnDate: (date) =>
    iteratee = (status, change) =>
      status = change.status if date.isAfter change.date
      status
    _.reduce @statuses, iteratee, null

  openOnDate: (date) =>
    @statusOnDate(date) in @openStatuses

  assigneeOnDate: (date) =>
    iteratee = (assignee, change) =>
      assignee = change.assignee if date.isAfter change.date
      assignee
    _.reduce @assignees, iteratee, null

  resolvedWithin: (date, days) =>
    start = moment(date).subtract days, 'days'
    @closed.isBetween(start, date) if @closed

Issue.columns = {}
module.exports = Issue
