/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-duplicate-string */
import { HttpProviderConfig, createHttpProvider, version } from '../src';
import { Provider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { Server } from 'http';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { getPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import express, { RequestHandler } from 'express';

type ComplexArg2 = { map: Map<string, Buffer> };
type ComplexResponse = Map<bigint, Buffer>[];
interface TestProvider extends Provider {
  noArgsEmptyReturn(): Promise<void>;
  complexArgsAndReturn({ arg1, arg2 }: { arg1: bigint; arg2: ComplexArg2 }): Promise<ComplexResponse>;
}

const createStubHttpProviderServer = async (port: number, path: string, handler: RequestHandler) => {
  const app = express();
  app.use(express.json());
  app.post(path, handler);
  const server = await new Promise<Server>((resolve) => {
    const result = app.listen(port, () => resolve(result));
  });
  return () => new Promise((resolve) => server.close(resolve));
};

const stubProviderPaths = {
  complexArgsAndReturn: '/complex',
  healthCheck: '/health',
  noArgsEmptyReturn: '/simple'
};

describe('createHttpProvider', () => {
  let port: number;
  let baseUrl: string;

  const createTxSubmitProviderClient = (
    config: Pick<HttpProviderConfig<TestProvider>, 'axiosOptions' | 'mapError'> = {}
  ) =>
    createHttpProvider<TestProvider>({
      baseUrl,
      logger,
      paths: stubProviderPaths,
      version,
      ...config
    });

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
  });

  it('attempting to access unimplemented method throws ProviderError', async () => {
    const provider = createTxSubmitProviderClient();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(() => (provider as any).doesNotExist).toThrowError(ProviderError);
  });

  describe('method with no args and void return', () => {
    it('calls http server with empty args in req body and parses the response', async () => {
      const provider = createTxSubmitProviderClient();
      const closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (req, res) => {
        expect(req.body).toEqual({});
        res.send();
      });
      const response = await provider.noArgsEmptyReturn();
      await closeServer();
      expect(response).toBe(undefined);
    });
  });

  describe('method with complex args and return', () => {
    it('serializes args and deserializes response using core serializableObject', async () => {
      const arg1 = 123n;
      const arg2: ComplexArg2 = { map: new Map([['key', Buffer.from('abc')]]) };
      const expectedResponse: ComplexResponse = [new Map([[1234n, Buffer.from('response data')]])];
      const provider = createTxSubmitProviderClient();
      const closeServer = await createStubHttpProviderServer(
        port,
        stubProviderPaths.complexArgsAndReturn,
        (req, res) => {
          expect(fromSerializableObject(req.body)).toEqual({ arg1, arg2 });
          res.send(toSerializableObject(expectedResponse));
        }
      );
      const response = await provider.complexArgsAndReturn({ arg1, arg2 });
      await closeServer();
      expect(response).toEqual(expectedResponse);
    });
  });

  it('passes through axios options, merging custom header with the included provider version headers', async () => {
    const provider = createTxSubmitProviderClient({ axiosOptions: { headers: { 'custom-header': 'header-value' } } });
    const closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (req, res) => {
      expect(req.headers['custom-header']).toBe('header-value');
      expect(req.headers['Version-Api']).toEqual(version.api);
      expect(req.headers['Version-Software']).toEqual(version.software);
      res.send();
    });
    await provider.noArgsEmptyReturn();
    await closeServer();
  });

  describe('errors', () => {
    describe('connection errors', () => {
      it('maps ECONNREFUSED and ENOTFOUND to ProviderError{ConnectionFailure}', async () => {
        const provider = createTxSubmitProviderClient({ mapError: jest.fn() });
        try {
          await provider.noArgsEmptyReturn();
          throw new Error('Expected to throw');
        } catch (error) {
          if (error instanceof ProviderError) {
            expect(error.reason).toBe(ProviderFailure.ConnectionFailure);
          } else {
            throw new TypeError('Invalid error type');
          }
        }
      });
      it('maps EAI_AGAIN to ProviderError{ConnectionFailure}', async () => {
        const provider = createHttpProvider<TestProvider>({
          axiosOptions: {},
          baseUrl: 'http://some-hostname:3000',
          logger,
          mapError: jest.fn(),
          paths: stubProviderPaths,
          version
        });
        try {
          await provider.noArgsEmptyReturn();
          throw new Error('Expected to throw');
        } catch (error) {
          if (error instanceof ProviderError) {
            expect(error.reason).toBe(ProviderFailure.ConnectionFailure);
          } else {
            throw new TypeError('Invalid error type');
          }
        }
      });
    });

    describe('HTTPError', () => {
      let closeServer: Function;
      const errorJson = { message: 'error' };

      beforeAll(async () => {
        closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (_, res) => {
          res.status(500).send(errorJson);
        });
      });

      afterAll(() => closeServer());

      it('parses error json and wraps errors in ProviderError', async () => {
        const provider = createTxSubmitProviderClient();
        try {
          await provider.noArgsEmptyReturn();
          throw new Error('Expected to throw');
        } catch (error) {
          if (error instanceof ProviderError) {
            expect(error.innerError).toEqual(errorJson);
          } else {
            throw new TypeError('Expected ProviderError');
          }
        }
      });

      it('supports custom error mapper that maps error into return type', async () => {
        const provider = createTxSubmitProviderClient({
          mapError: () => 'result'
        });
        expect(await provider.noArgsEmptyReturn()).toEqual('result');
      });

      it('supports custom error mapper that throws', async () => {
        const provider = createTxSubmitProviderClient({
          mapError: (error) => {
            throw new ProviderError(ProviderFailure.Unhealthy, error, 'bad server');
          }
        });
        try {
          await provider.noArgsEmptyReturn();
          throw new Error('Expected to throw');
        } catch (error) {
          expect((error as ProviderError).innerError).toBeTruthy();
          expect((error as ProviderError).reason).toBe(ProviderFailure.Unhealthy);
          expect((error as ProviderError).detail).toBe('bad server');
        }
      });
    });
  });
});
