/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-identical-functions */
import { CardanoNode, NetworkInfoProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncEpochPollService } from '../../src/util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { HttpServer, HttpServerConfig } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { ingestDbData, sleep, wrapWithTransaction } from '../util';
import { loadGenesisData } from '../../src/NetworkInfo/DbSyncNetworkInfoProvider/mappers';
import { dummyLogger as logger } from 'ts-log';
import { mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
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
  const epochMonitor = new DbSyncEpochPollService(db, epochPollInterval!);

  describe('unhealthy NetworkInfoProvider', () => {
    beforeEach(async () => {
      port = await getPort();
      baseUrl = `http://localhost:${port}/network-info`;
      clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
      config = { listen: { port } };
      cardanoNode = mockCardanoNode();
      networkInfoProvider = {
        currentWalletProtocolParameters: jest.fn(),
        eraSummaries: jest.fn(),
        genesisParameters: jest.fn(),
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        ledgerTip: jest.fn(),
        lovelaceSupply: jest.fn(),
        stake: jest.fn()
      } as unknown as DbSyncNetworkInfoProvider;
    });

    it('should not throw during service create if the NetworkInfoProvider is unhealthy', () => {
      expect(() => new NetworkInfoHttpService({ logger, networkInfoProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the NetworkInfoProvider is unhealthy', async () => {
      service = new NetworkInfoHttpService({ logger, networkInfoProvider });
      httpServer = new HttpServer(config, { logger, services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy state', () => {
    const dbConnectionQuerySpy = jest.spyOn(db, 'query');
    const clearCacheSpy = jest.spyOn(cache, 'clear');

    beforeAll(async () => {
      port = await getPort();
      baseUrl = `http://localhost:${port}/network-info`;
      cardanoNode = mockCardanoNode();
      config = { listen: { port } };
      networkInfoProvider = new DbSyncNetworkInfoProvider(
        { cardanoNodeConfigPath },
        { cache, cardanoNode, db, epochMonitor, logger }
      );
      service = new NetworkInfoHttpService({ logger, networkInfoProvider });
      httpServer = new HttpServer(config, { logger, services: [service] });
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
      jest.clearAllMocks();
      dbConnectionQuerySpy.mockClear();
      clearCacheSpy.mockClear();
    });

    describe('start', () => {
      it('should start epoch monitor once the db provider is initialized and started', async () => {
        await sleep(epochPollInterval * 2);

        expect(await epochMonitor.getLastKnownEpoch()).toBeDefined();
        expect(clearCacheSpy).not.toHaveBeenCalled();
      });
    });

    describe('/health', () => {
      it('forwards the networkInfoProvider health response', async () => {
        const res = await axios.post(`${baseUrl}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({
          localNode: {
            ledgerTip: {
              blockNo: 3_391_731,
              hash: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
              slot: 52_819_355
            },
            networkSync: 0.999
          },
          ok: true
        });
      });
    });

    describe('/era-summaries', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/era-summaries`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/era-summaries`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const response = await provider.eraSummaries();
        expect(response[0].parameters.slotLength).toBeDefined();
      });
    });

    describe('/stake', () => {
      const stakeTotalQueriesCount = 2;
      const stakeDbQueriesCount = 1;
      const stakeNodeQueriesCount = 1;
      const DB_POLL_QUERIES_COUNT = 1;

      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/stake`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/stake`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
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
        const cardanoNodeStakeSpy = jest.spyOn(cardanoNode, 'stakeDistribution');
        await provider.stake();
        await provider.stake();
        expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(stakeDbQueriesCount);
        expect(cardanoNodeStakeSpy).toHaveBeenCalledTimes(stakeNodeQueriesCount);
        expect(cache.keys().length).toEqual(stakeTotalQueriesCount);
      });

      it('should call db-sync queries again once the cache is cleared', async () => {
        const cardanoNodeStakeSpy = jest.spyOn(cardanoNode, 'stakeDistribution');
        await provider.stake();
        await cache.clear();
        expect(cache.keys().length).toEqual(0);

        await provider.stake();
        expect(dbConnectionQuerySpy).toBeCalledTimes(stakeDbQueriesCount * 2);
        expect(cardanoNodeStakeSpy).toBeCalledTimes(stakeNodeQueriesCount * 2);
      });

      it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
        const cardanoNodeStakeSpy = jest.spyOn(cardanoNode, 'stakeDistribution');
        const totalQueriesCount = stakeTotalQueriesCount + DB_POLL_QUERIES_COUNT;
        const currentEpochNo = 205;
        await provider.stake();
        expect(cache.keys().length).toEqual(stakeTotalQueriesCount);
        await sleep(epochPollInterval * 2);
        expect(await epochMonitor.getLastKnownEpoch()).toEqual(currentEpochNo);
        expect(cache.keys().length).toEqual(stakeTotalQueriesCount);
        expect(dbConnectionQuerySpy).toBeCalledTimes(totalQueriesCount);
        expect(cardanoNodeStakeSpy).toHaveBeenCalledTimes(stakeNodeQueriesCount);
        expect(clearCacheSpy).not.toHaveBeenCalled();
      });

      it(
        'should invalidate cached epoch values once the epoch rollover is captured by polling',
        wrapWithTransaction(async (dbConnection) => {
          const greaterEpoch = 255;

          await provider.stake();
          await sleep(epochPollInterval);

          expect(cache.keys().length).toEqual(stakeTotalQueriesCount);
          await ingestDbData(
            dbConnection,
            'epoch',
            ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
            [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
          );

          await sleep(epochPollInterval);
          expect(clearCacheSpy).toHaveBeenCalled();

          expect(await epochMonitor.getLastKnownEpoch()).toEqual(greaterEpoch);
          expect(cache.keys().length).toEqual(0);
        }, db)
      );
    });

    describe('/lovelace-supply', () => {
      const dbSyncQueriesCount = 2;

      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/lovelace-supply`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/lovelace-supply`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
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
    });

    describe('/ledger-tip', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/ledger-tip`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/ledger-tip`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
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
          expect((await axios.post(`${baseUrl}/current-wallet-protocol-parameters`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrl}/current-wallet-protocol-parameters`,
              {},
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
          expect((await axios.post(`${baseUrl}/genesis-parameters`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}/genesis-parameters`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
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

  describe('lifecycle methods', () => {
    const dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING, max: 1, min: 1 });

    beforeAll(async () => {
      port = await getPort();
      baseUrl = `http://localhost:${port}/network-info`;
      cardanoNode = mockCardanoNode();
      config = { listen: { port } };
      networkInfoProvider = new DbSyncNetworkInfoProvider(
        { cardanoNodeConfigPath },
        { cache, cardanoNode, db: dbConnection, epochMonitor, logger }
      );
      service = new NetworkInfoHttpService({ logger, networkInfoProvider });
      httpServer = new HttpServer(config, { logger, services: [service] });
      clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
      provider = networkInfoHttpProvider(clientConfig);
    });

    afterAll(async () => {
      await dbConnection.end();
    });

    it('initializes the CardanoNode instance when starting', async () => {
      await httpServer.initialize();
      await httpServer.start();
      expect(cardanoNode.initialize).toBeCalledTimes(1);
    });

    it('shuts the CardanoNode instance down when shutting down', async () => {
      await httpServer.shutdown();
      expect(cardanoNode.shutdown).toBeCalledTimes(1);
    });
  });
});
