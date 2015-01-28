moment = require 'moment'
_ = require 'underscore'

class Issue
  constructor: (rawIssue) ->
    @assignees = []
    @statuses = []
    @processCreated moment rawIssue.fields.created
    @processChange(change) for change in rawIssue.changelog.histories
    @processClosed(moment rawIssue.fields.resolutiondate) if rawIssue.fields.status.name in ['Done', 'Closed']

  processCreated: (date) =>
    @created = date
    @assignees.push
      date: date
      assignee: null
    @statuses.push
      date: date
      status: 'To Do'

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
  constructor: (@date) ->
    @displayDate = @date.format 'YYYY/MM/DD'
    @open = 0
    @openAndAssigned = 0
    @leadTimes7Day = []
    @leadTime7DayMovingAverage = null

  addIssue: (issue) =>
    if issue.resolvedWithin(@date, 7)
      @leadTimes7Day.push issue.leadTime
      @leadTime7DayMovingAverage = (_.reduce @leadTimes7Day, (total, leadTime) => total + leadTime) / @leadTimes7Day.length
    if issue.statusOnDate(@date) in ['To Do', 'In Progress', 'Ready For Merging']
      @open++
      if issue.assigneeOnDate(@date) in ['brendan.meade', 'acampo', 'rnieuwboer', 'ajunqueira', 'alarocca']
        @openAndAssigned++

class State
  constructor: (days) ->
    now = moment()
    @days = (new Day(moment(now).subtract(day, 'days')) for day in [(days - 1)..0])

  addIssue: (rawIssue) =>
    issue  = new Issue rawIssue
    day.addIssue(issue) for day in @days

module.exports = State
