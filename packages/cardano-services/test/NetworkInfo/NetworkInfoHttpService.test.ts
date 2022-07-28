/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-identical-functions */
import { CardanoNode, EraSummary, NetworkInfoProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncNetworkInfoProvider, NetworkInfoCacheKey, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { HttpServer, HttpServerConfig } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { ingestDbData, sleep, wrapWithTransaction } from '../util';
import { loadGenesisData } from '../../src/NetworkInfo/DbSyncNetworkInfoProvider/mappers';
import axios from 'axios';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

const cacheItemsInSupplySummaryCount = 2;

describe('NetworkInfoHttpService', () => {
  let httpServer: HttpServer;
  let networkInfoProvider: DbSyncNetworkInfoProvider;
  let service: NetworkInfoHttpService;
  let port: number;
  let baseUrl: string;
  let clientConfig: CreateHttpProviderConfig<NetworkInfoProvider>;
  let config: HttpServerConfig;
  let cardanoNode: CardanoNode;
  let provider: NetworkInfoProvider;

  const epochPollInterval = 2 * 1000;
  const cache = new InMemoryCache(UNLIMITED_CACHE_TTL);
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING, max: 1, min: 1 });

  const mockEraSummaries: EraSummary[] = [
    { parameters: { epochLength: 21_600, slotLength: 20_000 }, start: { slot: 0, time: new Date(1_563_999_616_000) } },
    {
      parameters: { epochLength: 432_000, slotLength: 1000 },
      start: { slot: 1_598_400, time: new Date(1_595_964_016_000) }
    }
  ];

  describe('unhealthy NetworkInfoProvider', () => {
    beforeEach(async () => {
      port = await getPort();
      baseUrl = `http://localhost:${port}/network-info`;
      clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
      config = { listen: { port } };
      cardanoNode = {
        eraSummaries: jest.fn(() => Promise.resolve(mockEraSummaries)),
        initialize: jest.fn(() => Promise.resolve()),
        shutdown: jest.fn(() => Promise.resolve()),
        systemStart: jest.fn(() => Promise.resolve(new Date(1_563_999_616_000)))
      };
      networkInfoProvider = {
        currentWalletProtocolParameters: jest.fn(),
        genesisParameters: jest.fn(),
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        ledgerTip: jest.fn(),
        lovelaceSupply: jest.fn(),
        stake: jest.fn(),
        timeSettings: jest.fn()
      } as unknown as DbSyncNetworkInfoProvider;
    });

    it('should not throw during service create if the NetworkInfoProvider is unhealthy', () => {
      expect(() => new NetworkInfoHttpService({ networkInfoProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the NetworkInfoProvider is unhealthy', async () => {
      service = new NetworkInfoHttpService({ networkInfoProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy state', () => {
    const dbConnectionQuerySpy = jest.spyOn(db, 'query');
    const invalidateCacheSpy = jest.spyOn(cache, 'invalidate');

    beforeEach(async () => {
      await cache.clear();
      jest.clearAllMocks();
    });

    beforeAll(async () => {
      port = await getPort();
      baseUrl = `http://localhost:${port}/network-info`;
      cardanoNode = {
        eraSummaries: jest.fn(() => Promise.resolve(mockEraSummaries)),
        initialize: jest.fn(() => Promise.resolve()),
        shutdown: jest.fn(() => Promise.resolve()),
        systemStart: jest.fn(() => Promise.resolve(new Date(1_563_999_616_000)))
      };
      config = { listen: { port } };
      networkInfoProvider = new DbSyncNetworkInfoProvider(
        { cardanoNodeConfigPath, epochPollInterval },
        { cache, cardanoNode, db }
      );
      service = new NetworkInfoHttpService({ networkInfoProvider });
      httpServer = new HttpServer(config, { services: [service] });
      clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
      provider = networkInfoHttpProvider(clientConfig);

      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await db.end();
      await httpServer.shutdown();
      await cache.shutdown();
      jest.clearAllTimers();
    });

    beforeEach(async () => {
      await cache.clear();
      dbConnectionQuerySpy.mockClear();
      invalidateCacheSpy.mockClear();
    });

    describe('start', () => {
      it('should start epoch polling once the db provider is initialized and started', async () => {
        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeUndefined();
        expect(cache.keys().length).toEqual(0);

        await sleep(epochPollInterval * 2);

        expect(cache.keys().length).toEqual(1);
        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeDefined();
        expect(invalidateCacheSpy).not.toHaveBeenCalled();
      });
    });

    describe('/health', () => {
      it('forwards the networkInfoProvider health response', async () => {
        const res = await axios.post(`${baseUrl}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/time-settings', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/time-settings`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrl}/time-settings`,
              { args: [] },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const response = await provider.timeSettings();
        expect(response[0].slotLength).toBeDefined();
      });
    });

    describe('/stake', () => {
      const stakeTotalQueriesCount = 2;
      const DB_POLL_QUERIES_COUNT = 1;

      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/stake`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/stake`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const response = await provider.stake();
        expect(response.active).toBeGreaterThan(0);
        expect(response.live).toBeGreaterThan(0);
      });

      it('should query the DB only once when the response is cached', async () => {
        await provider.stake();
        await provider.stake();
        expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(stakeTotalQueriesCount);
        expect(cache.keys().length).toEqual(stakeTotalQueriesCount);
      });

      it('should call db-sync queries again once the cache is cleared', async () => {
        await provider.stake();
        await cache.clear();
        expect(cache.keys().length).toEqual(0);

        await provider.stake();
        expect(dbConnectionQuerySpy).toBeCalledTimes(stakeTotalQueriesCount * 2);
      });

      it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
        const currentEpochNo = 205;
        const totalQueriesCount = stakeTotalQueriesCount + DB_POLL_QUERIES_COUNT;

        await provider.stake();

        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeUndefined();
        expect(cache.keys().length).toEqual(stakeTotalQueriesCount);

        await sleep(epochPollInterval);

        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toEqual(currentEpochNo);
        expect(cache.keys().length).toEqual(totalQueriesCount);
        expect(dbConnectionQuerySpy).toBeCalledTimes(totalQueriesCount);
        expect(invalidateCacheSpy).not.toHaveBeenCalled();
      });

      it(
        'should invalidate cached epoch values once the epoch rollover is captured by polling',
        wrapWithTransaction(async (dbConnection) => {
          const greaterEpoch = 255;

          await provider.stake();
          await sleep(epochPollInterval);

          expect(cache.keys().length).toEqual(stakeTotalQueriesCount + DB_POLL_QUERIES_COUNT);
          await ingestDbData(
            dbConnection,
            'epoch',
            ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
            [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
          );

          await sleep(epochPollInterval);
          expect(invalidateCacheSpy).toHaveBeenCalledWith([
            NetworkInfoCacheKey.TOTAL_SUPPLY,
            NetworkInfoCacheKey.ACTIVE_STAKE,
            NetworkInfoCacheKey.ERA_SUMMARIES
          ]);

          expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toEqual(greaterEpoch);
          expect(cache.keys().length).toEqual(2);

          await sleep(epochPollInterval);
        }, db)
      );
    });

    describe('/lovelace-supply', () => {
      const dbSyncQueriesCount = 2;
      const DB_POLL_QUERIES_COUNT = 1;

      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/lovelace-supply`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrl}/lovelace-supply`,
              { args: [] },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const { maxLovelaceSupply } = await loadGenesisData(cardanoNodeConfigPath);
        const response = await provider.lovelaceSupply();
        expect(response.circulating).toBeGreaterThan(0n);
        expect(response.total).toBeLessThan(maxLovelaceSupply);
      });

      // FIXME: When upstream bug is fixed. https://github.com/input-output-hk/cardano-db-sync/issues/942
      //        Total supply is incorrect, so we can't assert it's larger than circulating
      it.skip('lovelaceSupply (with better circulating supply assertion)', async () => {
        const { maxLovelaceSupply } = await loadGenesisData(cardanoNodeConfigPath);
        const response = await provider.lovelaceSupply();
        // Replaces the weak assertion on line 326
        expect(response.total).toBeGreaterThan(response.circulating);
        expect(response.total).toBeLessThan(maxLovelaceSupply);
      });

      it('should query only once when the response is cached', async () => {
        await provider.lovelaceSupply();
        await provider.lovelaceSupply();
        expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(cacheItemsInSupplySummaryCount);
      });

      it('should call queries again once the cache is cleared', async () => {
        await cache.clear();
        await provider.lovelaceSupply();
        expect(cache.keys().length).toEqual(cacheItemsInSupplySummaryCount);
        expect(dbConnectionQuerySpy).toBeCalledTimes(2);
        await cache.clear();
        expect(cache.keys().length).toEqual(0);
        await provider.lovelaceSupply();
        expect(dbConnectionQuerySpy).toBeCalledTimes(dbSyncQueriesCount * 2);
      });

      it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
        const currentEpochNo = 205;
        const totalDbQueriesCount = dbSyncQueriesCount + DB_POLL_QUERIES_COUNT;
        await provider.lovelaceSupply();
        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toBeUndefined();
        expect(cache.keys().length).toEqual(2);
        await sleep(epochPollInterval);
        expect(cache.getVal(NetworkInfoCacheKey.CURRENT_EPOCH)).toEqual(currentEpochNo);
        expect(cache.keys().length).toEqual(3);
        expect(dbConnectionQuerySpy).toBeCalledTimes(totalDbQueriesCount);
        expect(invalidateCacheSpy).not.toHaveBeenCalled();
      });
    });

    describe('/ledger-tip', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/ledger-tip`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/ledger-tip`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const response = await provider.ledgerTip();
        expect(response.slot).toBeDefined();
      });
    });

    describe('/current-wallet-protocol-parameters', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/current-wallet-protocol-parameters`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrl}/current-wallet-protocol-parameters`,
              { args: [] },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const response = await provider.currentWalletProtocolParameters();
        expect(response.maxTxSize).toBeDefined();
      });
    });

    describe('/genesis-parameters', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/genesis-parameters`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrl}/genesis-parameters`,
              { args: [] },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });
      it('successful request', async () => {
        const response = await provider.genesisParameters();
        expect(response.networkMagic).toBeDefined();
      });
    });
  });
});
