/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { APPLICATION_JSON, CONTENT_TYPE, HttpServerConfig, TxSubmitHttpServer } from '../../src';
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider, util } from '@cardano-sdk/core';
import { getPort } from 'get-port-please';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-services-client';
import cbor from 'cbor';
import got from 'got';

const serializeProviderArg = (arg: unknown) => JSON.stringify({ args: [util.toSerializableObject(arg)] });
const bodyTx = serializeProviderArg(cbor.encode('#####'));
const BAD_REQUEST_STRING = 'Response code 400 (Bad Request)';
const APPLICATION_CBOR = 'application/cbor';

describe('TxSubmitHttpServer', () => {
  let txSubmitProvider: TxSubmitProvider;
  let txSubmitHttpServer: TxSubmitHttpServer;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}`;
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
      txSubmitHttpServer = TxSubmitHttpServer.create({ txSubmitProvider }, config);
    });

    it('throws during initialization if the TxSubmitProvider is unhealthy', async () => {
      await expect(txSubmitHttpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy TxSubmitProvider on startup, unhealthy at request time', () => {
    let isOk: () => boolean;
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const serverHealth = async () => {
      const response = await got(`${apiUrlBase}/health`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      return JSON.parse(response.body);
    };

    beforeAll(async () => {
      isOk = () => true;
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: isOk() })), submitTx: jest.fn() };
      txSubmitHttpServer = TxSubmitHttpServer.create({ txSubmitProvider }, config);
      await txSubmitHttpServer.initialize();
      await txSubmitHttpServer.start();
      expect(await serverHealth()).toEqual({ ok: true });
    });

    afterAll(async () => {
      await txSubmitHttpServer.shutdown();
    });

    it('returns a ProviderError of failure type Unhealthy if the TxSubmitProvider is unhealthy when submitting', async () => {
      // Flip to unhealthy state
      isOk = () => false;
      (txSubmitProvider.submitTx as jest.Mock).mockRejectedValueOnce(void 0);
      expect(await serverHealth()).toEqual({ ok: false });

      try {
        await got.post(`${apiUrlBase}/submit`, {
          body: serializeProviderArg(Buffer.from(new Uint8Array())),
          headers: { [CONTENT_TYPE]: APPLICATION_JSON }
        });
        throw new Error('fail');
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        const parsedError = util.fromSerializableObject<ProviderError>(JSON.parse(error.response.body));
        expect(error.response.statusCode).toBe(503);
        expect(parsedError.name).toBe('ProviderError');
        expect(parsedError.reason).toBe('UNHEALTHY');
      }
    });
  });

  describe('healthy and successful submission', () => {
    beforeAll(async () => {
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: true })), submitTx: jest.fn() };
      txSubmitHttpServer = TxSubmitHttpServer.create({ txSubmitProvider }, config);
      await txSubmitHttpServer.initialize();
      await txSubmitHttpServer.start();
    });

    afterAll(async () => {
      await txSubmitHttpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the txSubmitProvider health response', async () => {
        const res = await got(`${apiUrlBase}/health`, {
          headers: { [CONTENT_TYPE]: APPLICATION_JSON }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
    });

    describe('/submit', () => {
      it('calls underlying TxSubmitProvider with a valid argument', async () => {
        (txSubmitProvider.submitTx as jest.Mock).mockImplementation(async (tx) => {
          expect(ArrayBuffer.isView(tx)).toBe(true);
        });
        expect(
          (
            await got.post(`${apiUrlBase}/submit`, {
              body: bodyTx,
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            })
          ).statusCode
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await got.post(`${apiUrlBase}/submit`, {
              body: bodyTx,
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            })
          ).statusCode
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 400 coded response if the wrong content type header is used', async () => {
        try {
          await got.post(`${apiUrlBase}/submit`, {
            body: bodyTx,
            headers: { [CONTENT_TYPE]: APPLICATION_CBOR }
          });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.statusCode).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
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
        txSubmitHttpServer = TxSubmitHttpServer.create({ txSubmitProvider }, config);
        await txSubmitHttpServer.initialize();
        await txSubmitHttpServer.start();
      });

      afterAll(async () => {
        await txSubmitHttpServer.shutdown();
      });

      it('rehydrates errors when used with TxSubmitHttpProvider', async () => {
        expect.assertions(2);
        const clientProvider = txSubmitHttpProvider(apiUrlBase);
        try {
          await clientProvider.submitTx(new Uint8Array());
        } catch (error) {
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
          await got.post(`${apiUrlBase}/submit`, {
            body: serializeProviderArg(Buffer.from(new Uint8Array())),
            headers: { [CONTENT_TYPE]: APPLICATION_JSON }
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.statusCode).toBe(400);
          const parsedError = util.fromSerializableObject<ProviderError<typeof stubErrors[0]>>(
            JSON.parse(error.response.body)
          );
          expect(parsedError.innerError!.name).toEqual(stubErrors[0].name);
          expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
        }
      });
    });
  });
});
