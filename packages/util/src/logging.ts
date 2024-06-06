import type { Logger } from 'ts-log';

export const loggerMethodNames: (keyof Logger)[] = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'];

/**
 * Prepends context to each log entry
 *
 * @param {Logger} logger To which logger we are adding a context. Could be a simple logger or
 * another context logger, in which case the new context is added along with the parent one.
 * @param {string} context string that is prepended to the log messages. It is concatenated
 * with the parent context if any.
 * @param contextStringify Optional function to override how the context is stringified.
 * It takes as parameter an array of contexts and returns a concatenated string.
 * Default contextStringify example: ['ctx1', 'ctx'2] becomes "[ctx1|ctx2]".
 * @returns A logger object that prepends the context when logging
 *
 * Example: single context, default formatting
 *   - const oneContextLogger = contextLogger('ctx1', rawLogger);
 *   - oneContextLogger.debug('hi') calls `rawLogger('[ctx1]', hi)
 *
 * Example: nested context, default formatting
 *   - const twoContextLogger = contextLogger('ctx2', oneContextLogger);
 *   - twoContextLogger.debug('hi') calls `rawLogger('[ctx1|ctx2]', hi)
 *
 * Example: nested context with custom formatter
 *   - const mergeLogger = contextLogger('ctx2', oneContextLogger, (ctx) => `(${ctx.join('&')}) =>`));
 *   - mergeLogger.debug('hi') calls `rawLogger('(ctx1&ctx2) =>', 'hi')
 */

export const contextLogger = (
  logger: Logger,
  context: string,
  contextStringify = (ctx: string[]) => (logger.contextStringify ? logger.contextStringify(ctx) : `[${ctx.join('|')}]`)
): Logger => {
  // Regardless of the nesting, we always want to call the base logger,
  // so we need to keep track of it in the derived logger.
  // Otherwise, if calling the parent logger, each logger will prepend it's context, ending up
  // with multiple context params when reaching the base logger, e.g. info('ctx1', 'ctx1,ctx2', actual message)
  const derivedLogger: Partial<Logger> = {
    baseLogger: logger.baseLogger || logger,
    contextArray: [...(logger.contextArray || []), context],
    contextStringify
  };

  const contextStr = contextStringify(derivedLogger.contextArray);

  return { ...derivedLogger, ...(<Logger>(<unknown>Object.fromEntries(
      loggerMethodNames.map<[keyof Logger, Logger['info']]>((method) => [
        method,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (message?: any, ...optionalParams: any[]) => {
          derivedLogger.baseLogger[method](contextStr, message, ...optionalParams);
        }
      ])
    ))) };
};
