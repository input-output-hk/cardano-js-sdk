/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, NetworkInfo, NetworkInfoProvider, testnetTimeSettings } from '@cardano-sdk/core';
import { DbSyncNetworkInfoProvider, NetworkInfoCacheKey, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { HttpServer, HttpServerConfig } from '../../src';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Pool } from 'pg';
import { doServerRequest, ingestDbData, sleep, wrapWithTransaction } from '../util';
import { getPort } from 'get-port-please';
import { networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

describe('NetworkInfoHttpService', () => {
  let httpServer: HttpServer;
  let networkInfoProvider: DbSyncNetworkInfoProvider;
  let service: NetworkInfoHttpService;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let doNetworkInfoRequest: ReturnType<typeof doServerRequest>;

  const dbPollInterval = 2 * 1000;
  const cache = new InMemoryCache(UNLIMITED_CACHE_TTL);
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const db = new Pool({ connectionString: process.env.DB_CONNECTION_STRING, max: 1, min: 1 });

  beforeAll(async () => {
    port = await getPort();
    config = { listen: { port } };
    apiUrlBase = `http://localhost:${port}/network-info`;
    networkInfoProvider = new DbSyncNetworkInfoProvider({ cardanoNodeConfigPath, dbPollInterval }, { cache, db });
    service = await NetworkInfoHttpService.create({ networkInfoProvider });
    httpServer = new HttpServer(config, { services: [service] });
    doNetworkInfoRequest = doServerRequest(apiUrlBase);
  });

  describe('healthy state', () => {
    const dbConnectionQuerySpy = jest.spyOn(db, 'query');
    const invalidateCacheSpy = jest.spyOn(cache, 'invalidate');

    beforeEach(async () => {
      await cache.clear();
      dbConnectionQuerySpy.mockClear();
      invalidateCacheSpy.mockClear();
    });

    beforeAll(async () => {
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await db.end();
      await httpServer.shutdown();
      await cache.shutdown();
      jest.clearAllTimers();
    });

    describe('init', () => {
      it('should start epoch polling once the db provider is initialized', async () => {
        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeUndefined();
        expect(cache.keys().length).toEqual(0);

        await sleep(dbPollInterval * 2);

        expect(cache.keys().length).toEqual(1);
        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeDefined();
        expect(invalidateCacheSpy).not.toHaveBeenCalled();
      });
    });

    describe('/health', () => {
      it('forwards the networkInfoProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/network', () => {
      const path = '/network';
      const DB_POLL_QUERIES_COUNT = 1;
      const networkInfoTotalQueriesCount = 4;

      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}/network`, { args: [] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}/network`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('cached', () => {
        it('should query the DB only once when the response is cached', async () => {
          await doNetworkInfoRequest<[], NetworkInfo>(path, []);
          await doNetworkInfoRequest<[], NetworkInfo>(path, []);

          expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(networkInfoTotalQueriesCount);
          expect(cache.keys().length).toEqual(networkInfoTotalQueriesCount);
        });

        it('should call db-sync queries again once the cache is cleared', async () => {
          await doNetworkInfoRequest<[], NetworkInfo>(path, []);
          await cache.clear();
          expect(cache.keys().length).toEqual(0);

          await doNetworkInfoRequest<[], NetworkInfo>(path, []);
          expect(dbConnectionQuerySpy).toBeCalledTimes(networkInfoTotalQueriesCount * 2);
        });

        it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
          const currentEpochNo = 183;
          const totalQueriesCount = networkInfoTotalQueriesCount + DB_POLL_QUERIES_COUNT;

          await doNetworkInfoRequest<[], NetworkInfo>(path, []);
          expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeUndefined();
          expect(cache.keys().length).toEqual(networkInfoTotalQueriesCount);

          await sleep(dbPollInterval);

          expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toEqual(currentEpochNo);
          expect(cache.keys().length).toEqual(totalQueriesCount);
          expect(dbConnectionQuerySpy).toBeCalledTimes(totalQueriesCount);
          expect(invalidateCacheSpy).not.toHaveBeenCalled();
        });

        it(
          'should invalidate cached epoch values once the epoch rollover is captured by polling',
          wrapWithTransaction(async (dbConnection) => {
            const greaterEpoch = 255;

            await doNetworkInfoRequest<[], NetworkInfo>(path, []);

            await sleep(dbPollInterval);
            expect(cache.keys().length).toEqual(networkInfoTotalQueriesCount + DB_POLL_QUERIES_COUNT);

            await ingestDbData(
              dbConnection,
              'epoch',
              ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
              [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
            );

            await sleep(dbPollInterval);
            expect(invalidateCacheSpy).toHaveBeenCalledWith([
              NetworkInfoCacheKey.TOTAL_SUPPLY,
              NetworkInfoCacheKey.ACTIVE_STAKE
            ]);
            expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toEqual(greaterEpoch);
            expect(cache.keys().length).toEqual(3);

            await sleep(dbPollInterval);
          }, db)
        );
      });
    });

    describe('with NetworkInfoHttpProvider', () => {
      let provider: NetworkInfoProvider;

      beforeEach(async () => {
        provider = networkInfoHttpProvider(apiUrlBase);
      });

      it('time settings response is an array of network info response', async () => {
        const testnetNetworkInfo: NetworkInfo['network'] = {
          id: Cardano.NetworkId.testnet,
          magic: Cardano.CardanoNetworkMagic.Testnet,
          timeSettings: testnetTimeSettings
        };
        const response = await provider.networkInfo();
        expect(response.network).toEqual(testnetNetworkInfo);
      });

      it('response is an object of network info', async () => {
        const response = await provider.networkInfo();
        expect(response).toMatchSnapshot();
      });

      it('response is an object of ledger tip', async () => {
        const response = await provider.ledgerTip();
        expect(response).toMatchSnapshot();
      });

      it('response is an object of current wallet protocol parameters', async () => {
        const response = await provider.currentWalletProtocolParameters();
        expect(response).toMatchSnapshot();
      });

      it('response is an object of genesis parameters', async () => {
        const response = await provider.genesisParameters();
        expect(response).toMatchSnapshot();
      });
    });

    describe('/ledger-tip', () => {
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}/ledger-tip`, { args: [] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}/ledger-tip`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
    });

    describe('/current-wallet-protocol-parameters', () => {
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}/current-wallet-protocol-parameters`, { args: [] })).status).toEqual(
          200
        );
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${apiUrlBase}/current-wallet-protocol-parameters`,
            { args: [] },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
    });

    describe('/genesis-parameters', () => {
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}/genesis-parameters`, { args: [] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${apiUrlBase}/genesis-parameters`,
            { args: [] },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
    });
  });
});
