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

const setFilterCondition = (options: StakePoolQueryOptions, condition: 'and' | 'or'): StakePoolQueryOptions => ({
  filters: { ...options.filters, _condition: condition }
});

const addStatusFilter = (options: StakePoolQueryOptions, status: Cardano.StakePoolStatus): StakePoolQueryOptions => ({
  filters: { ...options.filters, status: [status] }
});

const addPledgeMetFilter = (options: StakePoolQueryOptions, pledgeMet: boolean): StakePoolQueryOptions => ({
  filters: { ...options.filters, pledgeMet }
});

describe('StakePoolSearchHttpServer', () => {
  let dbConnection: Pool;
  let stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
  let stakePoolSearchHttpServer: StakePoolSearchHttpServer;
  let port: number;
  let apiUrlBase: string;
  let config: StakePoolSearchServerConfig;
  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
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
      stakePoolSearchProvider = new DbSyncStakePoolSearchProvider(dbConnection);
      stakePoolSearchHttpServer = StakePoolSearchHttpServer.create({ stakePoolSearchProvider }, config);
      await stakePoolSearchHttpServer.initialize();
      await stakePoolSearchHttpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
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
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect(
          (
            await got.post(`${apiUrlBase}/search`, {
              json: { args: [] }
            })
          ).statusCode
        ).toEqual(200);
      });

      it('returns a 400 coded response if the wrong content type header is used', async () => {
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
          const req: StakePoolQueryOptions = {
            filters: {
              identifier: {
                _condition: 'or',
                values: [
                  { name: 'THE AMSTERDAM NODE' },
                  { name: 'banderini' },
                  { ticker: 'TEST' },
                  { id: '98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' as unknown as Cardano.PoolId }
                ]
              }
            }
          };
          const responseWithOrCondition = await doServerRequest(setFilterCondition(req, 'or'));
          const responseWithAndCondition = await doServerRequest(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(responseWithAndCondition).toEqual(responseWithOrCondition);
        });
        it('and condition', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              identifier: {
                _condition: 'and',
                values: [
                  { name: 'CL' },
                  { ticker: 'CLIO' },
                  { id: 'pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' as unknown as Cardano.PoolId }
                ]
              }
            }
          };
          const responseWithOrCondition = await doServerRequest(setFilterCondition(req, 'or'));
          const responseWithAndCondition = await doServerRequest(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(responseWithAndCondition).toEqual(responseWithAndCondition);
        });
        it('stake pools do not match identifier filter', async () => {
          const req = {
            filters: {
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
              status: [Cardano.StakePoolStatus.Active]
            }
          };
          const responseWithOrCondition = await doServerRequest(setFilterCondition(req, 'or'));
          const response = await doServerRequest(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);
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
              status: [Cardano.StakePoolStatus.Retired]
            }
          };
          const responseWithOrCondition = await doServerRequest(setFilterCondition(req, 'or'));
          const response = await doServerRequest(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);
        });
        it('search by retiring status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              status: [Cardano.StakePoolStatus.Retiring]
            }
          };
          const responseWithOrCondition = await doServerRequest(setFilterCondition(req, 'or'));
          const response = await doServerRequest(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);
        });
      });
      describe('search pools by pledge met', () => {
        it('search by pledge met on true', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              pledgeMet: true
            }
          };
          const responseWithAndCondition = await doServerRequest(req);
          const responseWithOrCondition = await got.post(`${apiUrlBase}/search`, {
            json: { args: [setFilterCondition(req, 'or')] }
          });
          expect(responseWithOrCondition.statusCode).toEqual(200);
          expect(JSON.parse(responseWithOrCondition.body)).toEqual(responseWithAndCondition);
        });
        // FIXME: throws 500 error when running after previous test
        //        if running by itself or with previous test skipped doesn't throw and fails because of equality
        it('search by pledge met on false', async () => {
          const req = {
            filters: {
              pledgeMet: false
            }
          };
          const responseWithOrCondition = await doServerRequest(setFilterCondition(req, 'or'));
          expect(responseWithOrCondition).toMatchSnapshot();
          const responseWithAndCondition = await doServerRequest(req);
          expect(responseWithAndCondition).toEqual(responseWithAndCondition);
        });
      });
      describe('search pools by multiple filters', () => {
        const req: StakePoolQueryOptions = {
          filters: {
            identifier: {
              _condition: 'or',
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
            _condition: 'or',
            status: [
              Cardano.StakePoolStatus.Activating,
              Cardano.StakePoolStatus.Active,
              Cardano.StakePoolStatus.Retired,
              Cardano.StakePoolStatus.Retiring
            ]
          }
        };
        // TODO: the status code is only being checked in the following tests in order to just validate query errors.
        // As an improve, the stake pools response could be validated too.
        describe('identifier & status filters', () => {
          it('active with or condition', async () => {
            expect(
              await getStatusResponse(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active))
            ).toEqual(200);
          });
          it('active with and condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Active))).toEqual(200);
          });
          it('activating with or condition', async () => {
            expect(
              await getStatusResponse(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating)
              )
            ).toEqual(200);
          });
          it('activating with and condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Activating))).toEqual(200);
          });
          it('retired with or condition', async () => {
            expect(
              await getStatusResponse(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired))
            ).toEqual(200);
          });
          it('retired with and condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Retired))).toEqual(200);
          });
          it('retiring with or condition', async () => {
            expect(
              await getStatusResponse(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring))
            ).toEqual(200);
          });
          it('retiring with and condition', async () => {
            expect(await getStatusResponse(addStatusFilter(req, Cardano.StakePoolStatus.Retiring))).toEqual(200);
          });
        });
        describe('identifier & status  & pledgeMet filters', () => {
          it('pledgeMet true, active,  or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active), true)
              )
            ).toEqual(200);
          });
          it('pledgeMet false, active,  or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active),
                  false
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet true, status active, and condition', async () => {
            expect(
              await getStatusResponse(addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), true))
            ).toEqual(200);
          });
          it('pledgeMet false, status active, and condition', async () => {
            expect(
              await getStatusResponse(addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), false))
            ).toEqual(200);
          });
          it('pledgeMet true, status activating, or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
                  true
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet false, status activating, or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
                  false
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet true, status activating, and condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), true)
              )
            ).toEqual(200);
          });
          it('pledgeMet false, status activating, and condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), false)
              )
            ).toEqual(200);
          });
          it('pledgeMet true, status retired, or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired),
                  true
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet false, status retired, or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired),
                  false
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet true, status retired, and condition', async () => {
            expect(
              await getStatusResponse(addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), true))
            ).toEqual(200);
          });
          it('pledgeMet false, status retired, and condition', async () => {
            expect(
              await getStatusResponse(addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), false))
            ).toEqual(200);
          });
          it('pledgeMet true, status retiring, or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring),
                  true
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet false, status retiring, or condition', async () => {
            expect(
              await getStatusResponse(
                addPledgeMetFilter(
                  addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring),
                  false
                )
              )
            ).toEqual(200);
          });
          it('pledgeMet true, status retiring, and condition', async () => {
            expect(
              await getStatusResponse(addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), true))
            ).toEqual(200);
          });
          it('pledgeMet false, status retiring, and condition', async () => {
            expect(
              await getStatusResponse(addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), false))
            ).toEqual(200);
          });
          it('pledgeMet, multiple status, or condition', async () => {
            expect(await getStatusResponse(reqWithMultipleFilters)).toEqual(200);
          });
          it('pledgeMet, multiple status, and condition', async () => {
            expect(await getStatusResponse(setFilterCondition(reqWithMultipleFilters, 'and'))).toEqual(200);
          });
        });
      });
    });
  });
});
