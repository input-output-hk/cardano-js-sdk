/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import {
  Cardano,
  ProviderError,
  ProviderFailure,
  SortField,
  StakePoolProvider,
  StakePoolQueryOptions,
  StakePoolSearchResults,
  StakePoolStats
} from '@cardano-sdk/core';
import { DbSyncStakePoolProvider, HttpServer, HttpServerConfig, StakePoolHttpService } from '../../src';
import { Pool } from 'pg';
import { doServerRequest } from '../util';
import { getPort } from 'get-port-please';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';
const STAKE_POOL_NAME = 'THE AMSTERDAM NODE';

const setFilterCondition = (options: StakePoolQueryOptions, condition: 'and' | 'or'): StakePoolQueryOptions => ({
  filters: { ...options.filters, _condition: condition }
});

const setSortCondition = (
  options: StakePoolQueryOptions,
  order: 'asc' | 'desc',
  field: SortField
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

describe('StakePoolHttpService', () => {
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let stakePoolProvider: DbSyncStakePoolProvider;
  let service: StakePoolHttpService;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let doStakePoolRequest: ReturnType<typeof doServerRequest>;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/stake-pool`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
    doStakePoolRequest = doServerRequest(apiUrlBase);
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('unhealthy StakePoolProvider', () => {
    beforeEach(async () => {
      stakePoolProvider = {
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        queryStakePools: jest.fn(),
        stakePoolStats: jest.fn()
      } as unknown as DbSyncStakePoolProvider;
    });

    it('should not throw during service create if the StakePoolProvider is unhealthy', () => {
      expect(() => new StakePoolHttpService({ stakePoolProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the StakePoolProvider is unhealthy', async () => {
      service = new StakePoolHttpService({ stakePoolProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    beforeAll(async () => {
      stakePoolProvider = new DbSyncStakePoolProvider(dbConnection);
      service = new StakePoolHttpService({ stakePoolProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the stakePoolProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/search', () => {
      const url = '/search';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}${url}`, { args: [] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}${url}`, undefined, { headers: { 'Content-Type': APPLICATION_CBOR } });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with StakePoolHttpProvider', () => {
        let provider: StakePoolProvider;
        beforeEach(() => {
          provider = stakePoolHttpProvider(apiUrlBase);
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
          const req: StakePoolQueryOptions = {};
          const reqWithPagination: StakePoolQueryOptions = { pagination: { limit: 2, startAt: 1 } };
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
          const responseWithPagination = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [reqWithPagination]
          );
          expect(response.pageResults.length).toEqual(9);
          expect(responseWithPagination.pageResults.length).toEqual(2);
          expect(response.pageResults[0]).not.toEqual(responseWithPagination.pageResults[0]);
        });
        it('should paginate response with or condition', async () => {
          const req: StakePoolQueryOptions = { filters: { _condition: 'or' } };
          const reqWithPagination: StakePoolQueryOptions = { ...req, pagination: { limit: 2, startAt: 1 } };
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
          const responseWithPagination = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [reqWithPagination]
          );
          expect(response.pageResults.length).toEqual(9);
          expect(responseWithPagination.pageResults.length).toEqual(2);
          expect(response.pageResults[0]).not.toEqual(responseWithPagination.pageResults[0]);
        });
        it('should paginate rewards response', async () => {
          const req = { pagination: { limit: 1, startAt: 1 } };
          const reqWithRewardsPagination = { pagination: { limit: 1, startAt: 1 }, rewardsHistoryLimit: 0 };
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
          const responseWithPagination = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [reqWithRewardsPagination]
          );
          expect(response.pageResults[0].epochRewards.length).toEqual(1);
          expect(responseWithPagination.pageResults[0].epochRewards.length).toEqual(0);
        });
        it('should paginate rewards response with or condition', async () => {
          const req: StakePoolQueryOptions = { filters: { _condition: 'or' }, pagination: { limit: 1, startAt: 1 } };
          const reqWithRewardsPagination = { pagination: { limit: 1, startAt: 1 }, rewardsHistoryLimit: 0 };
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
          const responseWithPagination = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [reqWithRewardsPagination]
          );
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
          const responseWithOrCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [setFilterCondition(req, 'or')]
          );
          const responseWithAndCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [req]
          );
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
          const responseWithOrCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [setFilterCondition(req, 'or')]
          );
          const responseWithAndCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [req]
          );
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
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
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
          const responseWithOrCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [setFilterCondition(req, 'or')]
          );
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
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
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
          expect(response).toMatchSnapshot();
        });
        it('search by retired status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              status: [Cardano.StakePoolStatus.Retired]
            }
          };
          const responseWithOrCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [setFilterCondition(req, 'or')]
          );
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);
        });
        it('search by retiring status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              status: [Cardano.StakePoolStatus.Retiring]
            }
          };
          const responseWithOrCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [setFilterCondition(req, 'or')]
          );
          const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [req]);
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
          const responseWithAndCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [req]
          );
          const responseWithOrCondition = await axios.post(`${apiUrlBase}${url}`, {
            args: [setFilterCondition(req, 'or')]
          });
          expect(responseWithOrCondition.status).toEqual(200);
          expect(responseWithOrCondition.data).toEqual(responseWithAndCondition);
        });
        it('search by pledge met on false', async () => {
          const req = {
            filters: {
              pledgeMet: false
            }
          };
          const responseWithOrCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [setFilterCondition(req, 'or')]
          );
          expect(responseWithOrCondition).toMatchSnapshot();
          const responseWithAndCondition = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(
            url,
            [req]
          );
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
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('active with and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(req, Cardano.StakePoolStatus.Active)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('activating with or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('activating with and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(req, Cardano.StakePoolStatus.Activating)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('retired with or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('retired with and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(req, Cardano.StakePoolStatus.Retired)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('retiring with or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('retiring with and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addStatusFilter(req, Cardano.StakePoolStatus.Retiring)
            ]);
            expect(response).toMatchSnapshot();
          });
        });
        describe('identifier & status  & pledgeMet filters', () => {
          it('pledgeMet true, active,  or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, active,  or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active), false)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status active, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status active, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), false)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status activating, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
                true
              )
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status activating, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
                false
              )
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status activating, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status activating, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), false)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retired, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retired, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired), false)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retired, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retired, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), false)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retiring, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retiring, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(
                addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring),
                false
              )
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet true, status retiring, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), true)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet false, status retiring, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), false)
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet, multiple status, or condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              reqWithMultipleFilters
            ]);
            expect(response).toMatchSnapshot();
          });
          it('pledgeMet, multiple status, and condition', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setFilterCondition(reqWithMultipleFilters, 'and')
            ]);
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
        const sortByNameThenByPoolId = function (poolA: Cardano.StakePool, poolB: Cardano.StakePool) {
          if (poolA.metadata?.name && !poolB.metadata?.name) return -1;
          if (!poolA.metadata?.name && poolB.metadata?.name) return 1;
          if (poolA.metadata?.name && poolB.metadata?.name) {
            return poolA.metadata.name.toLowerCase() > poolB.metadata.name.toLowerCase() ? 1 : -1;
          }
          return poolA.id > poolB.id ? 1 : -1;
        };

        describe('sort by name', () => {
          it('desc order', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition({}, 'desc', 'name')
            ]);
            expect(response).toMatchSnapshot();
          });

          it('asc order', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition({}, 'asc', 'name')
            ]);
            expect(response).toMatchSnapshot();
          });

          it('if sort not provided, defaults to order by name and then by poolId asc', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [{}]);

            const resultSortedCopy = [...response.pageResults].sort(sortByNameThenByPoolId);

            expect(response.pageResults).toEqual(resultSortedCopy);
            expect(response).toMatchSnapshot();
          });

          describe('positions stake pools with no name registered after named pools, sorted by poolId', () => {
            const fistNoMetadataPoolId = Cardano.PoolId('pool126zlx7728y7xs08s8epg9qp393kyafy9rzr89g4qkvv4cv93zem');
            const secondNoMetadataPoolId = Cardano.PoolId('pool1y25deq9kldy9y9gfvrpw8zt05zsrfx84zjhugaxrx9ftvwdpua2');
            const firstNamedPoolId = Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70');
            const secondNamedPoolId = Cardano.PoolId('pool168d9plflldfr6mpjg9q2typv2m6a0hx4u5g8kfa486dwkke2uj7');

            const reqOptions: StakePoolQueryOptions = {
              filters: {
                identifier: {
                  _condition: 'or',
                  values: [
                    { id: secondNoMetadataPoolId },
                    { id: secondNamedPoolId },
                    { id: fistNoMetadataPoolId },
                    { id: firstNamedPoolId }
                  ]
                }
              }
            };

            it('with name ascending', async () => {
              const stakePoolIdsSorted = [
                firstNamedPoolId,
                secondNamedPoolId,
                fistNoMetadataPoolId,
                secondNoMetadataPoolId
              ];
              const { pageResults } = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
                { ...reqOptions, sort: { field: 'name', order: 'asc' } }
              ]);

              expect(pageResults.length).toEqual(4);
              expect(pageResults[0].metadata?.name).toEqual('CLIO1');
              expect(pageResults[pageResults.length - 1].metadata?.name).toBeUndefined();
              expect(pageResults.map(({ id }) => id)).toEqual(stakePoolIdsSorted);
            });

            it('with name descending', async () => {
              const stakePoolIdsSorted = [
                secondNamedPoolId,
                firstNamedPoolId,
                fistNoMetadataPoolId,
                secondNoMetadataPoolId
              ];
              const { pageResults } = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
                { ...reqOptions, sort: { field: 'name', order: 'desc' } }
              ]);

              expect(pageResults.length).toEqual(4);
              expect(pageResults[0].metadata?.name).toEqual('Farts');
              expect(pageResults[pageResults.length - 1].metadata?.name).toBeUndefined();
              expect(pageResults.map(({ id }) => id)).toEqual(stakePoolIdsSorted);
            });
          });

          it('with applied filters', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'desc', 'name')
            ]);
            expect(response).toMatchSnapshot();
          });

          it('asc order with applied pagination', async () => {
            const firstPageResultSet = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 0, 3), 'asc', 'name')
            ]);

            const secondPageResultSet = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 3, 3), 'asc', 'name')
            ]);

            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();
          });

          it('asc order with applied pagination, with change sort order on next page', async () => {
            const firstPageResponse = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 0, 5), 'asc', 'name')
            ]);

            const secondPageResponse = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 5, 5), 'asc', 'name')
            ]);
            const firstPageIds = firstPageResponse.pageResults.map(({ id }) => id);

            const hasDuplicatedIdsBetweenPages = firstPageIds.some((id) =>
              secondPageResponse.pageResults.map((stake) => stake.id).includes(id)
            );

            expect(firstPageResponse).toMatchSnapshot();
            expect(secondPageResponse).toMatchSnapshot();
            expect(hasDuplicatedIdsBetweenPages).toBe(false);
          });

          it('asc order with applied pagination and filters', async () => {
            const responsePage = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination(setFilterCondition(filterArgs, 'or'), 0, 5), 'asc', 'name')
            ]);

            expect(responsePage).toMatchSnapshot();
          });
        });

        describe('sort by saturation', () => {
          it('desc order', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition({}, 'desc', 'saturation')
            ]);
            expect(response).toMatchSnapshot();
          });
          it('asc order', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition({}, 'asc', 'saturation')
            ]);
            expect(response).toMatchSnapshot();
          });
          it('with applied filters', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'saturation')
            ]);
            expect(response).toMatchSnapshot();
          });
          it('with applied pagination', async () => {
            const firstPageResultSet = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 0, 3), 'asc', 'saturation')
            ]);
            const secondPageResultSet = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 3, 3), 'asc', 'saturation')
            ]);

            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();
          });
        });

        describe('sort by APY', () => {
          it('desc order', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition({}, 'desc', 'apy')
            ]);
            expect(response).toMatchSnapshot();
          });
          it('asc order', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition({}, 'asc', 'apy')
            ]);
            expect(response).toMatchSnapshot();
          });
          it('with applied filters', async () => {
            const response = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'apy')
            ]);
            expect(response).toMatchSnapshot();
          });
          it('with applied pagination', async () => {
            const firstPageResultSet = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 0, 3), 'desc', 'apy')
            ]);
            const secondPageResultSet = await doStakePoolRequest<[StakePoolQueryOptions], StakePoolSearchResults>(url, [
              setSortCondition(setPagination({}, 3, 3), 'desc', 'apy')
            ]);
            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();
          });
        });
      });
    });

    describe('/stats', () => {
      const url = '/stats';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}${url}`, { args: [] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}${url}`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with StakePoolHttpProvider', () => {
        let provider: StakePoolProvider;
        beforeEach(() => {
          provider = stakePoolHttpProvider(apiUrlBase);
        });

        it('response is an object with stake pool stats', async () => {
          const response = await provider.stakePoolStats();
          expect(response.qty.active).toBe(7);
          expect(response.qty.retired).toBe(2);
          expect(response.qty.retiring).toBe(0);
        });
      });

      describe('server and snapshot testing', () => {
        it('has active, retired and retiring stake pools count', async () => {
          const response = await doStakePoolRequest<[], StakePoolStats>(url, []);
          expect(response.qty).toBeDefined();
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
