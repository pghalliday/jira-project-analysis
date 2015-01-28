moment = require 'moment'
_ = require 'underscore'

class Issue
  constructor: (rawIssue, resolvedStatuses, initialStatus) ->
    @assignees = []
    @statuses = []
    @processCreated initialStatus, moment rawIssue.fields.created
    @processChange(change) for change in rawIssue.changelog.histories
    @processClosed(moment rawIssue.fields.resolutiondate) if rawIssue.fields.status.name in resolvedStatuses

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

  assigneeOnDate: (date) =>
    iteratee = (assignee, change) =>
      assignee = change.assignee if date.isAfter change.date
      assignee
    _.reduce @assignees, iteratee, null

  resolvedWithin: (date, days) =>
    start = moment(date).subtract days, 'days'
    @closed.isBetween(start, date) if @closed

class Day
  constructor: (@date, @openStatuses) ->
    @displayDate = @date.format 'YYYY/MM/DD'
    @open = 0
    @leadTimes7Day = []
    @leadTime7DayMovingAverage = null

  addIssue: (issue) =>
    if issue.resolvedWithin(@date, 7)
      @leadTimes7Day.push issue.leadTime
      @leadTime7DayMovingAverage = (_.reduce @leadTimes7Day, (total, leadTime) => total + leadTime) / @leadTimes7Day.length
    if issue.statusOnDate(@date) in @openStatuses
      @open++

class State
  constructor: (days, @statusMap) ->
    @statuses = @statusMap.todo.concat @statusMap.inProgress, @statusMap.done
    now = moment()
    @days = (new Day(moment(now).subtract(day, 'days'), @statusMap.todo.concat @statusMap.inProgress) for day in [(days - 1)..0])

  addIssue: (rawIssue) =>
    status = rawIssue.fields.status.name
    console.log 'WARNING: status not mapped: ' + status if status not in @statuses
    issue  = new Issue rawIssue, @statusMap.done, @initialStatus
    day.addIssue(issue) for day in @days

module.exports = State
