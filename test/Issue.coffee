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
      ]
    @Issue = Issue @statusMap

  it 'should export columns', ->
    @Issue.columns.should.deep.equal
      key: 'key'
      created: 'created'
      closed: 'closed'
      leadTime: 'lead time'

  describe 'from new issue with no changelog', ->
    before ->
      @rawIssue =
        key: 'key-1'
        fields:
          created: '2015-01-20T11:19:48.633+0000'
          status:
            name: 'todo'
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

    it 'should initialise key', ->
      @issue.key.should.equal 'key-2'

    it 'should initialise display created date', ->
      @issue.created.should.equal '2015/01/20'

    it 'should initialise display closed date', ->
      @issue.closed.should.equal '2015/01/26'

    it 'should initialise lead time', ->
      @issue.leadTime.should.equal 6

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

    describe '#resolvedWithin', ->
      it 'should return false if resolved more than x days before date', ->
        date = moment '2015-01-30T11:19:48.633+0000'
        @issue.resolvedWithin(date, 3).should.be.false

      it 'should return true if resolved less than x days before date', ->
        date = moment '2015-01-29T11:19:48.633+0000'
        @issue.resolvedWithin(date, 3).should.be.false
