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
        'unprioritized'
        'p1'
        'p2'
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
# coffeelint: disable=max_line_length
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
      'priority:unprioritized:open': 'priority:unprioritized open'
      'priority:unprioritized:technicalDebt': 'priority:unprioritized technical debt'
      'priority:unprioritized:leadTimeMA7': 'priority:unprioritized lead time MA7'
      'priority:unprioritized:cycleTimeMA7': 'priority:unprioritized cycle time MA7'
      'priority:unprioritized:deferredTimeMA7': 'priority:unprioritized deferred time MA7'
      'priority:p1:open': 'priority:p1 open'
      'priority:p1:technicalDebt': 'priority:p1 technical debt'
      'priority:p1:leadTimeMA7': 'priority:p1 lead time MA7'
      'priority:p1:cycleTimeMA7': 'priority:p1 cycle time MA7'
      'priority:p1:deferredTimeMA7': 'priority:p1 deferred time MA7'
      'priority:p2:open': 'priority:p2 open'
      'priority:p2:technicalDebt': 'priority:p2 technical debt'
      'priority:p2:leadTimeMA7': 'priority:p2 lead time MA7'
      'priority:p2:cycleTimeMA7': 'priority:p2 cycle time MA7'
      'priority:p2:deferredTimeMA7': 'priority:p2 deferred time MA7'
      'component:component1:open': 'component:component1 open'
      'component:component1:technicalDebt': 'component:component1 technical debt'
      'component:component1:leadTimeMA7': 'component:component1 lead time MA7'
      'component:component1:cycleTimeMA7': 'component:component1 cycle time MA7'
      'component:component1:deferredTimeMA7': 'component:component1 deferred time MA7'
      'component:component2:open': 'component:component2 open'
      'component:component2:technicalDebt': 'component:component2 technical debt'
      'component:component2:leadTimeMA7': 'component:component2 lead time MA7'
      'component:component2:cycleTimeMA7': 'component:component2 cycle time MA7'
      'component:component2:deferredTimeMA7': 'component:component2 deferred time MA7'
      'component:component3:open': 'component:component3 open'
      'component:component3:technicalDebt': 'component:component3 technical debt'
      'component:component3:leadTimeMA7': 'component:component3 lead time MA7'
      'component:component3:cycleTimeMA7': 'component:component3 cycle time MA7'
      'component:component3:deferredTimeMA7': 'component:component3 deferred time MA7'
