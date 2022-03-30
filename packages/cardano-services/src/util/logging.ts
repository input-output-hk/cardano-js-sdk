import { Logger } from 'ts-log';

export const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];

/**
 * Appends an object containing module metadata to each log entry
 *
 */
export const moduleLogger = (logger: Logger, module: string): Logger => <Logger>(<unknown>Object.fromEntries(
    loggerMethodNames.map((method) => [
      method,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      (...optionalParams: any[]) => {
        let firstArg = { module };
        let secondArg = optionalParams;
        if (typeof optionalParams[0] !== 'string') {
          firstArg = { ...firstArg, ...optionalParams[0] };
          secondArg = optionalParams.slice(1);
        }
        return logger[method](firstArg, secondArg[0]);
      }
    ])
  ));
