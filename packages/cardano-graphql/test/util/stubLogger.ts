import { Logger } from 'ts-log';

// eslint-disable-next-line unicorn/consistent-function-scoping,@typescript-eslint/no-empty-function
const noOp = () => {};

export const createStubLogger = (): Logger => ({
  debug: noOp,
  error: noOp,
  info: noOp,
  trace: noOp,
  warn: noOp
});
