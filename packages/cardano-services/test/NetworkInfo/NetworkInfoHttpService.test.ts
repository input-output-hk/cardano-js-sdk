/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-identical-functions */
import { CreateHttpProviderConfig, networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncEpochPollService, LedgerTipModel, findLedgerTip, loadGenesisData } from '../../src/util';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { HttpServer, HttpServerConfig } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { NetworkInfoFixtureBuilder } from './fixtures/FixtureBuilder';
import { NetworkInfoProvider } from '@cardano-sdk/core';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { ingestDbData, sleep, wrapWithTransaction } from '../util';
import { logger } from '@cardano-sdk/util-dev';
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
  let cardanoNode: OgmiosCardanoNode;
  let provider: NetworkInfoProvider;
  let lastBlockNoInDb: LedgerTipModel;

  const epochPollInterval = 2 * 1000;
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };
  const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
  const db = new Pool({
    connectionString: process.env.POSTGRES_CONNECTION_STRING,
    max: 1,
    min: 1
  });
  const fixtureBuilder = new NetworkInfoFixtureBuilder(db, logger);
  const epochMonitor = new DbSyncEpochPollService(db, epochPollInterval!);

  describe('healthy state', () => {
    const dbConnectionQuerySpy = jest.spyOn(db, 'query');
    const clearCacheSpy = {
      db: jest.spyOn(cache.db, 'clear')
    };

    beforeAll(async () => {
      port = await getPort();
      baseUrl = `http://localhost:${port}/network-info`;
      lastBlockNoInDb = (await db.query<LedgerTipModel>(findLedgerTip)).rows[0];
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({
          blockNo: lastBlockNoInDb.block_no,
          hash: lastBlockNoInDb.hash.toString('hex'),
          projectedTip: {
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            slot: Number(lastBlockNoInDb.slot_no)
          },
          slot: Number(lastBlockNoInDb.slot_no),
          withTip: true
        })
      ) as unknown as OgmiosCardanoNode;
      config = { listen: { port } };
      const genesisData = await loadGenesisData(cardanoNodeConfigPath);
      const deps = { cache, cardanoNode, db, epochMonitor, genesisData, logger };
      networkInfoProvider = new DbSyncNetworkInfoProvider(deps);
      service = new NetworkInfoHttpService({ logger, networkInfoProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
      provider = networkInfoHttpProvider(clientConfig);

      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await db.end();
      await httpServer.shutdown();
      await cache.db.shutdown();
      await cache.healthCheck.shutdown();
      jest.clearAllTimers();
    });

    beforeEach(async () => {
      await cache.db.clear();
      await cache.healthCheck.clear();
      jest.clearAllMocks();
      dbConnectionQuerySpy.mockClear();
      clearCacheSpy.db.mockClear();
    });

    describe('start', () => {
      it('should start epoch monitor once the db provider is initialized and started', async () => {
        await sleep(epochPollInterval * 2);

        expect(await epochMonitor.getLastKnownEpoch()).toBeDefined();
        expect(clearCacheSpy).not.toHaveBeenCalled();
      });
    });

    describe('/health', () => {
      it('forwards the networkInfoProvider health response with HTTP request', async () => {
        const res = await axios.post(`${baseUrl}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        );
      });

      it('forwards the networkInfoProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        );
      });
    });

    describe('/era-summaries', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/era-summaries`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          expect.assertions(2);
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

      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/stake`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          expect.assertions(2);
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
        expect(cache.db.keys().length).toEqual(stakeTotalQueriesCount);
      });

      it('should call db-sync queries again once the cache is cleared', async () => {
        const cardanoNodeStakeSpy = jest.spyOn(cardanoNode, 'stakeDistribution');
        await provider.stake();
        await cache.db.clear();
        expect(cache.db.keys().length).toEqual(0);

        await provider.stake();
        expect(dbConnectionQuerySpy).toBeCalledTimes(stakeDbQueriesCount * 2);
        expect(cardanoNodeStakeSpy).toBeCalledTimes(stakeNodeQueriesCount * 2);
      });

      it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
        const cardanoNodeStakeSpy = jest.spyOn(cardanoNode, 'stakeDistribution');
        const currentEpochNo = await fixtureBuilder.getLasKnownEpoch();
        await provider.stake();
        expect(cache.db.keys().length).toEqual(stakeTotalQueriesCount);
        await sleep(epochPollInterval * 2);
        expect(await epochMonitor.getLastKnownEpoch()).toEqual(currentEpochNo);
        expect(cache.db.keys().length).toEqual(stakeTotalQueriesCount);
        expect(dbConnectionQuerySpy).toHaveBeenCalled();
        expect(cardanoNodeStakeSpy).toHaveBeenCalledTimes(stakeNodeQueriesCount);
        expect(clearCacheSpy).not.toHaveBeenCalled();
      });

      it(
        'should invalidate cached epoch values once the epoch rollover is captured by polling',
        wrapWithTransaction(async (dbConnection) => {
          const greaterEpoch = 255;

          await provider.stake();
          await sleep(epochPollInterval);

          expect(cache.db.keys().length).toEqual(stakeTotalQueriesCount);
          await ingestDbData(
            dbConnection,
            'epoch',
            ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
            [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
          );

          await sleep(epochPollInterval);
          expect(clearCacheSpy).toHaveBeenCalled();

          expect(await epochMonitor.getLastKnownEpoch()).toEqual(greaterEpoch);
          expect(cache.db.keys().length).toEqual(0);
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
          expect.assertions(2);
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
        await cache.db.clear();
        await provider.lovelaceSupply();
        expect(cache.db.keys().length).toEqual(cacheItemsInSupplySummaryCount);
        expect(dbConnectionQuerySpy).toBeCalledTimes(2);
        await cache.db.clear();
        expect(cache.db.keys().length).toEqual(0);
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
          expect.assertions(2);
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

    describe('/protocol-parameters', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/protocol-parameters`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          expect.assertions(2);
          try {
            await axios.post(`${baseUrl}/protocol-parameters`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('successful request', async () => {
        const response = await provider.protocolParameters();
        expect(response.maxTxSize).toBeDefined();
      });
    });

    describe('/current-wallet-protocol-parameters', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/current-wallet-protocol-parameters`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          expect.assertions(2);
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
    });

    describe('/genesis-parameters', () => {
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}/genesis-parameters`, {})).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          expect.assertions(2);
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
});
