chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
chai.should()
expect = chai.expect
chai.use sinonChai

moment = require 'moment'
Day = require '../lib/Day'

describe 'Day', ->
  before ->
    @moment = moment()
    @Day = Day
      types: [
        'bug'
        'story'
        'subtask'
      ]
      priorities: [
        'p1'
        'p2'
        'p3'
      ]
      components: [
        'component1'
        'component2'
        'component3'
      ]
    @day = new @Day @moment

  it 'should export columns', ->
    @Day.columns.should.deep.equal
      date: 'date'
      open: 'open'
      technicalDebt: 'technical debt'
      leadTimeMA7: 'lead time MA7'
      cycleTimeMA7: 'cycle time MA7'
      deferredTimeMA7: 'deferred time MA7'
      'type:bug:open': 'type:bug open'
      'type:bug:technicalDebt': 'type:bug technical debt'
      'type:bug:leadTimeMA7': 'type:bug lead time MA7'
      'type:bug:cycleTimeMA7': 'type:bug cycle time MA7'
      'type:bug:deferredTimeMA7': 'type:bug deferred time MA7'
      'type:story:open': 'type:story open'
      'type:story:technicalDebt': 'type:story technical debt'
      'type:story:leadTimeMA7': 'type:story lead time MA7'
      'type:story:cycleTimeMA7': 'type:story cycle time MA7'
      'type:story:deferredTimeMA7': 'type:story deferred time MA7'
      'type:subtask:open': 'type:subtask open'
      'type:subtask:technicalDebt': 'type:subtask technical debt'
      'type:subtask:leadTimeMA7': 'type:subtask lead time MA7'
      'type:subtask:cycleTimeMA7': 'type:subtask cycle time MA7'
      'type:subtask:deferredTimeMA7': 'type:subtask deferred time MA7'

  it 'should initialise display date', ->
    @day.date.should.equal @moment.format 'YYYY/MM/DD'

  it 'should initialise open counts', ->
    @day.open.should.equal 0
    @day['type:bug:open'].should.equal 0
    @day['type:story:open'].should.equal 0
    @day['type:subtask:open'].should.equal 0

  it 'should initialise technical debt', ->
    @day.technicalDebt.should.equal 0
    @day['type:bug:technicalDebt'].should.equal 0
    @day['type:story:technicalDebt'].should.equal 0
    @day['type:subtask:technicalDebt'].should.equal 0

  it 'should initialise lead time 7 day moving average', ->
    expect(@day.leadTimeMA7).to.be.null
    expect(@day['type:bug:leadTimeMA7']).to.be.null
    expect(@day['type:story:leadTimeMA7']).to.be.null
    expect(@day['type:subtask:leadTimeMA7']).to.be.null

  it 'should initialise cycle time 7 day moving average', ->
    expect(@day.cycleTimeMA7).to.be.null
    expect(@day['type:bug:cycleTimeMA7']).to.be.null
    expect(@day['type:story:cycleTimeMA7']).to.be.null
    expect(@day['type:subtask:cycleTimeMA7']).to.be.null

  it 'should initialise deferred time 7 day moving average', ->
    expect(@day.deferredTimeMA7).to.be.null
    expect(@day['type:bug:deferredTimeMA7']).to.be.null
    expect(@day['type:story:deferredTimeMA7']).to.be.null
    expect(@day['type:subtask:deferredTimeMA7']).to.be.null

  describe '1st #addIssue', ->
    before ->
      @now = moment()
      @day = new @Day @now
      @issue =
        type: 'bug'
        leadTime: 5
        cycleTime: 3
        deferredTime: 2
        resolvedDays: sinon.spy -> 6
        openOnDate: sinon.spy -> false
        technicalDebtOnDate: sinon.spy -> 0
      @day.addIssue @issue

    it 'should correctly query the issue', ->
      @issue.openOnDate.should.have.been.calledOnce
      @issue.openOnDate.should.have.been.calledWithExactly @now
      @issue.technicalDebtOnDate.should.have.been.calledOnce
      @issue.technicalDebtOnDate.should.have.been.calledWithExactly @now
      @issue.resolvedDays.should.have.been.calledOnce
      @issue.resolvedDays.should.have.been.calledWithExactly @now

    it 'should correctly accumulate open counts', ->
      @day.open.should.equal 0
      @day['type:bug:open'].should.equal 0
      @day['type:story:open'].should.equal 0
      @day['type:subtask:open'].should.equal 0

    it 'should correctly accumulate technical debt', ->
      @day.technicalDebt.should.equal 0
      @day['type:bug:technicalDebt'].should.equal 0
      @day['type:story:technicalDebt'].should.equal 0
      @day['type:subtask:technicalDebt'].should.equal 0

    it 'should correctly accumulate lead time 7 day moving average', ->
      @day.leadTimeMA7.should.equal 5
      @day['type:bug:leadTimeMA7'].should.equal 5
      @day['type:story:leadTimeMA7'].should.equal 0
      @day['type:subtask:leadTimeMA7'].should.equal 0

    it 'should correctly accumulate cycle time 7 day moving average', ->
      @day.cycleTimeMA7.should.equal 3
      @day['type:bug:cycleTimeMA7'].should.equal 3
      @day['type:story:cycleTimeMA7'].should.equal 0
      @day['type:subtask:cycleTimeMA7'].should.equal 0

    it 'should correctly accumulate deferred time 7 day moving average', ->
      @day.deferredTimeMA7.should.equal 2
      @day['type:bug:deferredTimeMA7'].should.equal 2
      @day['type:story:deferredTimeMA7'].should.equal 0
      @day['type:subtask:deferredTimeMA7'].should.equal 0

    describe '2nd #addIssue', ->
      before ->
        @issue =
          leadTime: 3
          cycleTime: 1
          deferredTime: 2
          resolvedDays: -> 6
          openOnDate: -> false
          technicalDebtOnDate: -> 0
        @day.addIssue @issue

      it 'should correctly accumulate open count', ->
        @day.open.should.equal 0

      it 'should correctly accumulate technical debt', ->
        @day.technicalDebt.should.equal 0

      it 'should correctly accumulate lead time 7 day moving average', ->
        @day.leadTimeMA7.should.equal 4

      it 'should correctly accumulate cycle time 7 day moving average', ->
        @day.cycleTimeMA7.should.equal 2

      it 'should correctly accumulate deferred time 7 day moving average', ->
        @day.deferredTimeMA7.should.equal 2

      describe '3rd #addIssue', ->
        before ->
          @issue =
            leadTime: 20
            cycleTime: 15
            deferredTime: 5
            resolvedDays: -> 7
            openOnDate: -> false
            technicalDebtOnDate: -> 0
          @day.addIssue @issue

        it 'should correctly accumulate open count', ->
          @day.open.should.equal 0

        it 'should correctly accumulate technical debt', ->
          @day.technicalDebt.should.equal 0

        it 'should correctly accumulate lead time 7 day moving average', ->
          @day.leadTimeMA7.should.equal 4

        it 'should correctly accumulate cycle time 7 day moving average', ->
          @day.cycleTimeMA7.should.equal 2

        it 'should correctly accumulate deferred time 7 day moving average', ->
          @day.deferredTimeMA7.should.equal 2

        describe '4th #addIssue', ->
          before ->
            @issue =
              resolvedDays: -> 7
              openOnDate: -> true
              technicalDebtOnDate: -> 6
            @day.addIssue @issue

          it 'should correctly accumulate open count', ->
            @day.open.should.equal 1

          it 'should correctly accumulate technical debt', ->
            @day.technicalDebt.should.equal 6

          it 'should correctly accumulate lead time 7 day moving average', ->
            @day.leadTimeMA7.should.equal 4

          it 'should correctly accumulate cycle time 7 day moving average', ->
            @day.cycleTimeMA7.should.equal 2

# coffeelint: disable=max_line_length
          it 'should correctly accumulate deferred time 7 day moving average', ->
# coffeelint: enable=max_line_length
            @day.deferredTimeMA7.should.equal 2

          describe '5th #addIssue', ->
            before ->
              @issue =
                resolvedDays: -> 7
                openOnDate: -> true
                technicalDebtOnDate: -> 5
              @day.addIssue @issue

            it 'should correctly accumulate open count', ->
              @day.open.should.equal 2

            it 'should correctly accumulate technical debt', ->
              @day.technicalDebt.should.equal 11

            it 'should correctly accumulate lead time 7 day moving average', ->
              @day.leadTimeMA7.should.equal 4

            it 'should correctly accumulate cycle time 7 day moving average', ->
              @day.cycleTimeMA7.should.equal 2

# coffeelint: disable=max_line_length
            it 'should correctly accumulate deferred time 7 day moving average', ->
# coffeelint: enable=max_line_length
              @day.deferredTimeMA7.should.equal 2
