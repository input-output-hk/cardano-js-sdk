/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { APPLICATION_JSON, CONTENT_TYPE, HttpServer, HttpServerConfig, TxSubmitHttpService } from '../../src';
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { fromSerializableObject, toSerializableObject } from '@cardano-sdk/util';
import { getRandomPort } from 'get-port-please';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';
import cbor from 'cbor';

const serializeProviderArg = (arg: unknown) => JSON.stringify({ args: [toSerializableObject(arg)] });
const bodyTx = serializeProviderArg(cbor.encode('#####'));
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';

describe('TxSubmitHttpService', () => {
  let txSubmitProvider: TxSubmitProvider;
  let httpServer: HttpServer;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;

  beforeAll(async () => {
    port = await getRandomPort();
    apiUrlBase = `http://localhost:${port}/tx-submit`;
    config = { listen: { port } };
  });

  afterEach(async () => {
    jest.clearAllMocks();
  });

  describe('unhealthy TxSubmitProvider', () => {
    beforeAll(async () => {
      txSubmitProvider = {
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        submitTx: jest.fn()
      };
    });

    it('should not throw during initialization if the TxSubmitProvider is unhealthy', () => {
      expect(() => new TxSubmitHttpService({ txSubmitProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });
  });

  describe('healthy TxSubmitProvider on startup, unhealthy at request time', () => {
    let isOk: () => boolean;
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const serverHealth = async () => {
      const response = await axios.post(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      return response.data;
    };

    beforeAll(async () => {
      isOk = () => true;
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: isOk() })), submitTx: jest.fn() };
      httpServer = new HttpServer(config, {
        services: [new TxSubmitHttpService({ txSubmitProvider })]
      });
      await httpServer.initialize();
      await httpServer.start();
      expect(await serverHealth()).toEqual({ ok: true });
    });

    afterAll(async () => {
      await httpServer.shutdown();
    });

    it('returns a ProviderError of failure type Unhealthy if the TxSubmitProvider is unhealthy when submitting', async () => {
      // Flip to unhealthy state
      isOk = () => false;
      (txSubmitProvider.submitTx as jest.Mock).mockRejectedValueOnce(void 0);
      expect(await serverHealth()).toEqual({ ok: false });

      try {
        await axios.post(`${apiUrlBase}/submit`, serializeProviderArg(Buffer.from(new Uint8Array())), {
          headers: { [CONTENT_TYPE]: APPLICATION_JSON }
        });
        throw new Error('fail');
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        const parsedError = fromSerializableObject<ProviderError>(error.response.data);
        expect(error.response.status).toBe(503);
        expect(parsedError.name).toBe('ProviderError');
        expect(parsedError.reason).toBe('UNHEALTHY');
      }
    });
  });

  describe('healthy and successful submission', () => {
    beforeAll(async () => {
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: true })), submitTx: jest.fn() };
      httpServer = new HttpServer(config, {
        services: [new TxSubmitHttpService({ txSubmitProvider })]
      });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { [CONTENT_TYPE]: APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/submit', () => {
      it('calls underlying TxSubmitProvider with a valid argument', async () => {
        (txSubmitProvider.submitTx as jest.Mock).mockImplementation(async (tx) => {
          expect(ArrayBuffer.isView(tx)).toBe(true);
        });
        expect(
          (
            await axios.post(`${apiUrlBase}/submit`, bodyTx, {
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            })
          ).status
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${apiUrlBase}/submit`, bodyTx, {
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            })
          ).status
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}/submit`, bodyTx, {
            headers: { [CONTENT_TYPE]: APPLICATION_CBOR }
          });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(0);
        }
      });
    });
  });

  describe('healthy but failing submission', () => {
    describe('/submit', () => {
      const stubErrors = [new Cardano.TxSubmissionErrors.BadInputsError({ badInputs: [] })];

      beforeAll(async () => {
        txSubmitProvider = {
          healthCheck: jest.fn(() => Promise.resolve({ ok: true })),
          submitTx: jest.fn(() => Promise.reject(stubErrors))
        };
        httpServer = new HttpServer(config, {
          services: [new TxSubmitHttpService({ txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      it('rehydrates errors when used with TxSubmitHttpProvider', async () => {
        expect.assertions(2);
        const clientProvider = txSubmitHttpProvider(apiUrlBase);
        try {
          await clientProvider.submitTx(new Uint8Array());
        } catch (error: any) {
          if (error instanceof ProviderError) {
            const innerError = error.innerError as Cardano.TxSubmissionError;
            expect(innerError).toBeInstanceOf(Cardano.TxSubmissionErrors.BadInputsError);
            expect(innerError.message).toBe(stubErrors[0].message);
          }
        }
      });

      // eslint-disable-next-line max-len
      it('returns a 400 coded response with detail in the body to a transaction containing a domain violation', async () => {
        expect.assertions(3);
        try {
          await axios.post(`${apiUrlBase}/submit`, serializeProviderArg(Buffer.from(new Uint8Array())), {
            headers: { [CONTENT_TYPE]: APPLICATION_JSON }
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          const parsedError = fromSerializableObject<ProviderError<typeof stubErrors[0]>>(error.response.data);
          expect(parsedError.innerError!.name).toEqual(stubErrors[0].name);
          expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
        }
      });
    });
  });
});