# coffeelint: enable=max_line_length

  it 'should initialise display date', ->
    @day.date.should.equal @moment.format 'YYYY/MM/DD'

  it 'should initialise open counts', ->
    @day.open.should.equal 0
    @day['type:bug:open'].should.equal 0
    @day['type:story:open'].should.equal 0
    @day['type:subtask:open'].should.equal 0
    @day['priority:unprioritized:open'].should.equal 0
    @day['priority:p1:open'].should.equal 0
    @day['priority:p2:open'].should.equal 0
    @day['component:component1:open'].should.equal 0
    @day['component:component2:open'].should.equal 0
    @day['component:component3:open'].should.equal 0

  it 'should initialise technical debt', ->
    @day.technicalDebt.should.equal 0
    @day['type:bug:technicalDebt'].should.equal 0
    @day['type:story:technicalDebt'].should.equal 0
    @day['type:subtask:technicalDebt'].should.equal 0
    @day['priority:unprioritized:technicalDebt'].should.equal 0
    @day['priority:p1:technicalDebt'].should.equal 0
    @day['priority:p2:technicalDebt'].should.equal 0
    @day['component:component1:technicalDebt'].should.equal 0
    @day['component:component2:technicalDebt'].should.equal 0
    @day['component:component3:technicalDebt'].should.equal 0

  it 'should initialise lead time 7 day moving average', ->
    expect(@day.leadTimeMA7).to.be.null
    expect(@day['type:bug:leadTimeMA7']).to.be.null
    expect(@day['type:story:leadTimeMA7']).to.be.null
    expect(@day['type:subtask:leadTimeMA7']).to.be.null
    expect(@day['priority:unprioritized:leadTimeMA7']).to.be.null
    expect(@day['priority:p1:leadTimeMA7']).to.be.null
    expect(@day['priority:p2:leadTimeMA7']).to.be.null
    expect(@day['component:component1:leadTimeMA7']).to.be.null
    expect(@day['component:component2:leadTimeMA7']).to.be.null
    expect(@day['component:component3:leadTimeMA7']).to.be.null

  it 'should initialise cycle time 7 day moving average', ->
    expect(@day.cycleTimeMA7).to.be.null
    expect(@day['type:bug:cycleTimeMA7']).to.be.null
    expect(@day['type:story:cycleTimeMA7']).to.be.null
    expect(@day['type:subtask:cycleTimeMA7']).to.be.null
    expect(@day['priority:unprioritized:cycleTimeMA7']).to.be.null
    expect(@day['priority:p1:cycleTimeMA7']).to.be.null
    expect(@day['priority:p2:cycleTimeMA7']).to.be.null
    expect(@day['component:component1:cycleTimeMA7']).to.be.null
    expect(@day['component:component2:cycleTimeMA7']).to.be.null
    expect(@day['component:component3:cycleTimeMA7']).to.be.null

  it 'should initialise deferred time 7 day moving average', ->
    expect(@day.deferredTimeMA7).to.be.null
    expect(@day['type:bug:deferredTimeMA7']).to.be.null
    expect(@day['type:story:deferredTimeMA7']).to.be.null
    expect(@day['type:subtask:deferredTimeMA7']).to.be.null
    expect(@day['priority:unprioritized:deferredTimeMA7']).to.be.null
    expect(@day['priority:p1:deferredTimeMA7']).to.be.null
    expect(@day['priority:p2:deferredTimeMA7']).to.be.null
    expect(@day['component:component1:deferredTimeMA7']).to.be.null
    expect(@day['component:component2:deferredTimeMA7']).to.be.null
    expect(@day['component:component3:deferredTimeMA7']).to.be.null

  describe '1st #addIssue', ->
    before ->
      @now = moment()
      @day = new @Day @now
      @issue =
        type: 'bug'
        priority: 'p1'
        affectsComponent: (component) -> component in [
          'component1'
          'component3'
        ]
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
      @day['priority:unprioritized:open'].should.equal 0
      @day['priority:p1:open'].should.equal 0
      @day['priority:p2:open'].should.equal 0
      @day['component:component1:open'].should.equal 0
      @day['component:component2:open'].should.equal 0
      @day['component:component3:open'].should.equal 0

    it 'should correctly accumulate technical debt', ->
      @day.technicalDebt.should.equal 0
      @day['type:bug:technicalDebt'].should.equal 0
      @day['type:story:technicalDebt'].should.equal 0
      @day['type:subtask:technicalDebt'].should.equal 0
      @day['priority:unprioritized:technicalDebt'].should.equal 0
      @day['priority:p1:technicalDebt'].should.equal 0
      @day['priority:p2:technicalDebt'].should.equal 0
      @day['component:component1:technicalDebt'].should.equal 0
      @day['component:component2:technicalDebt'].should.equal 0
      @day['component:component3:technicalDebt'].should.equal 0

    it 'should correctly accumulate lead time 7 day moving average', ->
      @day.leadTimeMA7.should.equal 5
      @day['type:bug:leadTimeMA7'].should.equal 5
      expect(@day['type:story:leadTimeMA7']).to.be.null
      expect(@day['type:subtask:leadTimeMA7']).to.be.null
      expect(@day['priority:unprioritized:leadTimeMA7']).to.be.null
      @day['priority:p1:leadTimeMA7'].should.equal 5
      expect(@day['priority:p2:leadTimeMA7']).to.be.null
      @day['component:component1:leadTimeMA7'].should.equal 5
      expect(@day['component:component2:leadTimeMA7']).to.be.null
      @day['component:component3:leadTimeMA7'].should.equal 5

    it 'should correctly accumulate cycle time 7 day moving average', ->
      @day.cycleTimeMA7.should.equal 3
      @day['type:bug:cycleTimeMA7'].should.equal 3
      expect(@day['type:story:cycleTimeMA7']).to.be.null
      expect(@day['type:subtask:cycleTimeMA7']).to.be.null
      expect(@day['priority:unprioritized:cycleTimeMA7']).to.be.null
      @day['priority:p1:cycleTimeMA7'].should.equal 3
      expect(@day['priority:p2:cycleTimeMA7']).to.be.null
      @day['component:component1:cycleTimeMA7'].should.equal 3
      expect(@day['component:component2:cycleTimeMA7']).to.be.null
      @day['component:component3:cycleTimeMA7'].should.equal 3

    it 'should correctly accumulate deferred time 7 day moving average', ->
      @day.deferredTimeMA7.should.equal 2
      @day['type:bug:deferredTimeMA7'].should.equal 2
      expect(@day['type:story:deferredTimeMA7']).to.be.null
      expect(@day['type:subtask:deferredTimeMA7']).to.be.null
      expect(@day['priority:unprioritized:deferredTimeMA7']).to.be.null
      @day['priority:p1:deferredTimeMA7'].should.equal 2
      expect(@day['priority:p2:deferredTimeMA7']).to.be.null
      @day['component:component1:deferredTimeMA7'].should.equal 2
      expect(@day['component:component2:deferredTimeMA7']).to.be.null
      @day['component:component3:deferredTimeMA7'].should.equal 2

    describe '2nd #addIssue', ->
      before ->
        @issue =
          type: 'story'
          priority: 'p2'
          affectsComponent: (component) -> component in [
            'component2'
            'component3'
          ]
          leadTime: 3
          cycleTime: 1
          deferredTime: 2
          resolvedDays: -> 6
          openOnDate: -> false
          technicalDebtOnDate: -> 0
        @day.addIssue @issue

      it 'should correctly accumulate open count', ->
        @day.open.should.equal 0
        @day['type:bug:open'].should.equal 0
        @day['type:story:open'].should.equal 0
        @day['type:subtask:open'].should.equal 0
        @day['priority:unprioritized:open'].should.equal 0
        @day['priority:p1:open'].should.equal 0
        @day['priority:p2:open'].should.equal 0
        @day['component:component1:open'].should.equal 0
        @day['component:component2:open'].should.equal 0
        @day['component:component3:open'].should.equal 0

      it 'should correctly accumulate technical debt', ->
        @day.technicalDebt.should.equal 0
        @day['type:bug:technicalDebt'].should.equal 0
        @day['type:story:technicalDebt'].should.equal 0
        @day['type:subtask:technicalDebt'].should.equal 0
        @day['priority:unprioritized:technicalDebt'].should.equal 0
        @day['priority:p1:technicalDebt'].should.equal 0
        @day['priority:p2:technicalDebt'].should.equal 0
        @day['component:component1:technicalDebt'].should.equal 0
        @day['component:component2:technicalDebt'].should.equal 0
        @day['component:component3:technicalDebt'].should.equal 0

      it 'should correctly accumulate lead time 7 day moving average', ->
        @day.leadTimeMA7.should.equal 4
        @day['type:bug:leadTimeMA7'].should.equal 5
        @day['type:story:leadTimeMA7'].should.equal 3
        expect(@day['type:subtask:leadTimeMA7']).to.be.null
        expect(@day['priority:unprioritized:leadTimeMA7']).to.be.null
        @day['priority:p1:leadTimeMA7'].should.equal 5
        @day['priority:p2:leadTimeMA7'].should.equal 3
        @day['component:component1:leadTimeMA7'].should.equal 5
        @day['component:component2:leadTimeMA7'].should.equal 3
        @day['component:component3:leadTimeMA7'].should.equal 4

      it 'should correctly accumulate cycle time 7 day moving average', ->
        @day.cycleTimeMA7.should.equal 2
        @day['type:bug:cycleTimeMA7'].should.equal 3
        @day['type:story:cycleTimeMA7'].should.equal 1
        expect(@day['type:subtask:cycleTimeMA7']).to.be.null
        expect(@day['priority:unprioritized:cycleTimeMA7']).to.be.null
        @day['priority:p1:cycleTimeMA7'].should.equal 3
        @day['priority:p2:cycleTimeMA7'].should.equal 1
        @day['component:component1:cycleTimeMA7'].should.equal 3
        @day['component:component2:cycleTimeMA7'].should.equal 1
        @day['component:component3:cycleTimeMA7'].should.equal 2

      it 'should correctly accumulate deferred time 7 day moving average', ->
        @day.deferredTimeMA7.should.equal 2
        @day['type:bug:deferredTimeMA7'].should.equal 2
        @day['type:story:deferredTimeMA7'].should.equal 2
        expect(@day['type:subtask:deferredTimeMA7']).to.be.null
        expect(@day['priority:unprioritized:deferredTimeMA7']).to.be.null
        @day['priority:p1:deferredTimeMA7'].should.equal 2
        @day['priority:p2:deferredTimeMA7'].should.equal 2
        @day['component:component1:deferredTimeMA7'].should.equal 2
        @day['component:component2:deferredTimeMA7'].should.equal 2
        @day['component:component3:deferredTimeMA7'].should.equal 2

      describe '3rd #addIssue', ->
        before ->
          @issue =
            type: 'bug'
            priority: 'unprioritized'
            affectsComponent: (component) -> component in [
              'component1'
              'component2'
            ]
            resolvedDays: -> null
            openOnDate: -> false
            technicalDebtOnDate: -> 0
          @day.addIssue @issue

        it 'should correctly accumulate open count', ->
          @day.open.should.equal 0
          @day['type:bug:open'].should.equal 0
          @day['type:story:open'].should.equal 0
          @day['type:subtask:open'].should.equal 0
          @day['priority:unprioritized:open'].should.equal 0
          @day['priority:p1:open'].should.equal 0
          @day['priority:p2:open'].should.equal 0
          @day['component:component1:open'].should.equal 0
          @day['component:component2:open'].should.equal 0
          @day['component:component3:open'].should.equal 0

        it 'should correctly accumulate technical debt', ->
          @day.technicalDebt.should.equal 0
          @day['type:bug:technicalDebt'].should.equal 0
          @day['type:story:technicalDebt'].should.equal 0
          @day['type:subtask:technicalDebt'].should.equal 0
          @day['priority:unprioritized:technicalDebt'].should.equal 0
          @day['priority:p1:technicalDebt'].should.equal 0
          @day['priority:p2:technicalDebt'].should.equal 0
          @day['component:component1:technicalDebt'].should.equal 0
          @day['component:component2:technicalDebt'].should.equal 0
          @day['component:component3:technicalDebt'].should.equal 0

        it 'should correctly accumulate lead time 7 day moving average', ->
          @day.leadTimeMA7.should.equal 4
          @day['type:bug:leadTimeMA7'].should.equal 5
          @day['type:story:leadTimeMA7'].should.equal 3
          expect(@day['type:subtask:leadTimeMA7']).to.be.null
          expect(@day['priority:unprioritized:leadTimeMA7']).to.be.null
          @day['priority:p1:leadTimeMA7'].should.equal 5
          @day['priority:p2:leadTimeMA7'].should.equal 3
          @day['component:component1:leadTimeMA7'].should.equal 5
          @day['component:component2:leadTimeMA7'].should.equal 3
          @day['component:component3:leadTimeMA7'].should.equal 4

        it 'should correctly accumulate cycle time 7 day moving average', ->
          @day.cycleTimeMA7.should.equal 2
          @day['type:bug:cycleTimeMA7'].should.equal 3
          @day['type:story:cycleTimeMA7'].should.equal 1
          expect(@day['type:subtask:cycleTimeMA7']).to.be.null
          expect(@day['priority:unprioritized:cycleTimeMA7']).to.be.null
          @day['priority:p1:cycleTimeMA7'].should.equal 3
          @day['priority:p2:cycleTimeMA7'].should.equal 1
          @day['component:component1:cycleTimeMA7'].should.equal 3
          @day['component:component2:cycleTimeMA7'].should.equal 1
          @day['component:component3:cycleTimeMA7'].should.equal 2

        it 'should correctly accumulate deferred time 7 day moving average', ->
          @day.deferredTimeMA7.should.equal 2
          @day['type:bug:deferredTimeMA7'].should.equal 2
          @day['type:story:deferredTimeMA7'].should.equal 2
          expect(@day['type:subtask:deferredTimeMA7']).to.be.null
          expect(@day['priority:unprioritized:deferredTimeMA7']).to.be.null
          @day['priority:p1:deferredTimeMA7'].should.equal 2
          @day['priority:p2:deferredTimeMA7'].should.equal 2
          @day['component:component1:deferredTimeMA7'].should.equal 2
          @day['component:component2:deferredTimeMA7'].should.equal 2
          @day['component:component3:deferredTimeMA7'].should.equal 2

        describe '4th #addIssue', ->
          before ->
            @issue =
              type: 'subtask'
              parentType: 'bug'
              priority: 'unprioritized'
              parentPriority: 'p2'
              affectsComponent: (component) -> component in [
                'component1'
                'component2'
              ]
              resolvedDays: -> 7
              openOnDate: -> true
              technicalDebtOnDate: -> 6
            @day.addIssue @issue

          it 'should correctly accumulate open count', ->
            @day.open.should.equal 1
            @day['type:bug:open'].should.equal 1
            @day['type:story:open'].should.equal 0
            @day['type:subtask:open'].should.equal 1
            @day['priority:unprioritized:open'].should.equal 1
            @day['priority:p1:open'].should.equal 0
            @day['priority:p2:open'].should.equal 1
            @day['component:component1:open'].should.equal 1
            @day['component:component2:open'].should.equal 1
            @day['component:component3:open'].should.equal 0

          it 'should correctly accumulate technical debt', ->
            @day.technicalDebt.should.equal 6
            @day['type:bug:technicalDebt'].should.equal 6
            @day['type:story:technicalDebt'].should.equal 0
            @day['type:subtask:technicalDebt'].should.equal 6
            @day['priority:unprioritized:technicalDebt'].should.equal 6
            @day['priority:p1:technicalDebt'].should.equal 0
            @day['priority:p2:technicalDebt'].should.equal 6
            @day['component:component1:technicalDebt'].should.equal 6
            @day['component:component2:technicalDebt'].should.equal 6
            @day['component:component3:technicalDebt'].should.equal 0

          it 'should correctly accumulate lead time 7 day moving average', ->
            @day.leadTimeMA7.should.equal 4
            @day['type:bug:leadTimeMA7'].should.equal 5
            @day['type:story:leadTimeMA7'].should.equal 3
            expect(@day['type:subtask:leadTimeMA7']).to.be.null
            expect(@day['priority:unprioritized:leadTimeMA7']).to.be.null
            @day['priority:p1:leadTimeMA7'].should.equal 5
            @day['priority:p2:leadTimeMA7'].should.equal 3
            @day['component:component1:leadTimeMA7'].should.equal 5
            @day['component:component2:leadTimeMA7'].should.equal 3
            @day['component:component3:leadTimeMA7'].should.equal 4

          it 'should correctly accumulate cycle time 7 day moving average', ->
            @day.cycleTimeMA7.should.equal 2
            @day['type:bug:cycleTimeMA7'].should.equal 3
            @day['type:story:cycleTimeMA7'].should.equal 1
            expect(@day['type:subtask:cycleTimeMA7']).to.be.null
            expect(@day['priority:unprioritized:cycleTimeMA7']).to.be.null
            @day['priority:p1:cycleTimeMA7'].should.equal 3
            @day['priority:p2:cycleTimeMA7'].should.equal 1
            @day['component:component1:cycleTimeMA7'].should.equal 3
            @day['component:component2:cycleTimeMA7'].should.equal 1
            @day['component:component3:cycleTimeMA7'].should.equal 2

