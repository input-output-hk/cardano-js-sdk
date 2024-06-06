/* eslint-disable prettier/prettier */
/* eslint key-spacing: ["error", { align: { afterColon: true, beforeColon: false, on: "value" } }] */
import * as envalid from 'envalid';
import { inspect } from 'util';
import JSONbig from 'json-bigint';
import type { InspectOptions } from 'util';

const logLevels = { debug: 2, error: 5, fatal: 6, info: 3, trace: 1, warn: 4 };
const logLevelLabels = ['', 'TRACE  ', 'DEBUG  ', 'INFO   ', 'WARNING', 'ERROR  ', 'FATAL  '];

type LogLevel = keyof typeof logLevels;
type LoggerEntry = [LogLevel, number];

/** The base log function */
export type LogFunction = (...args: unknown[]) => void;

/** Recorder messages is an Array of Objects of this type */
export type LoggedMessage = { level: LogLevel; message: unknown[] };

/** The base logger object */
export type Logger = { [l in LogLevel]: LogFunction };

/**
 * A unit test dedicated logger. Check
 * https://github.com/input-output-hk/cardano-js-sdk/tree/master/packages/util-dev#testlogger for details.
 */
export type TestLogger = Logger & { messages: LoggedMessage[]; reset: () => void };

type TestStream = { columns?: number; isTTY?: boolean; write: Function };

/** Options for createLogger */
export interface TestLoggerOptions {
  /** The environment variables to use. Default: process.env - Used to test TestLogger */
  env?: NodeJS.ProcessEnv;

  /** If true, the logger will records all the logged values. - Default: false */
  record?: boolean;

  /** The stream to write logs. Default: process.stdout - Used to test TestLogger */
  stream?: TestStream;
}

const getConfig = (env: NodeJS.ProcessEnv, stream?: TestStream) => {
  const { TL_ARRAY, TL_BREAK, TL_COLOR, TL_COMPACT, TL_DEPTH, TL_HIDDEN, TL_JSON, TL_LEVEL, TL_PROXY, TL_STRING } =
    envalid.cleanEnv(env, {
      TL_ARRAY:   envalid.num({ default: 100 }),
      TL_BREAK:   envalid.num({ default: stream?.columns ? stream?.columns - 33 : 90 }),
      TL_COLOR:   envalid.bool({ default: stream?.isTTY || false }),
      TL_COMPACT: envalid.num({ default: 3 }),
      TL_DEPTH:   envalid.num({ default: 2 }),
      TL_HIDDEN:  envalid.bool({ default: false }),
      TL_JSON:    envalid.bool({ default: false }),
      TL_LEVEL:   envalid.str({ choices: Object.keys(logLevels) as LogLevel[], default: 'fatal' }),
      TL_PROXY:   envalid.bool({ default: false }),
      TL_STRING:  envalid.num({ default: 1000 })
    });

  const inspectOptions: InspectOptions = {
    breakLength:     TL_BREAK || Number.POSITIVE_INFINITY,
    colors:          TL_COLOR,
    compact:         TL_COMPACT || false,
    depth:           TL_DEPTH || Number.POSITIVE_INFINITY,
    maxArrayLength:  TL_ARRAY || Number.POSITIVE_INFINITY,
    maxStringLength: TL_STRING || Number.POSITIVE_INFINITY,
    showHidden:      TL_HIDDEN,
    showProxy:       TL_PROXY,
    sorted:          true
  };

  return { inspectOptions, minHeight: logLevels[TL_LEVEL], useJSON: TL_JSON };
};

/**
 * Creates a new TestLogger
 *
 * @param options If `record` is equal to `true`, all logged values are recorded in logger.messages
 * @returns the newly created TestLogger
 */
export const createLogger = (options: TestLoggerOptions = {}) => {
  const { env, record, stream } = { env: process.env, stream: process.stdout as TestStream, ...options };
  const { minHeight, inspectOptions, useJSON } = getConfig(env, stream);
  const messages: LoggedMessage[] = [];
  const stringify = (data: unknown) => {
    switch (typeof data) {
      case 'bigint':
      case 'boolean':
      case 'number':
      case 'symbol':
        return data.toString();
      case 'string':
        return data;
      case 'undefined':
        return 'undefined';
      case 'object':
        if (useJSON) return JSONbig.stringify(data);
      // eslint-disable-next-line no-fallthrough
      case 'function':
        return inspect(data, inspectOptions);
    }
  };

  const getLogFunction = ([level, height]: LoggerEntry) => {
    const label = logLevelLabels[height];

    return (...message: unknown[]) => {
      if (record) messages.push({ level, message });

      if (height < minHeight) return;

      const line = message.map(stringify).join(' ');
      const now = new Date().toISOString().replace('T', ' ').replace('Z', '');
      const lines = line.split('\n').map((_) => `${now} ${label} ${_}\n`);

      stream.write(lines.join(''));
    };
  };

  const logger = Object.fromEntries((<LoggerEntry[]>Object.entries(logLevels)).map((_) => [_[0], getLogFunction(_)]));
  const reset = () => <void>(<unknown>(messages.length = 0));

  return <TestLogger>{ messages, reset, ...logger };
};

/** The default logger */
export const logger = createLogger();
