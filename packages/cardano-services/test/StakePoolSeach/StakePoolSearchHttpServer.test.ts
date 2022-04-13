/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
// import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { Cardano, StakePoolQueryOptions } from '@cardano-sdk/core';
import {
  DbSyncStakePoolSearchProvider,
  StakePoolSearchHttpServer,
  StakePoolSearchResponse,
  StakePoolSearchServerConfig
} from '../../src';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import got from 'got';

const BAD_REQUEST_STRING = 'Response code 400 (Bad Request)';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

const setAndCondition = (options: StakePoolQueryOptions): StakePoolQueryOptions => ({
  filters: { ...options.filters, _condition: 'and' }
});

const addStatusFilter = (options: StakePoolQueryOptions, status: Cardano.StakePoolStatus): StakePoolQueryOptions => ({
  filters: { ...options.filters, status: [status] }
});

const addPledgeMetFilter = (options: StakePoolQueryOptions, pledgeMet: boolean): StakePoolQueryOptions => ({
  filters: { ...options.filters, pledgeMet }
});

describe('StakePoolSearchHttpServer', () => {
  let stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
  let stakePoolSearchHttpServer: StakePoolSearchHttpServer;
  let port: number;
  let apiUrlBase: string;
  let config: StakePoolSearchServerConfig;
  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}`;
    config = { listen: { port } };
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  const getStatusResponse = async (arg: unknown) => {
    const response = await got.post(`${apiUrlBase}/search`, {
      json: { args: [arg] }
    });
    return response.statusCode;
  };

  const doServerRequest = (arg: unknown) =>
    got
      .post(`${apiUrlBase}/search`, {
        json: { args: [arg] }
      })
      .json() as Promise<StakePoolSearchResponse>;

  describe('healthy state', () => {
    beforeAll(async () => {
      stakePoolSearchProvider = new DbSyncStakePoolSearchProvider(
        new Pool({ connectionString: process.env.DB_CONNECTION_STRING })
      );
      stakePoolSearchHttpServer = StakePoolSearchHttpServer.create({ stakePoolSearchProvider }, config);
      await stakePoolSearchHttpServer.initialize();
      await stakePoolSearchHttpServer.start();
    });

    afterAll(async () => {
      await stakePoolSearchHttpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the stakePoolSearchProvider health response', async () => {
        const res = await got(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
    });

    describe('/search', () => {
      it.skip('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await got.post(`${apiUrlBase}/search`, {
              json: { args: [] }
            })
          ).statusCode
        ).toEqual(200);
      });

      it.skip('returns a 400 coded response if the wrong content type header is used', async () => {
        try {
          await got.post(`${apiUrlBase}/search`, {
            headers: { 'Content-Type': APPLICATION_CBOR }
          });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.statusCode).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      describe('pagination', () => {
        it('should paginate response', async () => {
          const req = {};
          const reqWithPagination = { pagination: { limit: 2, startAt: 1 } };
          const response = await doServerRequest(req);
          const responseWithPagination = await doServerRequest(reqWithPagination);
          expect(response.stakePools.length).toEqual(8);
          expect(responseWithPagination.stakePools.length).toEqual(2);
          expect(response.stakePools[0]).not.toEqual(responseWithPagination.stakePools[0]);
        });
        it('should paginate response with or condition', async () => {
          const req = { filters: { _condition: 'or' } };
          const reqWithPagination = { ...req, pagination: { limit: 2, startAt: 1 } };
          const response = await doServerRequest(req);
          const responseWithPagination = await doServerRequest(reqWithPagination);
          expect(response.stakePools.length).toEqual(8);
          expect(responseWithPagination.stakePools.length).toEqual(2);
          expect(response.stakePools[0]).not.toEqual(responseWithPagination.stakePools[0]);
        });
      });

      describe('search pools by identifier filter', () => {
        // response should be the same despite the high order condition
        it('or condition', async () => {
          const req = {
            filters: {
              _condition: 'or',
              identifier: {
                condition: 'or',
                values: [
                  { name: 'THE AMSTERDAM NODE' },
                  { name: 'banderini' },
                  { ticker: 'TEST' },
                  { id: 'pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' }
                ]
              }
            }
          };
          const response = await doServerRequest(req);
          const reqWithAndCondition = { filters: { ...req.filters, _condition: 'and' } };
          const responseWithAndCondition = await doServerRequest(reqWithAndCondition);
          expect(response).toMatchSnapshot();
          expect(responseWithAndCondition).toEqual(response);
        });
        it('and condition', async () => {
          const req = {
            filters: {
              _condition: 'or',
              identifier: {
                condition: 'and',
                values: [
                  { name: 'CL' },
                  { ticker: 'CLIO' },
                  { id: 'pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' }
                ]
              }
            }
          };
          const response = await doServerRequest(req);
          const reqWithAndCondition = { filters: { ...req.filters, _condition: 'and' } };
          const responseWithAndCondition = await doServerRequest(reqWithAndCondition);
          expect(response).toMatchSnapshot();
          expect(responseWithAndCondition).toEqual(response);
        });
        it('stake pools do not match identifier filter', async () => {
          const req = {
            filters: {
              _condition: 'or',
              identifier: {
                condition: 'and',
                values: [{ name: 'imaginary name' }]
              }
            }
          };
          const response = await doServerRequest(req);
          expect(response).toEqual({ stakePools: [] });
        });
      });
      describe('search pools by status', () => {
        it('search by active status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              _condition: 'or',
              status: [Cardano.StakePoolStatus.Active]
            }
          };
          const response = await doServerRequest(req);
          expect(response).toMatchSnapshot();
        });
        it('search by activating status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              _condition: 'or',
              status: [Cardano.StakePoolStatus.Activating]
            }
          };
          const response = await doServerRequest(req);
          expect(response).toMatchSnapshot();
        });
        it('search by retired status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              _condition: 'or',
              status: [Cardano.StakePoolStatus.Retired]
            }
          };
          const response = await doServerRequest(req);
          expect(response).toMatchSnapshot();
        });
        it('search by retiring status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              _condition: 'or',
              status: [Cardano.StakePoolStatus.Retiring]
            }
          };
          const response = await doServerRequest(req);
          expect(response).toMatchSnapshot();
        });
      });
      describe('search pools by pledge met', () => {
        it('search by pledge met on true', async () => {
          const req = {
            filters: {
              _condition: 'or',
              pledgeMet: true
            }
          };
          expect(await getStatusResponse(req)).toEqual(200);
        });
        // FIXME: throws 500 error when running after previous test
        //        if running by itself or with previous test skipped doesn't throw and fails because of equality
        it('search by pledge met on false', async () => {
          const req = {
            filters: {
              _condition: 'or',
              pledgeMet: false
            }
          };
          const response = await doServerRequest(req);
          expect(response).toMatchSnapshot();
        });
      });
      describe('search pools by multiple filters', () => {
        const req: StakePoolQueryOptions = {
          filters: {
            _condition: 'or',
            identifier: {
              condition: 'or',
              values: [
                { name: 'THE AMSTERDAM NODE' },
                { name: 'banderini' },
                { ticker: 'TEST' },
                { id: Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70') }
              ]
            }
          }
        };
        const reqWithMultipleFilters: StakePoolQueryOptions = {
          filters: {
            ...req.filters,
            status: [
              Cardano.StakePoolStatus.Activating,
              Cardano.StakePoolStatus.Active,
              Cardano.StakePoolStatus.Retired,
              Cardano.StakePoolStatus.Retiring
            ]
          }
        };
        describe('identifier & status filters', () => {
          it('active with or condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Active))).toEqual(200);
          });
          it('active with and condition', async () => {
            expect(
              await getStatusResponse(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Active))
            ).toEqual(200);
          });
          it('activating with or condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Activating))).toEqual(200);
          });
          it('activating with and condition', async () => {
            expect(
              await getStatusResponse(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Activating))
            ).toEqual(200);
          });
          it('retired with or condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Retiring))).toEqual(200);
          });
          it('retired with and condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Retired))).toEqual(200);
          });
          it('retiring with or condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Retiring))).toEqual(200);
          });
          it('retiring with and condition', async () => {
            expect(
              await getStatusResponse(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Retiring))
            ).toEqual(200);
          });
        });
        describe.skip('identifier & status  & pledgeMet filters', () => {
          it('pledgeMet true, active,  or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, active,  or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status active, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Active), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status active, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Active), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status activating, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status activating, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status activating, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Activating), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status activating, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Activating), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status retired, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status retired, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status retired, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Retired), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status retired, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Retired), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status retiring, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status retiring, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet true, status retiring, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Retiring), true)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet false, status retiring, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setAndCondition(req), Cardano.StakePoolStatus.Retiring), false)
            );
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet, multiple status, or condition', async () => {
            const response = await doServerRequest(reqWithMultipleFilters);
            expect(response).toEqual({ stakePools: [] });
          });
          it('pledgeMet, multiple status, and condition', async () => {
            const response = await doServerRequest(setAndCondition(reqWithMultipleFilters));
            expect(response).toEqual({ stakePools: [] });
          });
        });
      });
    });
  });
});
