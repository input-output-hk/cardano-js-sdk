import { Logger } from 'ts-log';
import { createStubLogger } from '@cardano-sdk/util-dev';
import { moduleLogger } from '../../src/util';

const SOME_MODULE = 'some-module';
const SOME_MESSAGE = 'some message';

describe('moduleLogger', () => {
  let rawLogger: Logger;
  let logger: Logger;

  beforeEach(() => {
    rawLogger = createStubLogger();
    logger = moduleLogger(rawLogger, SOME_MODULE);
  });

  it('adds an object containing the module name to log output', () => {
    logger.info(SOME_MESSAGE);
    expect(rawLogger.info).toHaveBeenCalledWith({ module: SOME_MODULE }, SOME_MESSAGE);
  });

  it('merges the module name with a provided object, in the log output', () => {
    const SOME_DATA = { nested: { two: true }, one: 'one' };
    logger.info({ someData: SOME_DATA }, SOME_MESSAGE);
    expect(rawLogger.info).toHaveBeenCalledWith({ module: SOME_MODULE, someData: SOME_DATA }, SOME_MESSAGE);
  });
});
