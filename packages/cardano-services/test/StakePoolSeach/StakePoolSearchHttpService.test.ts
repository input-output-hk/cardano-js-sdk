/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
// import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { Cardano, StakePoolQueryOptions, StakePoolSearchProvider, StakePoolSearchResults } from '@cardano-sdk/core';
import { DbSyncStakePoolSearchProvider, HttpServer, HttpServerConfig, StakePoolSearchHttpService } from '../../src';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { stakePoolSearchHttpProvider } from '@cardano-sdk/cardano-services-client';
import got from 'got';

const UNSUPPORTED_MEDIA_STRING = 'Response code 415 (Unsupported Media Type)';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';
const STAKE_POOL_NAME = 'THE AMSTERDAM NODE';

const setFilterCondition = (options: StakePoolQueryOptions, condition: 'and' | 'or'): StakePoolQueryOptions => ({
  filters: { ...options.filters, _condition: condition }
});

const setSortCondition = (
  options: StakePoolQueryOptions,
  order: 'asc' | 'desc',
  field: 'name' | 'total_cost' | 'saturation'
): StakePoolQueryOptions => ({
  ...options,
  sort: { ...options.sort, field, order }
});

const setPagination = (options: StakePoolQueryOptions, startAt: number, limit: number): StakePoolQueryOptions => ({
  ...options,
  pagination: { ...options.pagination, limit, startAt }
});

const addStatusFilter = (options: StakePoolQueryOptions, status: Cardano.StakePoolStatus): StakePoolQueryOptions => ({
  filters: { ...options.filters, status: [status] }
});

const addPledgeMetFilter = (options: StakePoolQueryOptions, pledgeMet: boolean): StakePoolQueryOptions => ({
  filters: { ...options.filters, pledgeMet }
});

