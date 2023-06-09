/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, QueryStakePoolsArgs, SortField, StakePoolProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import { HttpServer } from '../../../src/Http/HttpServer';
import { HttpServerConfig } from '../../../src/Http/types';
import { INFO, createLogger } from 'bunyan';
import { Observable } from 'rxjs';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Pool } from 'pg';
import { PoolInfo, TypeormStakePoolFixtureBuilder } from './fitxures/TypeormFixtureBuilder';
import { StakePoolHttpService } from '../../../src/StakePool/StakePoolHttpService';
import { TypeormStakePoolProvider, createDnsResolver, getConnectionConfig, getEntities } from '../../../src';
import { getPort } from 'get-port-please';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import { sleep } from '../../util';
import axios from 'axios';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';
const pagination = { limit: 10, startAt: 0 };
const BAD_REQUEST = 'Request failed with status code 400';

const setFilterCondition = (options: QueryStakePoolsArgs, condition: 'and' | 'or'): QueryStakePoolsArgs => ({
  filters: { ...options.filters, _condition: condition },
  pagination
});

const setSortCondition = (
  options: QueryStakePoolsArgs,
  order: 'asc' | 'desc',
  field: SortField
): QueryStakePoolsArgs => ({
  ...options,
  sort: { ...options.sort, field, order }
});

const setPagination = (options: QueryStakePoolsArgs, startAt: number, limit: number): QueryStakePoolsArgs => ({
  ...options,
  pagination: { ...options.pagination, limit, startAt }
});

const addStatusFilter = (options: QueryStakePoolsArgs, status: Cardano.StakePoolStatus): QueryStakePoolsArgs => ({
  filters: { ...options.filters, status: [status] },
  pagination
});

const isLowerCase = (str: string): boolean => str.toUpperCase() !== str;

const toInvertedCase = (str: string): string => {
  let invertedCase = '';
  for (const element of str) {
    invertedCase += isLowerCase(element) ? element.toUpperCase() : element.toLowerCase();
  }
  return invertedCase;
};

