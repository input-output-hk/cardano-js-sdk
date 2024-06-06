import type { Logger } from 'ts-log';

import { contextLogger } from '../src/index.js';
import { createStubLogger } from './util.js';

const SOME_MODULE = 'some-module';
const SOME_FUNCTION_NAME = 'some-function-name';
const SOME_MESSAGE = 'some message';

const OPTIONAL1 = 'opt1';
const OPTIONAL2 = 'opt2';
const OPTIONAL3 = { opt3: 'opt3' };

describe('contextLogger', () => {
  let rawLogger: Logger;
  let logger: Logger;

  beforeEach(() => {
    rawLogger = createStubLogger();
    logger = contextLogger(rawLogger, SOME_MODULE);
  });
  it('adds context with default formatting to message', () => {
    logger.debug(SOME_MESSAGE, OPTIONAL1, OPTIONAL2, OPTIONAL3);
    expect(rawLogger.debug).toHaveBeenLastCalledWith(`[${SOME_MODULE}]`, SOME_MESSAGE, OPTIONAL1, OPTIONAL2, OPTIONAL3);
    expect(rawLogger.debug).toHaveBeenCalledTimes(1);
  });

  it('adds nested contexts with default formatting to message', () => {
    const nestedLogger = contextLogger(logger, SOME_FUNCTION_NAME);
    nestedLogger.warn(SOME_MESSAGE, OPTIONAL3);
    expect(rawLogger.warn).toHaveBeenCalledWith(`[${SOME_MODULE}|${SOME_FUNCTION_NAME}]`, SOME_MESSAGE, OPTIONAL3);
    expect(rawLogger.warn).toHaveBeenCalledTimes(1);
  });

  it('uses optional context formatter', () => {
    logger = contextLogger(rawLogger, SOME_MODULE, (ctx) => `(${ctx.join('&')}) =>`);
    logger.debug(SOME_MESSAGE);
    expect(rawLogger.debug).toHaveBeenLastCalledWith(`(${SOME_MODULE}) =>`, SOME_MESSAGE);
    expect(rawLogger.debug).toHaveBeenCalledTimes(1);
  });

  it('uses parent context formatter when in nested context', () => {
    logger = contextLogger(rawLogger, SOME_MODULE, (ctx) => `(${ctx.join('&')}) =>`);
    const nestedLogger = contextLogger(logger, SOME_FUNCTION_NAME);
    nestedLogger.info(SOME_MESSAGE);
    expect(rawLogger.info).toHaveBeenCalledWith(`(${SOME_MODULE}&${SOME_FUNCTION_NAME}) =>`, SOME_MESSAGE);
    expect(rawLogger.info).toHaveBeenCalledTimes(1);
  });

  it('uses child formatter when in nested context and parent formatter in parent', () => {
    const nestedLogger = contextLogger(logger, SOME_FUNCTION_NAME, (ctx) => `(${ctx.join('&')}) =>`);
    nestedLogger.info(SOME_MESSAGE, OPTIONAL3, OPTIONAL2);
    expect(rawLogger.info).toHaveBeenCalledWith(
      `(${SOME_MODULE}&${SOME_FUNCTION_NAME}) =>`,
      SOME_MESSAGE,
      OPTIONAL3,
      OPTIONAL2
    );

    logger.debug(SOME_MESSAGE);
    expect(rawLogger.debug).toHaveBeenCalledWith(`[${SOME_MODULE}]`, SOME_MESSAGE);

    expect(rawLogger.debug).toHaveBeenCalledTimes(1);
  });
});
