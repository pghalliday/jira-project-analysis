require('jasmine-reporters/src/jasmine.terminal_reporter');

jasmine.VERBOSE = true;

jasmine.getEnv().addReporter(new jasmine.TerminalReporter({
  verbosity: 3,
  color: true
}));
