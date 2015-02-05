_ = require 'underscore'
moment = require 'moment'

labelFieldName = (label) -> 'label_' + label
componentFieldName = (component) -> 'component_' + component

module.exports = (__statusMap, __userMap, __minimumTrustedCycleTime) ->
  __minimumTrustedCycleTime = __minimumTrustedCycleTime or 0
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
  __developers = __userMap.developers
  __users = __userMap.developers.concat(
    __userMap.ignore
  )

  class Issue
    @columns =
      key: 'key'
      status: 'status'
      created: 'created'
      closed: 'closed'
      leadTime: 'lead time'
      cycleTime: 'cycle time'
      deferredTime: 'deferred time'
      type: 'type'
      parentStatus: 'parent status'
      parentPriority: 'parent priority'
      parentType: 'parent type'
      priority: 'priority'
      resolution: 'resolution'
    @types = []
    @priorities = []
    @resolutions = []
    @labels = []
    @components = []
    @unknownUsers = []
    @unknownStatuses = []
    @_closers = {}

    constructor: (rawIssue) ->
      @key = rawIssue.key
      fields = rawIssue.fields
      changelog = rawIssue.changelog
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
      change.author.name
      @_processChangeItem(
        date
        change.author.name
        item
      ) for item in change.items

    _processChangeItem: (date, author, item) =>
      if author not in __users and author not in Issue.unknownUsers
        Issue.unknownUsers.push author
      switch item.field
        when 'assignee'
          to = item.to
          if to not in __users and to not in Issue.unknownUsers
            Issue.unknownUsers.push to
        when 'status'
          status = item.toString
          if status not in __statuses and status not in Issue.unknownStatuses
            Issue.unknownStatuses.push status
          @_statuses.push
            date: date
            status: status
          if (
            author in __developers and
            status in __doneStatuses and
            @_lastStatus not in __doneStatuses
          )
            @_closers.push author if author not in @_closers
            Issue._closers[author] = [] if not Issue._closers[author]
            closes = Issue._closers[author]
            close =
              key: @key
              unixTime: date.unix()
            insertIndex = _.sortedIndex closes, close, 'unixTime'
            closes.splice insertIndex, 0, close
          @_lastStatus = status

    _processClosed: (resolutiondate, resolution) =>
      if resolution
        @resolution = resolution.name
        resolutions = Issue.resolutions
        resolutions.push @resolution if resolutions.indexOf @resolution is -1
      if resolutiondate
        @_closed = moment resolutiondate
      else
        @_closed = @_lookupResolutionDate()
      @leadTime = @_closed.diff @_created, 'seconds'
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
            cycleTime += change.date.diff inProgressStart, 'seconds'
        cycleTime
      _.reduce @_statuses, iteratee, 0

    checkCycleTime: =>
      if @_closed
        if @cycleTime < __minimumTrustedCycleTime
          @cycleTime = 0
          for closer in @_closers
            lastClose = null
            for close in Issue._closers[closer]
              if close.key is @key
                if lastClose
                  @cycleTime += close.unixTime - lastClose.unixTime
              lastClose = close
          @deferredTime = @leadTime - @cycleTime

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
        date.diff @_created, 'seconds'
      else
        0

    resolvedDays: (date) =>
      if not @_closed
        null
      else
        date.diff @_closed, 'days'
