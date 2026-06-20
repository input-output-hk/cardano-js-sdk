const path = require('path');

module.exports = {
  coveragePathIgnorePatterns: ['.config.js'],
  // Node 22+ exposes `globalThis.performance` as a read-only accessor, which the
  // (modern) fake-timers implementation cannot replace — so exclude it from faking.
  fakeTimers: { doNotFake: ['performance'] },
  preset: 'ts-jest',
  // Node 19+ defaults http(s).globalAgent to keepAlive:true; in-process HTTP tests
  // that restart servers between cases reuse stale sockets ("socket hang up") — disable it.
  setupFiles: [path.join(__dirname, 'disableKeepAlive.js')],
  testTimeout: process.env.CI ? 120_000 : 12_000,
  transform: {
    '^.+\\.test.ts?$': 'ts-jest'
  }
};
