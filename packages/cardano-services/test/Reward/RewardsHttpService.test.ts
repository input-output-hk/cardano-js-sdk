/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure, RewardsProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, rewardsHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncRewardsProvider, HttpServer, HttpServerConfig, RewardsHttpService } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
import { mockCardanoNode, responseWithServiceState } from '../../../core/test/CardanoNode/mocks';
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

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/rewards`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
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

  describe('healthy state', () => {
    beforeAll(async () => {
      cardanoNode = mockCardanoNode() as unknown as OgmiosCardanoNode;
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
        expect(res.data).toEqual(responseWithServiceState);
      });

      it('forwards the rewardsProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(responseWithServiceState);
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
      const rewardAccount = Cardano.RewardAccount('stake_test1upd9j9rwxeu44xfxnrl6sqsswf9k60gcdjuy2gz6zyu2jmqyvn80c');

      describe('rewardAccountBalance', () => {
        it('returns address balance', async () => {
          const response = await provider.rewardAccountBalance({ rewardAccount });
          expect(response).toMatchSnapshot();
        });

        it('returns address balance 0 when it has no rewards', async () => {
          const response = await provider.rewardAccountBalance({
            rewardAccount: Cardano.RewardAccount('stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6')
          });
          expect(response).toMatchSnapshot();
        });
      });

      describe('rewardsHistory', () => {
        it('returns rewards address history', async () => {
          const response = await provider.rewardsHistory({
            rewardAccounts: [rewardAccount]
          });
          expect(response).toMatchSnapshot();
        });

        it('returns no rewards address history for empty reward accounts', async () => {
          const response = await provider.rewardsHistory({
            rewardAccounts: []
          });
          expect(response).toMatchSnapshot();
        });

        it('returns address rewards history with epochs ', async () => {
          const accountWithRewardsAtEpoch76 = Cardano.RewardAccount(
            'stake_test1up32f2hrv5ytqk8ad6e4apss5zrrjjlrkjhrksypn5g08fqrqf9gr'
          );
          const response = await provider.rewardsHistory({
            epochs: {
              lowerBound: 75,
              upperBound: 76
            },
            rewardAccounts: [accountWithRewardsAtEpoch76]
          });
          expect(response).toMatchSnapshot();
        });

        it('returns rewards address history of the epochs filtered', async () => {
          const response = await provider.rewardsHistory({
            epochs: {
              lowerBound: 10
            },
            rewardAccounts: [rewardAccount]
          });
          expect(response).toMatchSnapshot();
        });

        it('returns rewards address history some of the epochs filter', async () => {
          const response = await provider.rewardsHistory({
            epochs: {
              upperBound: 10
            },
            rewardAccounts: [rewardAccount]
          });
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