describe('TypeormStakePoolProvider', () => {
  let httpServer: HttpServer;
  let stakePoolProvider: TypeormStakePoolProvider;
  let service: StakePoolHttpService;
  let port: number;
  let baseUrl: string;
  let clientConfig: CreateHttpProviderConfig<StakePoolProvider>;
  let config: HttpServerConfig;
  let connectionConfig$: Observable<PgConnectionConfig>;
  let provider: StakePoolProvider;
  let fixtureBuilder: TypeormStakePoolFixtureBuilder;
  let filterArgs: QueryStakePoolsArgs;
  let poolsInfo: PoolInfo[];
  let poolsInfoWithMeta: PoolInfo[];
  let poolsInfoWithMetrics: PoolInfo[];

  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  const entities = getEntities([
    'block',
    'poolMetadata',
    'poolRegistration',
    'poolRetirement',
    'stakePool',
    'currentPoolMetrics'
  ]);
  const db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_STAKE_POOL, max: 1, min: 1 });

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/stake-pool`;
    config = { listen: { port } };
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    connectionConfig$ = getConnectionConfig(dnsResolver, 'projector', 'StakePool', {
      postgresConnectionStringStakePool: process.env.POSTGRES_CONNECTION_STRING_STAKE_POOL!
    });
    fixtureBuilder = new TypeormStakePoolFixtureBuilder(db, logger);
    poolsInfo = await fixtureBuilder.getPools(1000, ['active', 'activating', 'retired', 'retiring']);
    poolsInfoWithMeta = poolsInfo.filter((pool) => isNotNil(pool.metadataUrl));
    poolsInfoWithMetrics = poolsInfo.filter((pool) => isNotNil(pool.saturation));

    filterArgs = {
      filters: {
        identifier: {
          _condition: 'or',
          values: [
            { ticker: poolsInfoWithMeta[0].ticker },
            { name: poolsInfoWithMeta[1].name },
            { id: poolsInfoWithMeta[2].id }
          ]
        }
      },
      pagination
    };
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    describe('with TypeormStakePoolProvider', () => {
      beforeAll(async () => {
        provider = stakePoolHttpProvider(clientConfig);
        stakePoolProvider = new TypeormStakePoolProvider(
          { paginationPageSizeLimit: pagination.limit },
          { connectionConfig$, entities, logger }
        );
        service = new StakePoolHttpService({ logger, stakePoolProvider });
        httpServer = new HttpServer(config, { logger, runnableDependencies: [], services: [service] });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      describe('/health', () => {
        it('forwards the stakePoolProvider health response with provider client', async () => {
          // required a delay to determine TypeormProvider's healthCheck as healthy when subscribes to observable data source
          const response = await provider.healthCheck();
          expect(response).toEqual({ ok: false, reason: 'not started' });
          while (!(await provider.healthCheck()).ok) await sleep(10);
          const response2 = await provider.healthCheck();
          expect(response2).toEqual({ ok: true });
        });
      });

      describe('/search', () => {
        const url = '/search';

        describe('with Http Server', () => {
          it('returns a 200 coded response with a well formed HTTP request', async () => {
            expect((await axios.post(`${baseUrl}${url}`, { pagination: { limit: 5, startAt: 0 } })).status).toEqual(
              200
            );
          });

          it('returns a 415 coded response if the wrong content type header is used', async () => {
            expect.assertions(2);
            try {
              await axios.post(
                `${baseUrl}${url}`,
                { pagination: { limit: 5, startAt: 0 } },
                { headers: { 'Content-Type': APPLICATION_CBOR } }
              );
              throw new Error('fail');
            } catch (error: any) {
              expect(error.response.status).toBe(415);
              expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
            }
          });

          it('returns a 400 coded error if pagination argument is not provided', async () => {
            expect.assertions(2);
            try {
              await axios.post(`${baseUrl}${url}`, {}, { headers: { 'Content-Type': APPLICATION_JSON } });
            } catch (error: any) {
              expect(error.response.status).toBe(400);
              expect(error.message).toBe(BAD_REQUEST);
            }
          });

          it('returns a 400 coded error if pagination limit is greater than pagination page size limit', async () => {
            expect.assertions(2);
            const pageSizeGreaterThanMaxLimit = 30;
            try {
              await axios.post(
                `${baseUrl}${url}`,
                { pagination: { limit: pageSizeGreaterThanMaxLimit, startAt: 0 } },
                { headers: { 'Content-Type': APPLICATION_JSON } }
              );
            } catch (error: any) {
              expect(error.response.status).toBe(400);
              expect(error.message).toBe(BAD_REQUEST);
            }
          });

          it('returns a 400 coded error if provided filter identifier values are greater than pagination page size limit', async () => {
            expect.assertions(2);
            const filters = {
              identifier: {
                _condition: 'or',
                values: [
                  { name: 'Test1' },
                  { name: 'Test2' },
                  { ticker: 'Test3' },
                  { ticker: 'Test4' },
                  { ticker: 'Test5' },
                  { ticker: 'Test6' },
                  { ticker: 'Test7' },
                  { ticker: 'Test8' },
                  { ticker: 'Test9' },
                  { id: 'pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' as Cardano.PoolId },
                  { id: '98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' as Cardano.PoolId }
                ]
              }
            };

            try {
              await axios.post(
                `${baseUrl}${url}`,
                { filters, pagination: { limit: 5, startAt: 0 } },
                { headers: { 'Content-Type': APPLICATION_JSON } }
              );
            } catch (error: any) {
              expect(error.response.status).toBe(400);
              expect(error.message).toBe(BAD_REQUEST);
            }
          });
        });

        it('response is an array of stake pools', async () => {
          const options: QueryStakePoolsArgs = {
            filters: {
              identifier: {
                _condition: 'or',
                values: [{ id: poolsInfo[0].id }, { id: poolsInfo[1].id }]
              }
            },
            pagination
          };
          const response = await provider.queryStakePools(options);

          expect(() => Cardano.PoolId(poolsInfo[0].id as unknown as string)).not.toThrow();
          expect(() => Cardano.PoolIdHex(response.pageResults[0].hexId as unknown as string)).not.toThrow();
          expect(() => Cardano.VrfVkHex(response.pageResults[0].vrf as unknown as string)).not.toThrow();

          expect(response.pageResults).toHaveLength(2);
          expect(response.totalResultCount).toEqual(2);
        });

        describe('pagination', () => {
          const baseArgs = { pagination: { limit: 2, startAt: 0 } };

          it('should paginate response', async () => {
            const paginatedResponse = await provider.queryStakePools(baseArgs);
            expect(paginatedResponse.pageResults.length).toEqual(baseArgs.pagination.limit);
            expect(paginatedResponse.totalResultCount).toEqual(poolsInfo.length);
          });

          it('should paginate response with or condition', async () => {
            const reqWithPagination: QueryStakePoolsArgs = { ...baseArgs, filters: { _condition: 'or' } };

            const paginatedResponse = await provider.queryStakePools(reqWithPagination);
            expect(paginatedResponse.pageResults.length).toEqual(baseArgs.pagination.limit);
            expect(paginatedResponse.totalResultCount).toEqual(poolsInfo.length);
          });
        });

        describe('search pools by identifier filter', () => {
          it('or condition', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                identifier: {
                  _condition: 'or',
                  values: [
                    { name: poolsInfoWithMeta[0].name },
                    { name: poolsInfoWithMeta[1].name },
                    { ticker: poolsInfoWithMeta[0].ticker },
                    { id: poolsInfoWithMeta[0].id }
                  ]
                }
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const responseWithAndCondition = await provider.queryStakePools(req);
            expect(responseWithAndCondition).toEqual(responseWithOrCondition);
          });

          it('and condition', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                identifier: {
                  _condition: 'and',
                  values: [
                    { name: poolsInfoWithMeta[0].name },
                    { ticker: poolsInfoWithMeta[0].ticker },
                    { id: poolsInfoWithMeta[0].id }
                  ]
                }
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const responseWithAndCondition = await provider.queryStakePools(req);
            expect(responseWithOrCondition).toEqual(responseWithAndCondition);

            expect(responseWithOrCondition.pageResults[0]?.metadata?.name).toEqual(poolsInfoWithMeta[0].name);
            expect(responseWithOrCondition.pageResults[0]?.metadata?.ticker).toEqual(poolsInfoWithMeta[0].ticker);
            expect(responseWithOrCondition.pageResults[0]?.id).toEqual(poolsInfoWithMeta[0].id);
          });

          it('is case insensitive', async () => {
            const values = [{ name: poolsInfoWithMeta[0].name, ticker: poolsInfoWithMeta[0].ticker }];
            const insensitiveValues = [
              { name: toInvertedCase(poolsInfoWithMeta[0].name), ticker: toInvertedCase(poolsInfoWithMeta[0].ticker) }
            ];
            const req: QueryStakePoolsArgs = {
              filters: {
                identifier: { values }
              },
              pagination
            };
            const reqWithInsensitiveValues: QueryStakePoolsArgs = {
              filters: {
                identifier: { values: insensitiveValues }
              },
              pagination
            };
            const response = await provider.queryStakePools(req);
            const responseWithInsensitiveValues = await provider.queryStakePools(reqWithInsensitiveValues);
            expect(response).toEqual(responseWithInsensitiveValues);

            expect(responseWithInsensitiveValues.pageResults[0]?.metadata?.name).toEqual(poolsInfoWithMeta[0].name);
            expect(responseWithInsensitiveValues.pageResults[0]?.metadata?.ticker).toEqual(poolsInfoWithMeta[0].ticker);
            expect(responseWithInsensitiveValues.pageResults[0]?.id).toEqual(poolsInfoWithMeta[0].id);
          });

          it('stake pools do not match identifier filter', async () => {
            const req = {
              filters: {
                identifier: {
                  condition: 'and',
                  values: [{ name: 'Unknown Name' }]
                }
              },
              pagination
            };
            const response = await provider.queryStakePools(req);
            expect(response.pageResults).toEqual([]);
          });
          it('empty values ignores identifier filter', async () => {
            const req = {
              filters: {
                identifier: {
                  values: []
                }
              },
              pagination
            };
            const reqWithNoFilters = { pagination };
            const response = await provider.queryStakePools(req);
            const responseWithNoFilters = await provider.queryStakePools(reqWithNoFilters);
            expect(response).toEqual(responseWithNoFilters);
            expect(response.pageResults.length).toBeGreaterThan(0);
          });
        });

        describe('search pools by status', () => {
          it('search by active status', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                status: [Cardano.StakePoolStatus.Active]
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const response = await provider.queryStakePools(req);
            expect(response).toEqual(responseWithOrCondition);

            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
          });

          it('search by activating status', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                _condition: 'or',
                status: [Cardano.StakePoolStatus.Activating]
              },
              pagination
            };
            const response = await provider.queryStakePools(req);
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Activating);
          });

          it('search by retired status', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                status: [Cardano.StakePoolStatus.Retired]
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const response = await provider.queryStakePools(req);
            expect(response).toEqual(responseWithOrCondition);
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retired);
          });

          it('search by retiring status', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                status: [Cardano.StakePoolStatus.Retiring]
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const response = await provider.queryStakePools(req);
            expect(response).toEqual(responseWithOrCondition);
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retiring);
          });
        });

        describe('search pools by multiple filters', () => {
          describe('identifier & status filters', () => {
            it('active with or condition', async () => {
              const active = await fixtureBuilder.getPools(1, ['active']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: active[0].id }]
                  }
                },
                pagination
              };

              const response = await provider.queryStakePools(
                addStatusFilter(setFilterCondition(filter, 'or'), Cardano.StakePoolStatus.Active)
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });

            it('active with and condition', async () => {
              const active = await fixtureBuilder.getPools(1, ['active']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: active[0].id }]
                  }
                },
                pagination
              };

              const response = await provider.queryStakePools(addStatusFilter(filter, Cardano.StakePoolStatus.Active));
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });

            it('activating with or condition', async () => {
              const activatingPool = await fixtureBuilder.getPools(1, ['activating']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: activatingPool[0].id }]
                  }
                },
                pagination
              };

              const response = await provider.queryStakePools(
                addStatusFilter(setFilterCondition(filter, 'or'), Cardano.StakePoolStatus.Activating)
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Activating);
            });

            it('activating with and condition', async () => {
              const activatingPool = await fixtureBuilder.getPools(1, ['activating']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: activatingPool[0].id }]
                  }
                },
                pagination
              };

              const response = await provider.queryStakePools(
                addStatusFilter(filter, Cardano.StakePoolStatus.Activating)
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Activating);
            });

            it('retired with or condition', async () => {
              const retiredPool = await fixtureBuilder.getPools(1, ['retired']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiredPool[0].id }]
                  }
                },
                pagination
              };

              const response = await provider.queryStakePools(
                addStatusFilter(setFilterCondition(filter, 'or'), Cardano.StakePoolStatus.Retired)
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retired);
            });

            it('retired with and condition', async () => {
              const retiredPool = await fixtureBuilder.getPools(1, ['retired']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiredPool[0].id }]
                  },
                  status: [Cardano.StakePoolStatus.Retired]
                },
                pagination
              };

              const response = await provider.queryStakePools(filter);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retired);
            });

            it('retiring with or condition', async () => {
              const retiring = await fixtureBuilder.getPools(1, ['retiring']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiring[0].id }]
                  }
                },
                pagination
              };
              const response = await provider.queryStakePools(
                addStatusFilter(setFilterCondition(filter, 'or'), Cardano.StakePoolStatus.Retiring)
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retiring);
            });

            it('retiring with and condition', async () => {
              const retiring = await fixtureBuilder.getPools(1, ['retiring']);
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiring[0].id }]
                  }
                },
                pagination
              };
              const response = await provider.queryStakePools(
                addStatusFilter(filter, Cardano.StakePoolStatus.Retiring)
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retiring);
            });
          });
        });

        // eslint-disable-next-line complexity, unicorn/consistent-function-scoping
        const sortByNameThenByPoolIdAsc = (poolA: Cardano.StakePool, poolB: Cardano.StakePool) => {
          if (poolA.metadata?.name && poolB.metadata?.name === '') return 1;
          if (poolB.metadata?.name && poolA.metadata?.name === '') return -1;
          if (poolA.metadata?.name && !poolB.metadata?.name) return -1;
          if (!poolA.metadata?.name && poolB.metadata?.name) return 1;
          if (poolA.metadata?.name && poolB.metadata?.name) {
            if (poolA.metadata?.name === poolB.metadata?.name) return 0;
            return poolA.metadata.name > poolB.metadata.name ? 1 : -1;
          }

          return poolA.id > poolB.id ? 1 : -1;
        };

        describe('stake pools sort', () => {
          describe('sort by name', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'name'));
              expect(response.pageResults[0].metadata?.name).toEqual(poolsInfoWithMeta[1].name);
              expect(response.pageResults[response.pageResults.length - 1].metadata?.name).toEqual(undefined);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'name'));
              expect(response.pageResults[0].metadata?.name).toEqual(poolsInfoWithMeta[6].name);
              expect(response.pageResults[response.pageResults.length - 1].metadata?.name).toEqual(undefined);
            });

            it('if sort not provided, defaults to order by name desc and then by poolId asc', async () => {
              const response = await provider.queryStakePools({ pagination });
              const resultSortedCopy = [...response.pageResults].sort(sortByNameThenByPoolIdAsc);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(resultSortedCopy);
            });

            it('with applied filters', async () => {
              const reqWithFilters = setSortCondition(setFilterCondition(filterArgs, 'or'), 'desc', 'name');
              const response = await provider.queryStakePools(reqWithFilters);
              expect(response.pageResults[0].metadata?.name).toEqual(poolsInfoWithMeta[1].name);
              expect(response.pageResults[response.totalResultCount - 1].metadata?.name).toEqual(
                poolsInfoWithMeta[0].name
              );
            });

            it('asc order with applied pagination', async () => {
              const firstPageReq = setSortCondition(setPagination({ pagination }, 0, 3), 'asc', 'name');
              const secondPageReq = setSortCondition(setPagination({ pagination }, 3, 3), 'asc', 'name');

              const firstPageResultSet = await provider.queryStakePools(firstPageReq);

              const secondPageResultSet = await provider.queryStakePools(secondPageReq);
              const firstResponse = await provider.queryStakePools(firstPageReq);
              const secondResponse = await provider.queryStakePools(secondPageReq);

              expect(firstPageResultSet).toEqual(firstResponse);
              expect(secondPageResultSet).toEqual(secondResponse);
            });

            it('asc order with applied pagination, with change sort order on next page', async () => {
              const firstPageResponse = await provider.queryStakePools(
                setSortCondition(setPagination({ pagination }, 0, 5), 'asc', 'name')
              );

              const secondPageResponse = await provider.queryStakePools(
                setSortCondition(setPagination({ pagination }, 5, 5), 'asc', 'name')
              );
              const firstPageIds = firstPageResponse.pageResults.map(({ id }) => id);

              const hasDuplicatedIdsBetweenPages = firstPageIds.some((id) =>
                secondPageResponse.pageResults.map((stake) => stake.id).includes(id)
              );
              expect(hasDuplicatedIdsBetweenPages).toBe(false);
            });
          });

          describe('sort by cost', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'cost'));
              expect(response.pageResults[0].cost).toEqual(BigInt(poolsInfo[10].cost));
              expect(response.pageResults[response.pageResults.length - 1].cost).toEqual(BigInt(poolsInfo[9].cost));
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'cost'));
              expect(response.pageResults[0].cost).toEqual(BigInt(poolsInfo[13].cost));
              expect(response.pageResults[response.pageResults.length - 1].cost).toEqual(BigInt(poolsInfo[0].cost));
            });

            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'cost')
              );
              expect(response.pageResults[0].cost).toEqual(BigInt(poolsInfo[3].cost));
              expect(response.pageResults[response.totalResultCount - 1].cost).toEqual(BigInt(poolsInfo[0].cost));
            });
          });

          describe('sort by saturation', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'saturation'));
              expect(response.pageResults[0].metrics?.saturation).toEqual(poolsInfoWithMetrics[8].saturation);
              expect(response.pageResults[response.pageResults.length - 1].metrics?.saturation).toEqual(
                poolsInfoWithMetrics[9].saturation
              );
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'saturation'));
              expect(response.pageResults[0].metrics?.saturation).toEqual(poolsInfoWithMetrics[4].saturation);
              expect(response.pageResults[response.pageResults.length - 1].metrics?.saturation).toEqual(
                poolsInfoWithMetrics[1].saturation
              );
            });

            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'saturation')
              );
              expect(response.pageResults[0].metrics?.saturation).toEqual(poolsInfoWithMetrics[4].saturation);
              expect(response.pageResults[response.totalResultCount - 1].metrics?.saturation).toEqual(
                poolsInfoWithMetrics[1].saturation
              );
            });
          });

          describe('sort by apy', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'apy'));
              expect(response.pageResults[0].metrics?.apy).toEqual(poolsInfoWithMetrics[6].apy);
              expect(response.pageResults[response.pageResults.length - 1].metrics?.apy).toEqual(
                poolsInfoWithMetrics[1].apy
              );
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'apy'));
              expect(response.pageResults[0].metrics?.apy).toEqual(poolsInfoWithMetrics[2].apy);
              expect(response.pageResults[response.pageResults.length - 1].metrics?.apy).toEqual(
                poolsInfoWithMetrics[0].apy
              );
            });

            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'apy')
              );
              expect(response.pageResults[0].metrics?.apy).toEqual(poolsInfoWithMetrics[2].apy);
              expect(response.pageResults[response.totalResultCount - 1].metrics?.apy).toEqual(
                poolsInfoWithMetrics[0].apy
              );
            });
          });
        });
      });

      describe('/stats', () => {
        const url = '/stats';

        describe('with Http Server', () => {
          it('returns a 200 coded response with a well formed HTTP request', async () => {
            expect((await axios.post(`${baseUrl}${url}`, {})).status).toEqual(200);
          });

          it('returns a 415 coded response if the wrong content type header is used', async () => {
            try {
              await axios.post(`${baseUrl}${url}`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
              throw new Error('fail');
            } catch (error: any) {
              expect(error.response.status).toBe(415);
              expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
            }
          });
        });

        it('response is an object with stake pool stats', async () => {
          const response = await provider.stakePoolStats();
          expect(response.qty).toMatchShapeOf({ activating: 0, active: 0, retired: 0, retiring: 0 });
        });
      });
    });
  });
});
