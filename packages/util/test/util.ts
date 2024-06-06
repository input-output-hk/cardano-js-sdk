import type { Logger } from 'ts-log';

export const createStubLogger = (): Logger => ({
  debug: jest.fn(),
  error: jest.fn(),
  info: jest.fn(),
  trace: jest.fn(),
  warn: jest.fn()
});
