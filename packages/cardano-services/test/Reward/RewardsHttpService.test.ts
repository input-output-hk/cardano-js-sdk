/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure, RewardsProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, rewardsHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncRewardsProvider, HttpServer, HttpServerConfig, RewardsHttpService } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
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

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/rewards`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
  });

  afterEach(async () => {
    jest.resetAllMocks();
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
      httpServer = new HttpServer(config, { logger, services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      rewardsProvider = new DbSyncRewardsProvider(dbConnection, logger);
      service = new RewardsHttpService({ logger, rewardsProvider });
      httpServer = new HttpServer(config, { logger, services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the stakePoolSearchProvider health response', async () => {
        const res = await axios.post(`${baseUrl}/health`, {}, { headers: { 'Content-Type': APPLICATION_JSON } });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/history', () => {
      const historyUrl = '/history';
      const rewardAddress = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${baseUrl}${historyUrl}`, {
              args: [
                {
                  epochs: {
                    lowerBound: 1,
                    upperBound: 14
                  },
                  rewardAccounts: [rewardAddress]
                }
              ]
            })
          ).status
        ).toEqual(200);
      });
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${baseUrl}${historyUrl}`,
            {
              args: [
                {
                  rewardAccounts: [rewardAddress]
                }
              ]
            },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      it('returns 400 coded respons if the request is bad formed', async () => {
        try {
          await axios.post(`${baseUrl}${historyUrl}`, { args: [{ field: 'value' }] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });
    });

    describe('/account-balance', () => {
      const accountBalanceUrl = '/account-balance';
      const rewardAddress = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${baseUrl}${accountBalanceUrl}`, {
              args: [rewardAddress]
            })
          ).status
        ).toEqual(200);
      });
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${baseUrl}${accountBalanceUrl}`,
            { args: [rewardAddress] },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
      it('returns 400 coded respons if the request is bad formed', async () => {
        try {
          await axios.post(`${baseUrl}${accountBalanceUrl}`, { args: [{ address: 'asd' }] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });
    });

    describe('with rewardsHttpProvider', () => {
      let provider: RewardsProvider;
      beforeEach(() => {
        provider = rewardsHttpProvider(clientConfig);
      });
      const rewardAcc = Cardano.RewardAccount('stake_test1upd9j9rwxeu44xfxnrl6sqsswf9k60gcdjuy2gz6zyu2jmqyvn80c');
      describe('rewardAccountBalance', () => {
        it('returns address balance', async () => {
          const response = await provider.rewardAccountBalance(rewardAcc);
          expect(response).toMatchSnapshot();
        });
        it('returns address balance 0 when it has no rewards', async () => {
          const response = await provider.rewardAccountBalance(
            Cardano.RewardAccount('stake_test1uzxvhl83q8ujv2yvpy6n2krvpdlqqx28h7e9vsk6re43h3c3kufy6')
          );
          expect(response).toMatchSnapshot();
        });
      });
      describe('rewardsHistory', () => {
        it('returns rewards address history', async () => {
          const response = await provider.rewardsHistory({
            rewardAccounts: [rewardAcc]
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
            rewardAccounts: [rewardAcc]
          });
          expect(response).toMatchSnapshot();
        });
        it('returns rewards address history some of the epochs filter', async () => {
          const response = await provider.rewardsHistory({
            epochs: {
              upperBound: 10
            },
            rewardAccounts: [rewardAcc]
          });
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
