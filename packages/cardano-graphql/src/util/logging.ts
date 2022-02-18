import { Logger } from 'ts-log';

/**
 * Appends an object containing module metadata to each log entry
 *
 */
export const moduleLogger = (logger: Logger, module: string): Logger => {
  const methodNames = ['debug', 'error', 'info', 'trace', 'warn'] as (keyof Logger)[];
  return <Logger>(<unknown>Object.fromEntries(
    methodNames.map((method) => [
      method,
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
};