# coffeelint: disable=max_line_length
          it 'should correctly accumulate deferred time 7 day moving average', ->
# coffeelint: enable=max_line_length
            @day.deferredTimeMA7.should.equal 2
            @day['type:bug:deferredTimeMA7'].should.equal 2
            @day['type:story:deferredTimeMA7'].should.equal 2
            expect(@day['type:subtask:deferredTimeMA7']).to.be.null
            expect(@day['priority:unprioritized:deferredTimeMA7']).to.be.null
            @day['priority:p1:deferredTimeMA7'].should.equal 2
            @day['priority:p2:deferredTimeMA7'].should.equal 2
            @day['component:component1:deferredTimeMA7'].should.equal 2
            @day['component:component2:deferredTimeMA7'].should.equal 2
            @day['component:component3:deferredTimeMA7'].should.equal 2

          describe '5th #addIssue', ->
            before ->
              @issue =
                type: 'bug'
                priority: 'p1'
                affectsComponent: (component) -> component in [
                  'component2'
                  'component3'
                ]
                resolvedDays: -> 7
                openOnDate: -> true
                technicalDebtOnDate: -> 5
              @day.addIssue @issue

            it 'should correctly accumulate open count', ->
              @day.open.should.equal 2
              @day['type:bug:open'].should.equal 2
              @day['type:story:open'].should.equal 0
              @day['type:subtask:open'].should.equal 1
              @day['priority:unprioritized:open'].should.equal 1
              @day['priority:p1:open'].should.equal 1
              @day['priority:p2:open'].should.equal 1
              @day['component:component1:open'].should.equal 1
              @day['component:component2:open'].should.equal 2
              @day['component:component3:open'].should.equal 1

            it 'should correctly accumulate technical debt', ->
              @day.technicalDebt.should.equal 11
              @day['type:bug:technicalDebt'].should.equal 11
              @day['type:story:technicalDebt'].should.equal 0
              @day['type:subtask:technicalDebt'].should.equal 6
              @day['priority:unprioritized:technicalDebt'].should.equal 6
              @day['priority:p1:technicalDebt'].should.equal 5
              @day['priority:p2:technicalDebt'].should.equal 6
              @day['component:component1:technicalDebt'].should.equal 6
              @day['component:component2:technicalDebt'].should.equal 11
              @day['component:component3:technicalDebt'].should.equal 5

            it 'should correctly accumulate lead time 7 day moving average', ->
              @day.leadTimeMA7.should.equal 4
              @day['type:bug:leadTimeMA7'].should.equal 5
              @day['type:story:leadTimeMA7'].should.equal 3
              expect(@day['type:subtask:leadTimeMA7']).to.be.null
              expect(@day['priority:unprioritized:leadTimeMA7']).to.be.null
              @day['priority:p1:leadTimeMA7'].should.equal 5
              @day['priority:p2:leadTimeMA7'].should.equal 3
              @day['component:component1:leadTimeMA7'].should.equal 5
              @day['component:component2:leadTimeMA7'].should.equal 3
              @day['component:component3:leadTimeMA7'].should.equal 4

            it 'should correctly accumulate cycle time 7 day moving average', ->
              @day.cycleTimeMA7.should.equal 2
              @day['type:bug:cycleTimeMA7'].should.equal 3
              @day['type:story:cycleTimeMA7'].should.equal 1
              expect(@day['type:subtask:cycleTimeMA7']).to.be.null
              expect(@day['priority:unprioritized:cycleTimeMA7']).to.be.null
              @day['priority:p1:cycleTimeMA7'].should.equal 3
              @day['priority:p2:cycleTimeMA7'].should.equal 1
              @day['component:component1:cycleTimeMA7'].should.equal 3
              @day['component:component2:cycleTimeMA7'].should.equal 1
              @day['component:component3:cycleTimeMA7'].should.equal 2

# coffeelint: disable=max_line_length
            it 'should correctly accumulate deferred time 7 day moving average', ->
# coffeelint: enable=max_line_length
              @day.deferredTimeMA7.should.equal 2
              @day['type:bug:deferredTimeMA7'].should.equal 2
              @day['type:story:deferredTimeMA7'].should.equal 2
              expect(@day['type:subtask:deferredTimeMA7']).to.be.null
              expect(@day['priority:unprioritized:deferredTimeMA7']).to.be.null
              @day['priority:p1:deferredTimeMA7'].should.equal 2
              @day['priority:p2:deferredTimeMA7'].should.equal 2
              @day['component:component1:deferredTimeMA7'].should.equal 2
              @day['component:component2:deferredTimeMA7'].should.equal 2
              @day['component:component3:deferredTimeMA7'].should.equal 2
