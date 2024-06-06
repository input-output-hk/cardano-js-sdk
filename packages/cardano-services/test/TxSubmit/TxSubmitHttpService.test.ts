/* eslint-disable @typescript-eslint/no-explicit-any */
import { APPLICATION_JSON, CONTENT_TYPE, HttpServer, TxSubmitHttpService } from '../../src/index.js';
import { FATAL, createLogger } from 'bunyan';
import { ProviderError, TxCBOR, TxSubmissionError, TxSubmissionErrorCode } from '@cardano-sdk/core';
import { bufferToHexString, fromSerializableObject } from '@cardano-sdk/util';
import { getPort } from 'get-port-please';
import { logger } from '@cardano-sdk/util-dev';
import { servicesWithVersionPath as services } from '../util.js';
import { txSubmitHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';
import cbor from 'cbor';
import type { CreateHttpProviderConfig } from '@cardano-sdk/cardano-services-client';
import type { HttpServerConfig } from '../../src/index.js';
import type { OgmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import type { TxSubmitProvider } from '@cardano-sdk/core';

const txSubmitProviderMock = (
  healthCheckImpl = async () => Promise.resolve({ ok: true }),
  submitTxImpl = async () => Promise.resolve([])
) =>
  ({
    healthCheck: jest.fn(healthCheckImpl),
    initialize: jest.fn(),
    shutdown: jest.fn(),
    start: jest.fn(),
    submitTx: jest.fn(submitTxImpl)
  } as unknown as OgmiosTxSubmitProvider);

const serializeProviderArg = (arg: unknown) => ({ signedTransaction: arg });
const bodyTx = serializeProviderArg(cbor.encode('#####').toString('hex'));
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const emptyUintArrayAsHexString = bufferToHexString(Buffer.from(new Uint8Array()));

describe('TxSubmitHttpService', () => {
  let txSubmitProvider: OgmiosTxSubmitProvider;
  let httpServer: HttpServer;
  let port: number;
  let baseUrl: string;
  let baseUrlWithVersion: string;
  let clientConfig: CreateHttpProviderConfig<TxSubmitProvider>;
  let config: HttpServerConfig;

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
    baseUrlWithVersion = `${baseUrl}${services.txSubmit.versionPath}/${services.txSubmit.name}`;
    clientConfig = { baseUrl, logger: createLogger({ level: FATAL, name: 'unit tests' }) };
    config = { listen: { port } };
  });

  afterEach(async () => {
    jest.clearAllMocks();
  });

  describe('healthy TxSubmitProvider on startup, unhealthy at request time', () => {
    let isOk: () => boolean;
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const serverHealth = async () => {
      const response = await axios.post(`${baseUrlWithVersion}/health`, {
        headers: { [CONTENT_TYPE]: APPLICATION_JSON }
      });
      return response.data;
    };

    beforeAll(async () => {
      isOk = () => true;
      txSubmitProvider = txSubmitProviderMock(() => Promise.resolve({ ok: isOk() }));
      httpServer = new HttpServer(config, {
        logger,
        runnableDependencies: [],
        services: [new TxSubmitHttpService({ logger, txSubmitProvider })]
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
        await axios.post(
          `${baseUrlWithVersion}/submit`,
          { signedTransaction: emptyUintArrayAsHexString },
          {
            headers: { [CONTENT_TYPE]: APPLICATION_JSON }
          }
        );
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
      txSubmitProvider = txSubmitProviderMock();
      httpServer = new HttpServer(config, {
        logger,
        runnableDependencies: [],
        services: [new TxSubmitHttpService({ logger, txSubmitProvider })]
      });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the txSubmitProvider health response', async () => {
        const res = await axios.post(`${baseUrlWithVersion}/health`, {
          headers: { [CONTENT_TYPE]: APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/submit', () => {
      it('calls underlying TxSubmitProvider with a valid argument', async () => {
        (txSubmitProvider.submitTx as jest.Mock).mockImplementation(async ({ signedTransaction }) => {
          expect(typeof signedTransaction === 'string').toBe(true);
        });
        expect(
          (
            await axios.post(`${baseUrlWithVersion}/submit`, bodyTx, {
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            })
          ).status
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${baseUrlWithVersion}/submit`, bodyTx, {
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            })
          ).status
        ).toEqual(200);
        expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(3);
        try {
          await axios.post(`${baseUrlWithVersion}/submit`, bodyTx, {
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
      const stubErrors = [
        new TxSubmissionError(
          TxSubmissionErrorCode.NonEmptyRewardAccount,
          { nonEmptyRewardAccountBalance: { lovelace: 10n } },
          'Bad inputs'
        )
      ];

      beforeAll(async () => {
        txSubmitProvider = txSubmitProviderMock(
          () => Promise.resolve({ ok: true }),
          () => Promise.reject(stubErrors)
        );
        httpServer = new HttpServer(config, {
          logger,
          runnableDependencies: [],
          services: [new TxSubmitHttpService({ logger, txSubmitProvider })]
        });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      it('rehydrates errors when used with TxSubmitHttpProvider', async () => {
        expect.assertions(3);
        const clientProvider = txSubmitHttpProvider(clientConfig);
        try {
          await clientProvider.submitTx({ signedTransaction: TxCBOR(emptyUintArrayAsHexString) });
        } catch (error: any) {
          if (error instanceof ProviderError) {
            const innerError = error.innerError as TxSubmissionError;
            expect(innerError).toBeInstanceOf(TxSubmissionError);
            expect(innerError.code).toBe(stubErrors[0].code);
            expect(innerError.message).toBe(stubErrors[0].message);
          }
        }
      });

      // eslint-disable-next-line max-len
      // returns a 400 coded response with detail in the body to a transaction containing a domain violation
      it('asd', async () => {
        expect.assertions(3);
        try {
          await axios.post(
            `${baseUrlWithVersion}/submit`,
            { signedTransaction: emptyUintArrayAsHexString },
            {
              headers: { [CONTENT_TYPE]: APPLICATION_JSON }
            }
          );
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          // eslint-disable-next-line prettier/prettier
          const parsedError = fromSerializableObject<ProviderError<typeof stubErrors[0]>>(error.response.data);
          expect(parsedError.innerError!.name).toEqual(stubErrors[0].name);
          expect(txSubmitProvider.submitTx).toHaveBeenCalledTimes(1);
        }
      });
    });
  });
});
