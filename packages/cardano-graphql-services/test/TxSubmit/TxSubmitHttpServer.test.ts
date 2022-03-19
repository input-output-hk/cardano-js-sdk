/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { TxSubmitHttpServer, TxSubmitHttpServerConfig } from '../../src';
import { getPort } from 'get-port-please';
import cbor from 'cbor';
import got from 'got';

const tx = cbor.encode('#####');
const BAD_REQUEST_STRING = 'Response code 400 (Bad Request)';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

describe('TxSubmitHttpServer', () => {
  let txSubmitProvider: TxSubmitProvider;
  let txSubmitHttpServer: TxSubmitHttpServer;
  let port: number;
  let apiUrlBase: string;
  let config: TxSubmitHttpServerConfig;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}`;
    config = { listen: { port } };
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('unhealthy TxSubmitProvider', () => {
    beforeAll(async () => {
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: false })), submitTx: jest.fn() };
      txSubmitHttpServer = TxSubmitHttpServer.create(config, { txSubmitProvider });
    });

    it('throws during initialization if the TxSubmitProvider is unhealthy', async () => {
      await expect(txSubmitHttpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy TxSubmitProvider on startup, unhealthy at request time', () => {
    let isOk: () => boolean;
    let doSubmitTx: (tx: Uint8Array) => Promise<void>;
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const serverHealth = async () => {
      const response = await got(`${apiUrlBase}/health`, {
        headers: { 'Content-Type': APPLICATION_JSON }
      });
      return JSON.parse(response.body);
    };

    beforeAll(async () => {
      isOk = () => true;
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: isOk() })), submitTx: doSubmitTx };
      txSubmitHttpServer = TxSubmitHttpServer.create(config, { txSubmitProvider });
      await expect(await txSubmitHttpServer.initialize()).resolves;
      await expect(txSubmitHttpServer.start()).resolves;
      expect(await serverHealth()).toEqual({ ok: true });
    });

    afterAll(async () => {
      await txSubmitHttpServer.shutdown();
    });

    it('returns a ProviderError of failure type Unhealthy if the TxSubmitProvider is unhealthy when submitting', async () => {
      // Flip to unhealthy state
      isOk = () => false;
      doSubmitTx = () => Promise.reject();
      expect(await serverHealth()).toEqual({ ok: false });

      try {
        await got.post(`${apiUrlBase}/submit`, {
          body: Buffer.from(new Uint8Array()).toString(),
          headers: { 'Content-Type': APPLICATION_CBOR }
        });
        throw new Error('fail');
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        const body = JSON.parse(error.response.body);
        expect(error.response.statusCode).toBe(503);
        expect(body.name).toBe('ProviderError');
        expect(body.reason).toBe('UNHEALTHY');
      }
    });
  });

  describe('healthy and successful submission', () => {
    beforeAll(async () => {
      txSubmitProvider = { healthCheck: jest.fn(() => Promise.resolve({ ok: true })), submitTx: jest.fn() };
      txSubmitHttpServer = TxSubmitHttpServer.create(config, { txSubmitProvider });
      await txSubmitHttpServer.initialize();
      await txSubmitHttpServer.start();
    });

    afterAll(async () => {
      await txSubmitHttpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the txSubmitProvider health response', async () => {
        const res = await got(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
    });

    describe('/submit', () => {
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await got.post(`${apiUrlBase}/submit`, {
              body: tx,
              headers: { 'Content-Type': APPLICATION_CBOR },
              method: 'post'
            })
          ).statusCode
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 400 coded response if the wrong content type header is used', async () => {
        try {
          await got.post(`${apiUrlBase}/submit`, {
            body: tx,
            headers: { 'Content-Type': APPLICATION_JSON }
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
      // eslint-disable-next-line max-len
      it('returns a 400 coded response with detail in the body to a transaction containing a domain violation', async () => {
        const stubErrors = [new Cardano.TxSubmissionErrors.BadInputsError({ badInputs: [] })];
        txSubmitProvider = {
          healthCheck: jest.fn(() => Promise.resolve({ ok: true })),
          submitTx: jest.fn(() => Promise.reject(stubErrors))
        };
        txSubmitHttpServer = TxSubmitHttpServer.create(config, { txSubmitProvider });
        await txSubmitHttpServer.initialize();
        await txSubmitHttpServer.start();
        try {
          await got.post(`${apiUrlBase}/submit`, {
            body: Buffer.from(new Uint8Array()).toString(),
            headers: { 'Content-Type': APPLICATION_CBOR }
          });
          throw new Error('fail');
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.statusCode).toBe(400);
          expect(JSON.parse(error.response.body)[0].name).toEqual(stubErrors[0].name);
          expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
          await txSubmitHttpServer.shutdown();
        }
      });
    });
  });
});
