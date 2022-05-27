/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-duplicate-string */
import { HttpProviderConfig, createHttpProvider } from '../src';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';

import { Server } from 'http';
import { getPort } from 'get-port-please';
import express, { RequestHandler } from 'express';

type ComplexArg2 = { map: Map<string, Buffer> };
type ComplexResponse = Map<bigint, Buffer>[];
interface TestProvider {
  noArgsEmptyReturn(): Promise<void>;
  complexArgsAndReturn(arg1: bigint, arg2: ComplexArg2): Promise<ComplexResponse>;
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
  noArgsEmptyReturn: '/simple'
};

describe('createHttpServer', () => {
  let port: number;
  let baseUrl: string;

  const createTxSubmitProviderClient = (
    config: Pick<HttpProviderConfig<TestProvider>, 'axiosOptions' | 'mapError'> = {}
  ) =>
    createHttpProvider<TestProvider>({
      baseUrl,
      paths: stubProviderPaths,
      ...config
    });

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
  });

  it('attempting to access unimplemented method throws ProviderError', async () => {
    const provider = createTxSubmitProviderClient();
    expect(() => (provider as any).doesntExist).toThrowError(ProviderError);
  });

  describe('method with no args and void return', () => {
    it('calls http server with empty args in req body and parses the response', async () => {
      const provider = createTxSubmitProviderClient();
      const closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (req, res) => {
        expect(req.body.args).toEqual([]);
        res.send();
      });
      const response = await provider.noArgsEmptyReturn();
      expect(response).toBe(undefined);
      await closeServer();
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
          expect(fromSerializableObject(req.body.args)).toEqual([arg1, arg2]);
          res.send(toSerializableObject(expectedResponse));
        }
      );
      const response = await provider.complexArgsAndReturn(arg1, arg2);
      expect(response).toEqual(expectedResponse);
      await closeServer();
    });
  });

  it('passes through axios options', async () => {
    const provider = createTxSubmitProviderClient({ axiosOptions: { headers: { 'custom-header': 'header-value' } } });
    const closeServer = await createStubHttpProviderServer(port, stubProviderPaths.noArgsEmptyReturn, (req, res) => {
      expect(req.headers['custom-header']).toBe('header-value');
      res.send();
    });
    await provider.noArgsEmptyReturn();
    await closeServer();
  });

  describe('errors', () => {
    describe('connection errors', () => {
      it('maps ECONNREFUSED and ENOTFOUND to ProviderError{ConnectionFailure}', async () => {
        const provider = createTxSubmitProviderClient();
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

      it('calls mapError with null response when request fails', async () => {
        const provider = createTxSubmitProviderClient({
          mapError: (error) => {
            expect(error).toBeNull();
            return 'error';
          }
        });
        expect(await provider.noArgsEmptyReturn()).toEqual('error');
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
