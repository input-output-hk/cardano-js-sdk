/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure, RewardsProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, rewardsHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncRewardsProvider, HttpServer, HttpServerConfig, RewardsHttpService } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { LedgerTipModel, findLedgerTip } from '../../src/util/DbSyncProvider';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { RewardsFixtureBuilder } from './fixtures/FixtureBuilder';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { logger } from '@cardano-sdk/util-dev';
import axios from 'axios';

const APPLICATION_JSON = 'application/json';
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const BAD_REQUEST_STRING = 'Request failed with status code 400';
describe('RewardsHttpService', () => {
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let rewardsProvider: DbSyncRewardsProvider;
  let service: RewardsHttpService;
  let port: number;
  let baseUrl: string;
  let clientConfig: CreateHttpProviderConfig<RewardsProvider>;
  let config: HttpServerConfig;
  let cardanoNode: OgmiosCardanoNode;
  let provider: RewardsProvider;
  let lastBlockNoInDb: Cardano.BlockNo;
  let fixtureBuilder: RewardsFixtureBuilder;
  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/rewards`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbConnection = new Pool({
      connectionString: process.env.POSTGRES_CONNECTION_STRING
    });
    fixtureBuilder = new RewardsFixtureBuilder(dbConnection, logger);
  });

  describe('unhealthy RewardsProvider', () => {
    beforeEach(async () => {
      rewardsProvider = {
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        rewardAccountBalance: jest.fn(),
        rewardsHistory: jest.fn()
      } as unknown as DbSyncRewardsProvider;
    });
    it('should not throw during service create if the RewardsProvider is unhealthy', () => {
      expect(() => new RewardsHttpService({ logger, rewardsProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the RewardsProvider is unhealthy', async () => {
      service = new RewardsHttpService({ logger, rewardsProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [], services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    beforeAll(async () => {
      lastBlockNoInDb = Cardano.BlockNo((await dbConnection.query<LedgerTipModel>(findLedgerTip)).rows[0].block_no);
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({ blockNo: lastBlockNoInDb.valueOf() })
      ) as unknown as OgmiosCardanoNode;
      rewardsProvider = new DbSyncRewardsProvider(
        { paginationPageSizeLimit: 5 },
        { cardanoNode, db: dbConnection, logger }
      );
      service = new RewardsHttpService({ logger, rewardsProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      provider = rewardsHttpProvider(clientConfig);
      await httpServer.initialize();
      await httpServer.start();
    });
    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the rewardsProvider health response with HTTP request', async () => {
        const res = await axios.post(`${baseUrl}/health`, {}, { headers: { 'Content-Type': APPLICATION_JSON } });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb.valueOf() }));
      });

      it('forwards the rewardsProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb.valueOf() }));
      });
    });

    describe('/history', () => {
      const historyUrl = '/history';
      const rewardAddress = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${baseUrl}${historyUrl}`, {
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
            `${baseUrl}${historyUrl}`,
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
          await axios.post(`${baseUrl}${historyUrl}`, { field: 'value' });
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
            `${baseUrl}${historyUrl}`,
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
            await axios.post(`${baseUrl}${accountBalanceUrl}`, {
              rewardAccount
            })
          ).status
        ).toEqual(200);
      });
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${baseUrl}${accountBalanceUrl}`,
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
          await axios.post(`${baseUrl}${accountBalanceUrl}`, { address: 'asd' });
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
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', rewards: 0n });
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
              lowerBound: Cardano.EpochNo(5),
              upperBound: Cardano.EpochNo(6)
            },
            rewardAccounts: [rewardAccount]
          });

          expect(response.get(rewardAccount)!.length).toBe(2);

          let lowestEpoch = Number.MAX_SAFE_INTEGER;
          let highestEpoch = 0;
          for (const result of response.get(rewardAccount)!) {
            lowestEpoch = Math.min(lowestEpoch, result.epoch.valueOf());
            highestEpoch = Math.max(highestEpoch, result.epoch.valueOf());
          }

          expect(lowestEpoch).toBeGreaterThanOrEqual(5);
          expect(highestEpoch).toBeLessThanOrEqual(6);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', rewards: 0n });
        });

        it('returns rewards address history of the epochs filtered', async () => {
          const rewardAccount = (await fixtureBuilder.getRewardAccounts(1))[0];
          const response = await provider.rewardsHistory({
            epochs: {
              lowerBound: Cardano.EpochNo(5)
            },
            rewardAccounts: [rewardAccount]
          });
          expect(response.get(rewardAccount)!.length).toBeGreaterThan(0);

          let lowestEpoch = Number.MAX_SAFE_INTEGER;
          for (const result of response.get(rewardAccount)!) {
            lowestEpoch = Math.min(lowestEpoch, result.epoch.valueOf());
          }

          expect(lowestEpoch).toBeGreaterThanOrEqual(5);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', rewards: 0n });
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
            highestEpoch = Math.min(highestEpoch, result.epoch.valueOf());
          }

          expect(highestEpoch).toBeLessThanOrEqual(10);
          expect(response.get(rewardAccount)![0]).toMatchShapeOf({ epoch: '0', rewards: 0n });
        });
      });
    });
  });
});
