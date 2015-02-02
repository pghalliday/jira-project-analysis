chai = require 'chai'
chai.should()
expect = chai.expect

moment = require 'moment'
Issue = require '../lib/Issue'

describe 'Issue', ->
  before ->
    @now = moment '2015-02-01T11:19:48.633+0000'
    @statusMap =
      todo: [
        'todo'
        'open'
      ]
      inProgress: [
        'in progress'
        'ready for merging'
      ]
      done: [
        'done'
        'closed'
      ]
    @Issue = Issue @statusMap

  it 'should export initial columns', ->
    @Issue.columns.should.deep.equal
      key: 'key'
      created: 'created'
      closed: 'closed'
      leadTime: 'lead time'
      cycleTime: 'cycle time'
      deferredTime: 'deferred time'
      type: 'type'
      priority: 'priority'
      resolution: 'resolution'

  it 'should export initial labels', ->
    @Issue.labels.should.deep.equal []

  it 'should export initial components', ->
    @Issue.components.should.deep.equal []

  it 'should export initial types', ->
    @Issue.types.should.deep.equal []

  it 'should export initial priorities', ->
    @Issue.priorities.should.deep.equal []

  it 'should export initial resolutions', ->
    @Issue.resolutions.should.deep.equal []

  describe 'from new issue with no changelog', ->
    before ->
      @rawIssue =
        key: 'key-1'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'todo'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: []
      @issue = new @Issue @rawIssue

    it 'should initialise key', ->
      @issue.key.should.equal 'key-1'

    it 'should initialise display created date', ->
      @issue.created.should.equal '2015/01/20'

    it 'should initialise display closed date', ->
      expect(@issue.closed).to.be.undefined

    it 'should initialise lead time', ->
      expect(@issue.leadTime).to.be.undefined

    it 'should initialise cycle time', ->
      expect(@issue.cycleTime).to.be.undefined

    it 'should initialise deferred time', ->
      expect(@issue.deferredTime).to.be.undefined

    it 'should initialise type', ->
      @issue.type.should.equal 'bug'

    it 'should initialise priority', ->
      @issue.priority.should.equal 'p1'

    it 'should initialise resolution', ->
      expect(@issue.resolution).to.be.undefined

    it 'should initialise labels', ->
      @issue.label_label1.should.equal 'yes'
      @issue.label_label2.should.equal 'yes'

    it 'should initialise components', ->
      @issue.component_component1.should.equal 'yes'
      @issue.component_component2.should.equal 'yes'

    it 'should append to Issue labels', ->
      @Issue.labels.should.deep.equal [
        'label1'
        'label2'
      ]

    it 'should append to Issue components', ->
      @Issue.components.should.deep.equal [
        'component1'
        'component2'
      ]

    it 'should append to Issue types', ->
      @Issue.types.should.deep.equal [
        'bug'
      ]

    it 'should append to Issue priorities', ->
      @Issue.priorities.should.deep.equal [
        'p1'
      ]

    it 'should append to Issue columns', ->
      @Issue.columns.should.deep.equal
        key: 'key'
        created: 'created'
        closed: 'closed'
        leadTime: 'lead time'
        cycleTime: 'cycle time'
        deferredTime: 'deferred time'
        type: 'type'
        priority: 'priority'
        resolution: 'resolution'
        label_label1: 'label:label1'
        label_label2: 'label:label2'
        component_component1: 'component:component1'
        component_component2: 'component:component2'

    describe '#hasLabel', ->
      it 'should return true if issue has label', ->
        @issue.hasLabel('label1').should.be.true

      it 'should return false if issue does not have label', ->
        @issue.hasLabel('label3').should.be.false

    describe '#affectsComponent', ->
      it 'should return true if issue affects component', ->
        @issue.affectsComponent('component1').should.be.true

      it 'should return false if issue does not affect component', ->
        @issue.affectsComponent('component3').should.be.false

    describe '#openOnDate', ->
      it 'should return true if date is after created', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.true

    describe '#technicalDebtOnDate', ->
      it 'should return 0 if date is before created', ->
        date = moment '2015-01-19T11:19:48.633+0000'
        @issue.technicalDebtOnDate(date).should.equal 0

      it 'should return number of days open if date is after created', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.technicalDebtOnDate(date).should.equal 2

    describe '#resolvedWithin', ->
      it 'should return false if issue is not done', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.resolvedWithin(date, 7).should.be.false

  describe 'from closed issue', ->
    before ->
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          resolutiondate: '2015-01-26T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: [
            created: '2015-01-22T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user1'
            ]
          ,
            created: '2015-01-24T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'in progress'
            ]
          ,
            created: '2015-01-26T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user2'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date', ->
      @issue.closed.should.equal '2015/01/26'

    it 'should initialise lead time', ->
      @issue.leadTime.should.equal 6

    it 'should initialise cycle time', ->
      @issue.cycleTime.should.equal 2

    it 'should initialise deferred time', ->
      @issue.deferredTime.should.equal 4

    it 'should initialise resolution', ->
      @issue.resolution.should.equal 'fixed'

    it 'should append to Issue resolutions', ->
      @Issue.resolutions.should.deep.equal [
        'fixed'
      ]

    describe '#openOnDate', ->
      it 'should return false if date is before created', ->
        date = moment '2015-01-19T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.false

      it 'should return true if date is between created and done', ->
        date = moment '2015-01-22T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.true

      it 'should return false if date is after done', ->
        date = moment '2015-01-27T11:19:48.633+0000'
        @issue.openOnDate(date).should.be.false

    describe '#technicalDebtOnDate', ->
      it 'should return 0 if date is after done', ->
        date = moment '2015-01-27T11:19:48.633+0000'
        @issue.technicalDebtOnDate(date).should.equal 0

    describe '#resolvedWithin', ->
      it 'should return false if resolved more than x days before date', ->
        date = moment '2015-01-30T11:19:48.633+0000'
        @issue.resolvedWithin(date, 3).should.be.false

      it 'should return true if resolved less than x days before date', ->
        date = moment '2015-01-29T11:19:48.633+0000'
        @issue.resolvedWithin(date, 3).should.be.false

  describe 'from closed issue with missing resolutiondate', ->
    before ->
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          resolution:
            name: 'fixed'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: [
            created: '2015-01-22T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user1'
            ]
          ,
            created: '2015-01-24T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'in progress'
            ]
          ,
            created: '2015-01-26T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user2'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date', ->
      @issue.closed.should.equal '2015/01/26'

# coffeelint: disable=max_line_length
  describe 'from closed issue with missing resolutiondate and no status changes', ->
# coffeelint: enable=max_line_length
    before ->
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'done'
          issuetype:
            name: 'bug'
          priority:
            name: 'p1'
          labels: [
            'label1'
            'label2'
          ]
          components: [
            name: 'component1'
          ,
            name: 'component2'
          ]
        changelog:
          histories: []
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date to equal the created date', ->
      @issue.closed.should.equal '2015/01/20'
