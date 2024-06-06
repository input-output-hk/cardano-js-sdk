/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import {
  DbSyncRewardsProvider,
  HttpServer,
  InMemoryCache,
  RewardsHttpService,
  UNLIMITED_CACHE_TTL
} from '../../src/index.js';
import { INFO, createLogger } from 'bunyan';
import { Pool } from 'pg';
import { RewardsFixtureBuilder } from './fixtures/FixtureBuilder.js';
import { clearDbPools, servicesWithVersionPath as services } from '../util.js';
import { findLedgerTip } from '../../src/util/DbSyncProvider/index.js';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks.js';
import { logger } from '@cardano-sdk/util-dev';
import { rewardsHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';
import type { CreateHttpProviderConfig } from '@cardano-sdk/cardano-services-client';
import type { DbPools, LedgerTipModel } from '../../src/util/DbSyncProvider/index.js';
import type { HttpServerConfig } from '../../src/index.js';
import type { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import type { RewardsProvider } from '@cardano-sdk/core';

const APPLICATION_JSON = 'application/json';
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const BAD_REQUEST_STRING = 'Request failed with status code 400';

describe('RewardsHttpService', () => {
  let dbPools: DbPools;
  let httpServer: HttpServer;
  let rewardsProvider: DbSyncRewardsProvider;
  let service: RewardsHttpService;
  let port: number;
  let baseUrl: string;
  let baseUrlWithVersion: string;
  let clientConfig: CreateHttpProviderConfig<RewardsProvider>;
  let config: HttpServerConfig;
  let cardanoNode: OgmiosCardanoNode;
  let provider: RewardsProvider;
  let lastBlockNoInDb: LedgerTipModel;
  let fixtureBuilder: RewardsFixtureBuilder;
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
    baseUrlWithVersion = `${baseUrl}${services.rewards.versionPath}/${services.rewards.name}`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbPools = {
      healthCheck: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC }),
      main: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC })
    };
    fixtureBuilder = new RewardsFixtureBuilder(dbPools.main, logger);
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    beforeAll(async () => {
      lastBlockNoInDb = (await dbPools.main.query<LedgerTipModel>(findLedgerTip)).rows[0];
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
      rewardsProvider = new DbSyncRewardsProvider(
        { paginationPageSizeLimit: 5 },
        { cache, cardanoNode, dbPools, logger }
      );
      service = new RewardsHttpService({ logger, rewardsProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      provider = rewardsHttpProvider(clientConfig);
      await httpServer.initialize();
      await httpServer.start();
    });
    afterAll(async () => {
      await clearDbPools(dbPools);
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the rewardsProvider health response with HTTP request', async () => {
        const res = await axios.post(
          `${baseUrlWithVersion}/health`,
          {},
          { headers: { 'Content-Type': APPLICATION_JSON } }
        );
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

      it('forwards the rewardsProvider health response with provider client', async () => {
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

    describe('/history', () => {
      const historyUrl = '/history';
      const rewardAddress = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${baseUrlWithVersion}${historyUrl}`, {
              epochs: {
                lowerBound: 1,
                upperBound: 14
              },
              rewardAccounts: [rewardAddress]
            })
          ).status
        ).toEqual(200);
      });
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${baseUrlWithVersion}${historyUrl}`,
            {
              rewardAccounts: [rewardAddress]
            },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
      it('returns 400 coded response if the request is bad formed', async () => {
        expect.assertions(2);
        try {
          await axios.post(`${baseUrlWithVersion}${historyUrl}`, { field: 'value' });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });
      it('returns a 400 coded error if reward accounts are greater than pagination page size limit', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${baseUrlWithVersion}${historyUrl}`,
            {
              rewardAccounts: [
                rewardAddress,
                'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d',
                'stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj',
                'stake_test1uzwd0ng8pw7vvhm4k3s28azx9c6ytug60uh35jvztgg03rge58jf8',
                'stake_test1urpklgzqsh9yqz8pkyuxcw9dlszpe5flnxjtl55epla6ftqktdyfz',
                'stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv'
              ]
            },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
    });
    describe('/account-balance', () => {
      const accountBalanceUrl = '/account-balance';
      const rewardAccount = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${baseUrlWithVersion}${accountBalanceUrl}`, {
              rewardAccount
            })
          ).status
        ).toEqual(200);
      });
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${baseUrlWithVersion}${accountBalanceUrl}`,
            { rewardAccount },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
      it('returns 400 coded response if the request is bad formed', async () => {
        expect.assertions(2);
        try {
          await axios.post(`${baseUrlWithVersion}${accountBalanceUrl}`, { address: 'asd' });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });
    });

    describe('with rewardsHttpProvider', () => {
      describe('rewardAccountBalance', () => {
        it('returns address balance', async () => {
          const rewardAccount = (await fixtureBuilder.getRewardAccounts(1))[0];
          const response = await provider.rewardAccountBalance({ rewardAccount });
          expect(response).toBeGreaterThan(0);
          expect(() => Cardano.RewardAccount(rewardAccount as unknown as string)).not.toThrow();
        });

        it('returns address balance 0 when it has no rewards', async () => {
          const response = await provider.rewardAccountBalance({
            rewardAccount: Cardano.RewardAccount('stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6')
          });
          expect(response).toBe(0n);
        });
      });

      describe('rewardsHistory', () => {
        it('returns rewards address history', async () => {
          const rewardAccount = (await fixtureBuilder.getRewardAccounts(1))[0];
          const response = await provider.rewardsHistory({
            rewardAccounts: [rewardAccount]
          });
          expect(response.get(rewardAccount)!.length).toBeGreaterThan(0);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', poolId: 'pool_id', rewards: 0n });
        });

        it('returns no rewards address history for empty reward accounts', async () => {
          const response = await provider.rewardsHistory({
            rewardAccounts: []
          });
          expect(response.size).toBe(0);
        });

        it('returns address rewards history with epochs ', async () => {
          const rewardAccount = (await fixtureBuilder.getRewardAccounts(1))[0];
          const response = await provider.rewardsHistory({
            epochs: {
              lowerBound: Cardano.EpochNo(1),
              upperBound: Cardano.EpochNo(2)
            },
            rewardAccounts: [rewardAccount]
          });

          expect(response.get(rewardAccount)!.length).toBe(2);

          let lowestEpoch = Number.MAX_SAFE_INTEGER;
          let highestEpoch = 0;
          for (const result of response.get(rewardAccount)!) {
            lowestEpoch = Math.min(lowestEpoch, result.epoch);
            highestEpoch = Math.max(highestEpoch, result.epoch);
          }

          expect(lowestEpoch).toBeGreaterThanOrEqual(1);
          expect(highestEpoch).toBeLessThanOrEqual(2);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', poolId: 'pool_id', rewards: 0n });
        });

        it('returns rewards address history of the epochs filtered', async () => {
          const rewardAccount = (await fixtureBuilder.getRewardAccounts(1))[0];
          const response = await provider.rewardsHistory({
            epochs: {
              lowerBound: Cardano.EpochNo(1)
            },
            rewardAccounts: [rewardAccount]
          });
          expect(response.get(rewardAccount)!.length).toBeGreaterThan(0);

          let lowestEpoch = Number.MAX_SAFE_INTEGER;
          for (const result of response.get(rewardAccount)!) {
            lowestEpoch = Math.min(lowestEpoch, result.epoch);
          }

          expect(lowestEpoch).toBeGreaterThanOrEqual(1);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', poolId: 'pool_id', rewards: 0n });
        });

        it('returns rewards address history some of the epochs filter', async () => {
          const rewardAccount = (await fixtureBuilder.getRewardAccounts(1))[0];
          const response = await provider.rewardsHistory({
            epochs: {
              upperBound: Cardano.EpochNo(10)
            },
            rewardAccounts: [rewardAccount]
          });
          expect(response.get(rewardAccount)!.length).toBeGreaterThan(0);

          let highestEpoch = Number.MAX_SAFE_INTEGER;
          for (const result of response.get(rewardAccount)!) {
            highestEpoch = Math.min(highestEpoch, result.epoch);
          }

          expect(highestEpoch).toBeLessThanOrEqual(10);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', poolId: 'pool_id', rewards: 0n });
        });
      });
    });
  });
});
