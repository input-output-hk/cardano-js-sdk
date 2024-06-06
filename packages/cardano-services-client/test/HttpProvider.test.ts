/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-duplicate-string */
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { createHttpProvider } from '../src/index.js';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { getPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import express from 'express';
import path from 'path';
import type { HttpProviderConfig } from '../src/index.js';
import type { Provider } from '@cardano-sdk/core';
import type { RequestHandler } from 'express';
import type { Server } from 'http';

const packageJson = require(path.join(__dirname, '..', 'package.json'));

type ComplexArg2 = { map: Map<string, Uint8Array> };
type ComplexResponse = Map<bigint, Uint8Array>[];
interface TestProvider extends Provider {
  noArgsEmptyReturn(): Promise<void>;
  complexArgsAndReturn({ arg1, arg2 }: { arg1: bigint; arg2: ComplexArg2 }): Promise<ComplexResponse>;
}

const apiVersion = '1.0.0';
const serviceSlug = 'test';

const createStubHttpProviderServer = async (port: number, urlPath: string, handler: RequestHandler) => {
  const app = express();
  app.use(express.json());
  app.post(`/v${apiVersion}/${serviceSlug}${urlPath}`, handler);
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
  let closeServer: () => Promise<unknown>;

  const createTxSubmitProviderClient = (
    config: Pick<HttpProviderConfig<TestProvider>, 'axiosOptions' | 'mapError'> = {}
  ) =>
    createHttpProvider<TestProvider>({
      apiVersion,
      baseUrl,
      logger,
      paths: stubProviderPaths,
      serviceSlug,
      ...config
    });

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
  });

  afterEach(async () => {
    if (closeServer) await closeServer();
  });

  it('attempting to access unimplemented method throws ProviderError', async () => {
    const provider = createTxSubmitProviderClient();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(() => (provider as any).doesNotExist).toThrowError(ProviderError);
  });

  it('passes through axios options, merging custom header with the included provider version headers', async () => {
    const provider = createTxSubmitProviderClient({ axiosOptions: { headers: { 'custom-header': 'header-value' } } });
    closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (req, res) => {
      expect(req.headers['custom-header']).toBe('header-value');
      expect(req.headers['Version-Api']).toEqual(apiVersion);
      expect(req.headers['Version-Software']).toEqual(packageJson.version);
      res.send();
    });
    await expect(provider.noArgsEmptyReturn()).resolves;
  });

  describe('method with no args and void return', () => {
    it('calls http server with empty args in req body and parses the response', async () => {
      const provider = createTxSubmitProviderClient();
      closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (req, res) => {
        expect(req.body).toEqual({});
        res.send();
      });
      const response = await provider.noArgsEmptyReturn();
      expect(response).toBe(undefined);
    });
  });

  describe('method with complex args and return', () => {
    it('serializes args and deserializes response using core serializableObject', async () => {
      const arg1 = 123n;
      const arg2: ComplexArg2 = { map: new Map([['key', new Uint8Array(Buffer.from('abc'))]]) };
      const expectedResponse: ComplexResponse = [new Map([[1234n, new Uint8Array(Buffer.from('response data'))]])];
      const provider = createTxSubmitProviderClient();
      closeServer = await createStubHttpProviderServer(port, stubProviderPaths.complexArgsAndReturn, (req, res) => {
        expect(fromSerializableObject(req.body)).toEqual({ arg1, arg2 });
        res.send(toSerializableObject(expectedResponse));
      });
      const response = await provider.complexArgsAndReturn({ arg1, arg2 });
      expect(response).toEqual(expectedResponse);
    });
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
          apiVersion: '1.0.0',
          axiosOptions: {},
          baseUrl: 'http://some-hostname:3000',
          logger,
          mapError: jest.fn(),
          paths: stubProviderPaths,
          serviceSlug: 'test'
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
      const errorJson = { message: 'error' };

      beforeEach(async () => {
        closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (_, res) => {
          res.status(500).send(errorJson);
        });
      });

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
        await expect(provider.noArgsEmptyReturn()).resolves.toEqual('result');
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
