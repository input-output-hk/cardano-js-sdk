import { PassThrough, Writable } from 'stream';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { createLogger } from '../src/TestLogger.js';

const toVoid = new Writable({ write: (_chunk, _encoding, done) => done() });

const getPassThrough = () => {
  const stream = new PassThrough();
  const promise = new Promise<string>((resolve, reject) => {
    const chunks: Buffer[] = [];

    stream.once('close', () => resolve(Buffer.concat(chunks).toString('utf-8')));
    stream.once('error', reject);
    stream.on('data', (data) => {
      if (!(data instanceof Buffer)) reject(new Error('not Buffer'));
      chunks.push(data);
    });
  });

  return {
    getContent: () => {
      stream.end();

      return promise;
    },
    stream
  };
};

describe('TestLogger', () => {
  describe('logged message record', () => {
    const logger = createLogger({ env: {}, record: true, stream: toVoid });

    it('logged messages are correctly logged', () => {
      logger.trace({ some: 'data' });
      logger.debug('Debug string');
      logger.info('Info content', { answer: 42, data: 'test' });
      logger.warn('Error which can be ignored', new Error('you can ignore me'));
      logger.error(new TypeError('test error'), 'with data', { answer: 42, test: 'data' });
      logger.fatal('FATAL ERROR');

      expect(logger.messages).toStrictEqual([
        { level: 'trace', message: [{ some: 'data' }] },
        { level: 'debug', message: ['Debug string'] },
        { level: 'info', message: ['Info content', { answer: 42, data: 'test' }] },
        { level: 'warn', message: ['Error which can be ignored', new Error('you can ignore me')] },
        { level: 'error', message: [new TypeError('test error'), 'with data', { answer: 42, test: 'data' }] },
        { level: 'fatal', message: ['FATAL ERROR'] }
      ]);
    });

    it('reset method removes all logged messages', () => {
      logger.reset();

      expect(logger.messages).toStrictEqual([]);
    });
  });

  it('stringifies all logged types', async () => {
    const { getContent, stream } = getPassThrough();
    const logger = createLogger({ env: {}, stream });

    logger.fatal(42n, true, 42, Symbol('42'), '42', undefined, { test: 42 }, () => 42);

    const content = await getContent();

    expect(content).toMatch(/42 true 42 Symbol\(42\) 42 undefined { test: 42 } \[Function \(anonymous\)]/);
  });

  describe('environment variables', () => {
    describe('TL_ARRAY', () => {
      const loggedData = Array.from({ length: 120 }).fill(0);

      it('by default max 100 array elements are logged', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_COMPACT: '0' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content.split('\n').length).toBe(104);
      });

      it('0 maps to Infinity', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_ARRAY: '0', TL_COMPACT: '0' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content.split('\n').length).toBe(123);
      });
    });

    describe('TL_BREAK', () => {
      const loggedData = Object.fromEntries(Array.from({ length: 10 }, (_, i) => [i.toString(), `v${i}`]));

      it('by default, writing on a non tty, max log line length is (90 + line header length) characters', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: {}, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content.split('\n').length).toBe(13);
      });

      it('by default, writing on a tty, max log line length is the width of the tty', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({
          env: {},
          stream: { columns: 200, write: stream.write.bind(stream) } as Writable & { columns?: number }
        });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content.split('\n').length).toBe(2);
      });

      it('0 maps to Infinite', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_BREAK: '0' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content.split('\n').length).toBe(2);
      });
    });

    describe('TL_DEPTH', () => {
      const loggedData = { one: { two: { three: ['four', { five: { six: 'end' } }] } } };

      it('by default depth level 2 is used', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: {}, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/{ one: { two: { three: \[Array] } } }/);
      });

      it('depth level ${TL_DEPTH} is used', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_DEPTH: '4' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/two: { three: \[ 'four', { five: \[Object] } ] }/);
      });

      it('0 maps to Infinity', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_DEPTH: '0' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/three: \[ 'four', { five: { six: 'end' } } ]/);
      });
    });

    describe('TL_JSON', () => {
      class Test {
        private test: number;

        constructor() {
          this.test = 42;
        }

        justToUseTest() {
          return this.test;
        }
      }

      const loggedData = { bigint: 23n, number: 42, string: 'test', test: new Test() };

      it('by default util.inspect is used', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: {}, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/{ bigint: 23n, number: 42, string: 'test', test: Test { test: 42 } }/);
      });

      it('JSONBig.stringify is used with JSON=true', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_JSON: 'true' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/{"bigint":23,"number":42,"string":"test","test":{"test":42}}/);
      });
    });

    describe('TL_HIDDEN', () => {
      const loggedData = { public: 'enumerable' };

      Object.defineProperty(loggedData, 'hidden', { enumerable: false, value: 'non-enumerable' });

      it('by default only enumerable properties are logged', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: {}, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/{ public: 'enumerable' }/);
      });

      it('non-enumerable properties are logged as well with HIDDEN=true', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_HIDDEN: 'true' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/{ \[hidden]: 'non-enumerable', public: 'enumerable' }/);
      });
    });

    describe('TL_LEVEL', () => {
      it('only fatal() is logged with default value', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: {}, stream });

        logger.trace('trace message');
        logger.debug('debug message');
        logger.info('info message');
        logger.warn('warn message');
        logger.error('error message');
        logger.fatal('fatal message');

        const content = await getContent();

        expect(content).not.toMatch(/trace message/);
        expect(content).not.toMatch(/debug message/);
        expect(content).not.toMatch(/info message/);
        expect(content).not.toMatch(/warn message/);
        expect(content).not.toMatch(/error message/);
        expect(content).toMatch(/fatal message/);
      });

      it('trace() and debug() are not logged with LEVEL=info', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_LEVEL: 'info' }, stream });

        logger.trace('trace message');
        logger.debug('debug message');
        logger.info('info message');
        logger.warn('warn message');
        logger.error('error message');
        logger.fatal('fatal message');

        const content = await getContent();

        expect(content).not.toMatch(/trace message/);
        expect(content).not.toMatch(/debug message/);
        expect(content).toMatch(/info message/);
        expect(content).toMatch(/warn message/);
        expect(content).toMatch(/error message/);
        expect(content).toMatch(/fatal message/);
      });
    });

    describe('TL_STRING', () => {
      const loggedData = { data: 'test string '.repeat(200) };

      it('by default max 1000 character are logged for each string', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_BREAK: '0' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/ 1400 more characters/);
      });

      it('Max 2000 character are logged for each string with TL_STRING=2000', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_BREAK: '0', TL_STRING: '2000' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).toMatch(/ 400 more characters/);
      });

      it('0 maps to Infinite', async () => {
        const { getContent, stream } = getPassThrough();
        const logger = createLogger({ env: { TL_BREAK: '0', TL_STRING: '0' }, stream });

        logger.fatal(loggedData);

        const content = await getContent();

        expect(content).not.toMatch(/more characters/);
      });
    });
  });

  describe('common cardano-sdk use cases', () => {
    it('ProviderError', async () => {
      const { getContent, stream } = getPassThrough();
      const logger = createLogger({ env: {}, stream });

      logger.fatal(new ProviderError(ProviderFailure.BadRequest, new TypeError('test'), 'check'));

      const content = await getContent();

      expect(content).toMatch(/ProviderError: BAD_REQUEST \(check\)/);
      expect(content).toMatch(/innerError: TypeError: test/);
    });
  });
});
