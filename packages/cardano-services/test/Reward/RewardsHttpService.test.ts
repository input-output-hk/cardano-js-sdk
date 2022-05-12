/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import { Cardano, RewardsProvider } from '@cardano-sdk/core';
import { DbSyncRewardsProvider, HttpServer, HttpServerConfig, RewardsHttpService } from '../../src';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { rewardsHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';
import got from 'got';

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
  let apiUrlBase: string;
  let config: HttpServerConfig;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/rewards`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      rewardsProvider = new DbSyncRewardsProvider(dbConnection);
      service = RewardsHttpService.create({ rewardsProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the stakePoolSearchProvider health response', async () => {
        const res = await got.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
    });

    describe('/history', () => {
      const historyUrl = '/history';
      const rewardAddress = 'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await axios.post(`${apiUrlBase}${historyUrl}`, {
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
            `${apiUrlBase}${historyUrl}`,
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
          await axios.post(`${apiUrlBase}${historyUrl}`, { args: [{ field: 'value' }] });
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
            await axios.post(`${apiUrlBase}${accountBalanceUrl}`, {
              args: [rewardAddress]
            })
          ).status
        ).toEqual(200);
      });
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${apiUrlBase}${accountBalanceUrl}`,
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
          await axios.post(`${apiUrlBase}${accountBalanceUrl}`, { args: [{ address: 'asd' }] });
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
        provider = rewardsHttpProvider(apiUrlBase);
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
          const response = await provider.rewardsHistory({
            epochs: {
              lowerBound: 10,
              upperBound: 11
            },
            rewardAccounts: [rewardAcc]
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
