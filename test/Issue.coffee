chai = require 'chai'
chai.should()
expect = chai.expect

moment = require 'moment'
Issue = require '../lib/Issue'

describe 'Issue', ->
  before ->
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
      ],
      ignore: [
      ]
    @userMap =
      developers: [
        'user1'
        'user2'
        'user3'
      ]
      ignore: [
        'user0'
      ]
    @Issue = Issue @statusMap, @userMap

  it 'should export initial columns', ->
    @Issue.columns.should.deep.equal [
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

  it 'should export initial unknown statuses', ->
    @Issue.unknownStatuses.should.deep.equal []

  describe 'from new issue with no changelog', ->
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-1'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          summary: 'summary 1'
          description: 'description 1'
          comment:
            comments: [
              body: 'comment 1'
            ,
              body: 'comment 2'
            ]
          status:
            name: 'unknownStatus'
          issuetype:
            name: 'sub-task'
          priority:
            name: 'p1'
          parent:
            fields:
              issuetype:
                name: 'bug'
              status:
                name: 'todo'
              priority:
                name: 'p2'
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

    it 'should initialise summary', ->
      @issue.summary.should.equal 'summary 1'

    it 'should initialise description', ->
      @issue.description.should.equal 'description 1'

    it 'should initialise comments', ->
      @issue.comments.should.equal 'comment 1 <|> comment 2'

    it 'should initialise status', ->
      @issue.status.should.equal 'unknownStatus'

    it 'should initialise display created date', ->
      @issue.created.should.equal '2015-01-20T11:19:48.633Z'

    it 'should initialise display closed date', ->
      expect(@issue.closed).to.be.undefined

    it 'should initialise lead time', ->
      expect(@issue.leadTime).to.be.undefined

    it 'should initialise cycle time', ->
      expect(@issue.cycleTime).to.be.undefined

    it 'should initialise deferred time', ->
      expect(@issue.deferredTime).to.be.undefined

    it 'should initialise type', ->
      @issue.type.should.equal 'sub-task'

    it 'should initialise priority', ->
      @issue.priority.should.equal 'p1'

    it 'should initialise resolution', ->
      expect(@issue.resolution).to.be.undefined

    it 'should initialise parent status', ->
      @issue.parentStatus.should.equal 'todo'

    it 'should initialise parent priority', ->
      @issue.parentPriority.should.equal 'p2'

    it 'should initialise parent type', ->
      @issue.parentType.should.equal 'bug'

    it 'should initialise labels', ->
      @issue['label.label1'].should.equal 'yes'
      @issue['label.label2'].should.equal 'yes'

    it 'should initialise components', ->
      @issue['component.component1'].should.equal 'yes'
      @issue['component.component2'].should.equal 'yes'

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
        'sub-task'
      ]

    it 'should append to Issue priorities', ->
      @Issue.priorities.should.deep.equal [
        'p1'
      ]

    it 'should append to Issue columns', ->
      @Issue.columns.should.deep.equal [
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
        'label.label1'
        'label.label2'
        'component.component1'
        'component.component2'
      ]

    it 'should append to Issue unknown statuses', ->
      @Issue.unknownStatuses.should.deep.equal [
        'unknownStatus'
      ]

    it 'should set the correct label fields', ->
      @issue['label.label1'].should.eql 'yes'
      @issue['label.label2'].should.eql 'yes'

    it 'should set the correct component fields', ->
      @issue['component.component1'].should.eql 'yes'
      @issue['component.component2'].should.eql 'yes'

  describe 'from closed issue', ->
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          resolutiondate: '2015-01-26T11:19:48.633+0000'
          summary: 'summary 2'
          description: 'description 2'
          comment:
            comments: [
              body: 'comment 3'
            ,
              body: 'comment 4'
            ]
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
            author:
              name: 'user0'
            created: '2015-01-21T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'unknownStatus1'
            ]
          ,
            author:
              name: 'user1'
            created: '2015-01-21T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'unknownStatus2'
            ]
          ,
            author:
              name: 'unknownUser1'
            created: '2015-01-22T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'unknownUser2'
            ]
          ,
            author:
              name: 'unknownUser2'
            created: '2015-01-24T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'in progress'
            ]
          ,
            author:
              name: 'unknownUser2'
            created: '2015-01-26T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'unknownUser3'
            ,
              field: 'status'
              toString: 'done'
            ]
          ]
      @issue = new @Issue @rawIssue

    it 'should initialise display closed date', ->
      @issue.closed.should.equal '2015-01-26T11:19:48.633Z'

    it 'should initialise lead time', ->
      @issue.leadTime.should.equal 6

    it 'should initialise cycle time', ->
      @issue.cycleTime.should.equal 2

    it 'should initialise deferred time', ->
      @issue.deferredTime.should.equal 4

    it 'should initialise resolution', ->
      @issue.resolution.should.equal 'fixed'

    it 'should initialise parent status', ->
      expect(@issue.parentStatus).to.be.undefined

    it 'should initialise parent priority', ->
      expect(@issue.parentPriority).to.be.undefined

    it 'should initialise parent type', ->
      expect(@issue.parentType).to.be.undefined

    it 'should append to Issue resolutions', ->
      @Issue.resolutions.should.deep.equal [
        'fixed'
      ]

    it 'should append to Issue unknown statuses', ->
      @Issue.unknownStatuses.should.deep.equal [
        'unknownStatus1'
        'unknownStatus2'
      ]

  describe 'from closed issue with missing resolutiondate', ->
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          summary: 'summary 3'
          description: 'description 3'
          comment:
            comments: [
              body: 'comment 5'
            ,
              body: 'comment 6'
            ]
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
            author:
              name: 'user2'
            created: '2015-01-22T11:19:48.633+0000'
            items: [
              field: 'assignee'
              to: 'user1'
            ]
          ,
            author:
              name: 'user1'
            created: '2015-01-24T11:19:48.633+0000'
            items: [
              field: 'status'
              toString: 'in progress'
            ]
          ,
            author:
              name: 'user1'
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
      @issue.closed.should.equal '2015-01-26T11:19:48.633Z'

# coffeelint: disable=max_line_length
  describe 'from closed issue with missing resolutiondate and no status changes', ->
# coffeelint: enable=max_line_length
    before ->
      @Issue = Issue @statusMap, @userMap
      @rawIssue =
        key: 'key-2'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          summary: 'summary 4'
          description: 'description 4'
          comment:
            comments: [
              body: 'comment 7'
            ,
              body: 'comment 8'
            ]
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
      @issue.closed.should.equal '2015-01-20T11:19:48.633Z'
