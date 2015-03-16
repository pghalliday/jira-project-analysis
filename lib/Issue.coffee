_ = require 'underscore'
moment = require 'moment'

labelFieldName = (label) -> 'label.' + label
componentFieldName = (component) -> 'component.' + component

module.exports = (__statusMap) ->
  __initialStatus = __statusMap.todo[0]
  __openStatuses = __statusMap.todo.concat __statusMap.inProgress
  __todoStatuses = __statusMap.todo
  __inProgressStatuses = __statusMap.inProgress
  __doneStatuses = __statusMap.done
  __statuses = __statusMap.todo.concat(
    __statusMap.inProgress
    __statusMap.done
    __statusMap.ignore
  )

  class Issue
    @columns = [
      'key'
      'summary'
      'description'
      'comments'
      'status'
      'created'
      'closed'
      'leadTime'
      'cycleTime'
      'deferredTime'
      'type'
      'parentStatus'
      'parentPriority'
      'parentType'
      'priority'
      'resolution'
    ]
    @types = []
    @priorities = []
    @resolutions = []
    @labels = []
    @components = []
    @unknownStatuses = []

    constructor: (rawIssue) ->
      @key = rawIssue.key
      fields = rawIssue.fields
      changelog = rawIssue.changelog
      @summary = fields.summary
      @description = fields.description
      @_processComments fields.comment.comments
      @status = fields.status.name
      if @status not in __statuses and @status not in Issue.unknownStatuses
        Issue.unknownStatuses.push @status
      if fields.parent
        parentFields = fields.parent.fields
        @parentStatus = parentFields.status.name
        @parentPriority = parentFields.priority.name
        @parentType = parentFields.issuetype.name
      @_processType fields.issuetype.name
      @_processPriority fields.priority.name
      @_processLabel label for label in fields.labels
      @_processComponent component.name for component in fields.components
      @_statuses = []
      @_closers = []
      @_processCreated __initialStatus, moment fields.created
      @_lastStatus = __initialStatus
      @_processChange(change) for change in changelog.histories
      @_processClosed(
        fields.resolutiondate
        fields.resolution
      ) if @status in __doneStatuses

    _processComments: (comments) =>
      @comments = _.map(comments, (comment) -> comment.body).join ' <|> '

    _processType: (@type) =>
      types = Issue.types
      types.push @type if @type not in types

    _processPriority: (@priority) =>
      priorities = Issue.priorities
      priorities.push @priority if @priority not in priorities

    _processLabel: (label) =>
      labels = Issue.labels
      field = labelFieldName label
      @[field] = 'yes'
      Issue.columns.push field if field not in Issue.columns
      labels.push label if label not in labels

    _processComponent: (component) =>
      components = Issue.components
      field = componentFieldName component
      @[field] = 'yes'
      Issue.columns.push field if field not in Issue.columns
      components.push component if component not in components

    _processCreated: (initialStatus, date) =>
      @_created = date
      @created = date.toISOString()
      @_statuses.push
        date: date
        status: initialStatus

    _processChange: (change) =>
      date = moment change.created
      @_processChangeItem(
        date
        item
      ) for item in change.items

    _processChangeItem: (date, item) =>
      switch item.field
        when 'assignee'
          to = item.to
        when 'status'
          status = item.toString
          if status not in __statuses and status not in Issue.unknownStatuses
            Issue.unknownStatuses.push status
          @_statuses.push
            date: date
            status: status

    _processClosed: (resolutiondate, resolution) =>
      if resolution
        @resolution = resolution.name
        resolutions = Issue.resolutions
        resolutions.push @resolution if @resolution not in resolutions
      if resolutiondate
        @_closed = moment resolutiondate
      else
        @_closed = @_lookupResolutionDate()
      @leadTime = @_closed.diff @_created, 'days', true
      @cycleTime = @_calculateCycleTime()
      @deferredTime = @leadTime - @cycleTime
      @closed = @_closed.toISOString()

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
            cycleTime += change.date.diff inProgressStart, 'days', true
        cycleTime
      _.reduce @_statuses, iteratee, 0