describe('StakePoolSearchHttpService', () => {
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let stakePoolSearchProvider: DbSyncStakePoolSearchProvider;
  let service: StakePoolSearchHttpService;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/stake-pool-search`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  const doServerRequest = (arg: unknown) =>
    got
      .post(`${apiUrlBase}/search`, {
        json: { args: [arg] }
      })
      .json() as Promise<StakePoolSearchResults>;

  describe('healthy state', () => {
    beforeAll(async () => {
      stakePoolSearchProvider = new DbSyncStakePoolSearchProvider(dbConnection);
      service = StakePoolSearchHttpService.create({ stakePoolSearchProvider });
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

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await got.post(`${apiUrlBase}/search`, {
            headers: { 'Content-Type': APPLICATION_CBOR }
          });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.statusCode).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with StakePoolSearchHttpProvider', () => {
        let provider: StakePoolSearchProvider;
        beforeEach(() => {
          provider = stakePoolSearchHttpProvider(apiUrlBase);
        });

        it('response is an array of stake pools', async () => {
          const options: StakePoolQueryOptions = {
            filters: {
              identifier: {
                _condition: 'or',
                values: [
                  { name: 'banderini' },
                  { id: Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70') }
                ]
              }
            }
          };
          const response = await provider.queryStakePools(options);
          expect(response.pageResults).toHaveLength(2);
          expect(response.totalResultCount).toEqual(2);
        });
      });

      describe('pagination', () => {
        it('should paginate response', async () => {
          const req = {};
          const reqWithPagination = { pagination: { limit: 2, startAt: 1 } };
          const response = await doServerRequest(req);
          const responseWithPagination = await doServerRequest(reqWithPagination);
          expect(response.pageResults.length).toEqual(8);
          expect(responseWithPagination.pageResults.length).toEqual(2);
          expect(response.pageResults[0]).not.toEqual(responseWithPagination.pageResults[0]);
        });
        it('should paginate response with or condition', async () => {
          const req = { filters: { _condition: 'or' } };
          const reqWithPagination = { ...req, pagination: { limit: 2, startAt: 2 } };
          const response = await doServerRequest(req);
          const responseWithPagination = await doServerRequest(reqWithPagination);
          expect(response.pageResults.length).toEqual(8);
          expect(responseWithPagination.pageResults.length).toEqual(2);
          expect(response.pageResults[0]).not.toEqual(responseWithPagination.pageResults[0]);
        });
        it('should paginate rewards response', async () => {
          const req = { pagination: { limit: 1, startAt: 1 } };
          const reqWithRewardsPagination = { pagination: { limit: 1, startAt: 1 }, rewardsHistoryLimit: 0 };
          const response = await doServerRequest(req);
          const responseWithPagination = await doServerRequest(reqWithRewardsPagination);
          expect(response.pageResults[0].epochRewards.length).toEqual(1);
          expect(responseWithPagination.pageResults[0].epochRewards.length).toEqual(0);
        });
        it('should paginate rewards response with or condition', async () => {
          const req = { filters: { _condition: 'or' }, pagination: { limit: 1, startAt: 1 } };
          const reqWithRewardsPagination = { pagination: { limit: 1, startAt: 1 }, rewardsHistoryLimit: 0 };
          const response = await doServerRequest(req);
          const responseWithPagination = await doServerRequest(reqWithRewardsPagination);
          expect(response.pageResults[0].epochRewards.length).toEqual(1);
          expect(responseWithPagination.pageResults[0].epochRewards.length).toEqual(0);
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
                  { name: STAKE_POOL_NAME },
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
          expect(response.pageResults).toEqual([]);
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
                { name: STAKE_POOL_NAME },
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
        describe('identifier & status filters', () => {
          it('active with or condition', async () => {
            const response = await doServerRequest(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active)
            );
            expect(response).toMatchSnapshot();
          });
          it('active with and condition', async () => {
            const response = await doServerRequest(addStatusFilter(req, Cardano.StakePoolStatus.Active));
            expect(response).toMatchSnapshot();
          });
          it('activating with or condition', async () => {
            const response = await doServerRequest(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating)
            );
            expect(response).toMatchSnapshot();
          });
          it('activating with and condition', async () => {
            const response = await doServerRequest(addStatusFilter(req, Cardano.StakePoolStatus.Activating));
            expect(response).toMatchSnapshot();
          });
          it('retired with or condition', async () => {
            const response = await doServerRequest(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired)
            );
            expect(response).toMatchSnapshot();
          });
          it('retired with and condition', async () => {
            const response = await doServerRequest(addStatusFilter(req, Cardano.StakePoolStatus.Retired));
            expect(response).toMatchSnapshot();
          });
          it('retiring with or condition', async () => {
            const response = await doServerRequest(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring)
            );
            expect(response).toMatchSnapshot();
          });
          it('retiring with and condition', async () => {
            const response = await doServerRequest(addStatusFilter(req, Cardano.StakePoolStatus.Retiring));
            expect(response).toMatchSnapshot();
          });
        });
        describe('identifier & status  & pledgeMet filters', () => {
          it('pledgeMet true, active,  or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, active,  or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active), false)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status active, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status active, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), false)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status activating, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
                true
              )
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status activating, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
                false
              )
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status activating, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status activating, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), false)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retired, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retired, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired), false)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retired, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retired, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), false)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retiring, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retiring, or condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring),
                false
              )
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retiring, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), true)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retiring, and condition', async () => {
            const response = await doServerRequest(
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), false)
            );
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet, multiple status, or condition', async () => {
            const response = await doServerRequest(reqWithMultipleFilters);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet, multiple status, and condition', async () => {
            const response = await doServerRequest(setFilterCondition(reqWithMultipleFilters, 'and'));
            expect(response).toMatchSnapshot();
          });
        });
      });

      describe('stake pools sort', () => {
        const filterArgs: StakePoolQueryOptions = {
          filters: {
            identifier: {
              _condition: 'or',
              values: [
                { ticker: 'TEST' },
                { name: STAKE_POOL_NAME },
                { id: Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70') }
              ]
            }
          }
        };

        it('sort by name desc order', async () => {
          const response = await doServerRequest(setSortCondition({}, 'desc', 'name'));
          expect(response).toMatchSnapshot();
        });

        it('sort by name asc order', async () => {
          const response = await doServerRequest(setSortCondition({}, 'asc', 'name'));
          expect(response).toMatchSnapshot();
        });

        it('sort by total_cost desc order', async () => {
          const response = await doServerRequest(setSortCondition({}, 'desc', 'total_cost'));
          expect(response).toMatchSnapshot();
        });

        it('sort by total_cost asc order', async () => {
          const response = await doServerRequest(setSortCondition({}, 'asc', 'total_cost'));
          expect(response).toMatchSnapshot();
        });

        it('if sort not provided defaults by name asc order', async () => {
          const response = await doServerRequest({});
          expect(response).toMatchSnapshot();
        });

        it('sort with applied filters', async () => {
          const response = await doServerRequest(
            setSortCondition(setFilterCondition(filterArgs, 'or'), 'desc', 'name')
          );
          expect(response).toMatchSnapshot();
        });

        it('sort asc by total_cost with applied pagination', async () => {
          const responsePage1 = await doServerRequest(setSortCondition(setPagination({}, 0, 3), 'asc', 'total_cost'));

          const responsePage2 = await doServerRequest(setSortCondition(setPagination({}, 3, 3), 'asc', 'total_cost'));

          expect(responsePage1).toMatchSnapshot();
          expect(responsePage2).toMatchSnapshot();
        });

        it('sort asc by name with applied pagination, with change sort criteria on next page', async () => {
          const firstPageResponse = await doServerRequest(setSortCondition(setPagination({}, 0, 5), 'asc', 'name'));

          const secondPageResponse = await doServerRequest(
            setSortCondition(setPagination({}, 5, 5), 'asc', 'total_cost')
          );
          const firstPageIds = firstPageResponse.pageResults.map(({ id }) => id);

          const hasDuplicatedIdsBetweenPages = firstPageIds.some((id) =>
            secondPageResponse.pageResults.map((stake) => stake.id).includes(id)
          );

          expect(firstPageResponse).toMatchSnapshot();
          expect(secondPageResponse).toMatchSnapshot();
          expect(hasDuplicatedIdsBetweenPages).toBe(false);
        });

        it('sort asc by name with applied pagination and filters', async () => {
          const responsePage = await doServerRequest(
            setSortCondition(setPagination(setFilterCondition(filterArgs, 'or'), 0, 5), 'asc', 'name')
          );

          expect(responsePage).toMatchSnapshot();
        });
      });
    });
  });
});
