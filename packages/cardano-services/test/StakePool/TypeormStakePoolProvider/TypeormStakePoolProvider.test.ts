/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, QueryStakePoolsArgs, SortField, StakePoolProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import {
  DEFAULT_FUZZY_SEARCH_OPTIONS,
  HttpServer,
  HttpServerConfig,
  InMemoryCache,
  StakePoolHttpService,
  TypeormStakePoolProvider,
  UNLIMITED_CACHE_TTL,
  createDnsResolver,
  getConnectionConfig,
  getEntities
} from '../../../src';
import { INFO, createLogger } from 'bunyan';
import { Observable } from 'rxjs';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Pool } from 'pg';
import { PoolInfo, TypeormStakePoolFixtureBuilder } from './fitxures/TypeormFixtureBuilder';
import { emptyDbData, ingestDbData, servicesWithVersionPath as services, sleep } from '../../util';
import { getPort } from 'get-port-please';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import axios from 'axios';
import lowerCase from 'lodash/lowerCase.js';

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
  let baseUrlWithVersion: string;
  let clientConfig: CreateHttpProviderConfig<StakePoolProvider>;
  let config: HttpServerConfig;
  let connectionConfig$: Observable<PgConnectionConfig>;
  let provider: StakePoolProvider;
  let fixtureBuilder: TypeormStakePoolFixtureBuilder;
  let filterArgs: QueryStakePoolsArgs;
  let poolsInfo: PoolInfo[];
  let poolsInfoWithMeta: PoolInfo[];
  let poolsInfoWithUniqueMeta: PoolInfo[];
  let poolsInfoWithMetaFiltered: PoolInfo[];
  let poolsInfoWithMetrics: PoolInfo[];
  let poolsInfoWithMetricsFiltered: PoolInfo[];

  const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
  const entities = getEntities(['currentPoolMetrics', 'poolMetadata', 'poolDelisted']);
  const delisted_id = Cardano.PoolId('pool1vj30jr7wn83dzn928qk6fx34h3d3f3cesr47j5ymeumf65wdw9x');
  const db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_STAKE_POOL });

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
    baseUrlWithVersion = `${baseUrl}${services.stakePool.versionPath}/${services.stakePool.name}`;
    config = { listen: { port } };
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    connectionConfig$ = getConnectionConfig(dnsResolver, 'projector', 'StakePool', {
      postgresConnectionStringStakePool: process.env.POSTGRES_CONNECTION_STRING_STAKE_POOL!
    });

    // data prep
    // ingesting delist before building the fixture
    await ingestDbData(db, 'pool_delisted', ['stake_pool_id'], [delisted_id]);

    fixtureBuilder = new TypeormStakePoolFixtureBuilder(db, logger);
    poolsInfo = await fixtureBuilder.getPools(1000, ['active', 'activating', 'retired', 'retiring']);
    poolsInfoWithMeta = poolsInfo.filter((pool) => isNotNil(pool.metadataUrl));
    poolsInfoWithMetrics = poolsInfo.filter((pool) => isNotNil(pool.saturation));
    poolsInfoWithUniqueMeta = poolsInfoWithMeta
      .filter(({ name, ticker }) => name !== 'Same Name' && ticker !== 'SP6a7')
      .sort((a, b) => (a.name < b.name ? -1 : 1));

    filterArgs = {
      filters: {
        identifier: {
          _condition: 'or',
          values: [
            { ticker: poolsInfoWithUniqueMeta[0].ticker },
            { name: poolsInfoWithUniqueMeta[1].name },
            { id: poolsInfoWithUniqueMeta[2].id }
          ]
        }
      },
      pagination
    };

    const applyFilter = (pool: PoolInfo): boolean =>
      filterArgs.filters?.identifier?.values.some(
        ({ ticker }) => ticker && pool.ticker && pool.ticker.includes(ticker)
      ) ||
      filterArgs.filters?.identifier?.values.some(
        ({ name }) => name && pool.name && pool.name.toLowerCase().includes(name.toLowerCase())
      ) ||
      filterArgs.filters?.identifier?.values.some(({ id }) => id && pool.id === id) ||
      false;

    poolsInfoWithMetaFiltered = poolsInfoWithMeta.filter(applyFilter);
    poolsInfoWithMetricsFiltered = poolsInfoWithMetrics.filter(applyFilter);
  });

  afterAll(async () => {
    // data cleanse
    await emptyDbData(db, 'pool_delisted');
    await db.end();
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    describe('with TypeormStakePoolProvider', () => {
      beforeAll(async () => {
        provider = stakePoolHttpProvider(clientConfig);
        stakePoolProvider = new TypeormStakePoolProvider(
          { fuzzyOptions: DEFAULT_FUZZY_SEARCH_OPTIONS, lastRosEpochs: 10, paginationPageSizeLimit: pagination.limit },
          { cache: new InMemoryCache(UNLIMITED_CACHE_TTL), connectionConfig$, entities, logger }
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
          while (!(await provider.healthCheck()).ok) await sleep(10);
          const response = await provider.healthCheck();
          expect(response).toEqual({ ok: true });
        });
      });

      describe('/search', () => {
        const url = '/search';

        describe('with Http Server', () => {
          it('returns a 200 coded response with a well formed HTTP request', async () => {
            expect(
              (await axios.post(`${baseUrlWithVersion}${url}`, { pagination: { limit: 5, startAt: 0 } })).status
            ).toEqual(200);
          });

          it('returns a 415 coded response if the wrong content type header is used', async () => {
            expect.assertions(2);
            try {
              await axios.post(
                `${baseUrlWithVersion}${url}`,
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
              await axios.post(`${baseUrlWithVersion}${url}`, {}, { headers: { 'Content-Type': APPLICATION_JSON } });
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
                `${baseUrlWithVersion}${url}`,
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
                `${baseUrlWithVersion}${url}`,
                { filters, pagination: { limit: 5, startAt: 0 } },
                { headers: { 'Content-Type': APPLICATION_JSON } }
              );
            } catch (error: any) {
              expect(error.response.status).toBe(400);
              expect(error.message).toBe(BAD_REQUEST);
            }
          });
        });

        it('response is an array of stake pools excluding delisted pool', async () => {
          const options: QueryStakePoolsArgs = {
            filters: {
              identifier: {
                _condition: 'or',
                values: [{ id: poolsInfo[0].id }, { id: poolsInfo[1].id }, { id: delisted_id }]
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

          // TODO: after regenerating test db, there are no 'retiring' pools
          it.skip('search by retiring status', async () => {
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

            // TODO: after regenerating test db, there are no 'retiring' pools
            it.skip('retiring with or condition', async () => {
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

            // TODO: after regenerating test db, there are no 'retiring' pools
            it.skip('retiring with and condition', async () => {
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

        // Being this search based on a not exact match, the results of these tests are strongly dependant on
        // stake pools configuration in the local-network: the expected result of the tests is hard coded.
        // In case of changes in the local-network configuration, the need of some actions here is expected.
        describe('search pools by text', () => {
          describe('by default, result is sorted by relevance', () => {
            it('with stringent search', async () => {
              const response = await provider.queryStakePools({ filters: { text: 'sp11' }, pagination });
              expect(response.pageResults.map(({ metadata }) => metadata?.ticker)).toEqual(['SP11', 'SP1', 'SP10']);
            });

            it('with mild search', async () => {
              const response = await provider.queryStakePools({ filters: { text: 'pool 10 ' }, pagination });
              expect(response.pageResults.map(({ metadata }) => metadata?.ticker).slice(0, 3)).toEqual([
                'SP10',
                'SP6a7',
                'SP1'
              ]);
            });
          });

          it('when search options are specified, they take precedence over sort by relevance', async () => {
            const response = await provider.queryStakePools({
              filters: { text: 'sp1' },
              pagination,
              sort: { field: 'ticker', order: 'desc' }
            });
            expect(response.pageResults.map(({ metadata }) => metadata?.ticker)).toEqual(['SP11', 'SP10', 'SP1']);
          });

          it('returns an empty array on empty search result', async () => {
            const response = await provider.queryStakePools({
              filters: { text: 'no one match this search' },
              pagination
            });
            expect(response.pageResults).toEqual([]);
          });
        });

        describe('stake pools sort', () => {
          describe('sort by name', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'name'));
              const expected = [...poolsInfoWithMeta].sort((a, b) => (lowerCase(a.name) < lowerCase(b.name) ? 1 : -1));
              expect(response.pageResults[0].metadata?.name).toEqual(expected[0].name);
              expect(response.pageResults[1].metadata?.name).toEqual(expected[1].name);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'name'));
              const expected = [...poolsInfoWithMeta].sort((a, b) => (lowerCase(a.name) < lowerCase(b.name) ? -1 : 1));
              expect(response.pageResults[0].metadata?.name).toEqual(expected[0].name);
              expect(response.pageResults[1].metadata?.name).toEqual(expected[1].name);
            });

            it('if sort not provided, defaults to order by name asc', async () => {
              const response = await provider.queryStakePools({ pagination });
              const expected = [...poolsInfoWithMeta].sort((a, b) => (lowerCase(a.name) < lowerCase(b.name) ? -1 : 1));
              expect(response.pageResults[0].metadata?.name).toEqual(expected[0].name);
              expect(response.pageResults[1].metadata?.name).toEqual(expected[1].name);
            });

            it('with applied filters', async () => {
              const reqWithFilters = setSortCondition(setFilterCondition(filterArgs, 'or'), 'desc', 'name');
              const response = await provider.queryStakePools(reqWithFilters);
              const expected = [...poolsInfoWithMetaFiltered].sort((a, b) =>
                lowerCase(a.name) < lowerCase(b.name) ? 1 : -1
              );
              expect(response.pageResults[0].metadata?.name).toEqual(expected[0].name);
              expect(response.pageResults[1].metadata?.name).toEqual(expected[1].name);
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

          describe('sort by ticker', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'ticker'));
              const expected = [...poolsInfoWithMeta].sort((a, b) => (a.ticker < b.ticker ? 1 : -1));
              expect(response.pageResults[0].metadata?.ticker).toEqual(expected[0].ticker);
              expect(response.pageResults[1].metadata?.ticker).toEqual(expected[1].ticker);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'ticker'));
              const expected = [...poolsInfoWithMeta].sort((a, b) => (a.ticker < b.ticker ? -1 : 1));
              expect(response.pageResults[0].metadata?.ticker).toEqual(expected[0].ticker);
              expect(response.pageResults[1].metadata?.ticker).toEqual(expected[1].ticker);
            });

            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'ticker')
              );
              const expected = [...poolsInfoWithMetricsFiltered].sort((a, b) => (a.ticker < b.ticker ? -1 : 1));
              expect(response.pageResults[0].metadata?.ticker).toEqual(expected[0].ticker);
              expect(response.pageResults[1].metadata?.ticker).toEqual(expected[1].ticker);
            });
          });

          describe('sort by cost', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'cost'));
              const expected = [...poolsInfoWithMetrics].sort((a, b) => (a.cost < b.cost ? 1 : -1));
              expect(response.pageResults[0].cost).toEqual(BigInt(expected[0].cost));
              expect(response.pageResults[1].cost).toEqual(BigInt(expected[1].cost));
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'cost'));
              const expected = [...poolsInfoWithMetrics].sort((a, b) => (a.cost < b.cost ? -1 : 1));
              expect(response.pageResults[0].cost).toEqual(BigInt(expected[0].cost));
              expect(response.pageResults[1].cost).toEqual(BigInt(expected[1].cost));
            });

            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'cost')
              );
              const expected = [...poolsInfoWithMetricsFiltered].sort((a, b) => (a.cost < b.cost ? -1 : 1));
              expect(response.pageResults[0].cost).toEqual(BigInt(expected[0].cost));
              expect(response.pageResults[1].cost).toEqual(BigInt(expected[1].cost));
            });
          });

          describe('sort by saturation', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'saturation'));
              const expected = [...poolsInfoWithMetrics]
                .filter((_) => !Number.isNaN(_.saturation))
                .sort((a, b) => (a.saturation < b.saturation ? 1 : -1));
              expect(response.pageResults[0].metrics?.saturation).toEqual(expected[0].saturation);
              expect(response.pageResults[1].metrics?.saturation).toEqual(expected[1].saturation);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'saturation'));
              const expected = [...poolsInfoWithMetrics]
                .filter((_) => !Number.isNaN(_.saturation))
                .sort((a, b) => (a.saturation < b.saturation ? -1 : 1));
              expect(response.pageResults[0].metrics?.saturation).toEqual(expected[0].saturation);
              expect(response.pageResults[1].metrics?.saturation).toEqual(expected[1].saturation);
            });

            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'saturation')
              );
              const expected = [...poolsInfoWithMetricsFiltered].sort((a, b) => (a.saturation < b.saturation ? -1 : 1));
              expect(response.pageResults[0].metrics?.saturation).toEqual(expected[0].saturation);
              expect(response.pageResults[1].metrics?.saturation).toEqual(expected[1].saturation);
            });
          });

          describe('sort by lastRos', () => {
            let expectedLastRos: { max: number; min: number };

            beforeAll(() => {
              expectedLastRos = poolsInfoWithMetrics.reduce(
                (result, current) => ({
                  max: Math.max(result.max, current.lastRos === undefined ? 0 : current.lastRos),
                  min: Math.min(result.min, current.lastRos === undefined ? 100 : current.lastRos)
                }),
                { max: 0, min: 100 }
              );
            });

            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'lastRos'));
              expect(response.pageResults[0].metrics?.lastRos).toEqual(expectedLastRos.max);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'lastRos'));
              expect(response.pageResults[0].metrics?.lastRos).toEqual(expectedLastRos.min);
            });
          });

          describe.each(['apy', 'ros'] as const)('sort by %s', (field) => {
            let expectedRos: { max: number; min: number };

            beforeAll(() => {
              expectedRos = poolsInfoWithMetrics.reduce(
                (result, current) => ({
                  max: Math.max(result.max, current.ros === undefined ? 0 : current.ros),
                  min: Math.min(result.min, current.ros === undefined ? 100 : current.ros)
                }),
                { max: 0, min: 100 }
              );
            });

            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', field));
              expect(response.pageResults[0].metrics?.ros).toEqual(expectedRos.max);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', field));
              expect(response.pageResults[0].metrics?.ros).toEqual(expectedRos.min);
            });
          });

          describe('sort by margin', () => {
            let margins: Cardano.Fraction[] = [];

            beforeAll(() => {
              margins = poolsInfo
                .map(({ margin }) => margin)
                .sort((a, b) => (a.numerator / a.denominator < b.numerator / b.denominator ? -1 : 1));
            });

            it('desc order', async () => {
              const { pageResults } = await provider.queryStakePools(
                setSortCondition({ pagination }, 'desc', 'margin')
              );

              expect(pageResults.map(({ margin }) => margin)).toEqual(
                margins
                  .map((_) => _)
                  .reverse()
                  .splice(0, 10)
              );
            });

            it('asc order', async () => {
              const { pageResults } = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'margin'));

              expect(pageResults.map(({ margin }) => margin)).toEqual(margins.map((_) => _).splice(0, 10));
            });
          });

          describe('sort by pledge', () => {
            let pledges: bigint[] = [];

            beforeAll(() => {
              pledges = poolsInfo.map(({ pledge }) => BigInt(pledge)).sort((a, b) => (a < b ? -1 : 1));
            });

            it('desc order', async () => {
              const { pageResults } = await provider.queryStakePools(
                setSortCondition({ pagination }, 'desc', 'pledge')
              );

              expect(pageResults.map(({ pledge }) => pledge)).toEqual(
                pledges
                  .map((_) => _)
                  .reverse()
                  .splice(0, 10)
              );
            });

            it('asc order', async () => {
              const { pageResults } = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'pledge'));

              expect(pageResults.map(({ pledge }) => pledge)).toEqual(pledges.map((_) => _).splice(0, 10));
            });
          });

          describe('sort by blocks', () => {
            let blocks: number[] = [];

            beforeAll(() => {
              blocks = poolsInfoWithMetrics.map((_) => _.blocks).sort((a, b) => (a < b ? -1 : 1));
            });

            it('desc order', async () => {
              const { pageResults } = await provider.queryStakePools(
                setSortCondition({ pagination }, 'desc', 'blocks')
              );

              expect(pageResults.map(({ metrics }) => metrics!.blocksCreated)).toEqual(
                blocks
                  .map((_) => _)
                  .reverse()
                  .splice(0, 10)
              );
            });

            it('asc order', async () => {
              const { pageResults } = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'blocks'));

              expect(pageResults.map(({ metrics }) => metrics!.blocksCreated)).toEqual(
                blocks.filter((_) => _ !== null).splice(0, 10)
              );
            });
          });

          describe('sort by liveStake', () => {
            let pledges: bigint[] = [];

            beforeAll(() => {
              pledges = poolsInfoWithMetrics
                .filter(({ stake }) => stake !== null)
                .map(({ stake }) => BigInt(stake))
                .sort((a, b) => (a < b ? -1 : 1));
            });

            it('desc order', async () => {
              const { pageResults } = await provider.queryStakePools(
                setSortCondition({ pagination }, 'desc', 'liveStake')
              );

              expect(pageResults.map(({ metrics }) => metrics!.stake.live)).toEqual(
                pledges
                  .map((_) => _)
                  .reverse()
                  .splice(0, 10)
              );
            });

            it('asc order', async () => {
              const { pageResults } = await provider.queryStakePools(
                setSortCondition({ pagination }, 'asc', 'liveStake')
              );

              expect(pageResults.map(({ metrics }) => metrics!.stake.live)).toEqual(
                pledges.map((_) => _).splice(0, 10)
              );
            });
          });
        });
      });

      describe('/stats', () => {
        const url = '/stats';

        describe('with Http Server', () => {
          it('returns a 200 coded response with a well formed HTTP request', async () => {
            expect((await axios.post(`${baseUrlWithVersion}${url}`, {})).status).toEqual(200);
          });

          it('returns a 415 coded response if the wrong content type header is used', async () => {
            try {
              await axios.post(`${baseUrlWithVersion}${url}`, {}, { headers: { 'Content-Type': APPLICATION_CBOR } });
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
