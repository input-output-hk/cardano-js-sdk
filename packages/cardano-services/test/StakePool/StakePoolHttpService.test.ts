/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { DbSyncEpochPollService, loadGenesisData } from '../../src/util/index.js';
import { DbSyncStakePoolFixtureBuilder, PoolWith } from './fixtures/FixtureBuilder.js';
import {
  DbSyncStakePoolProvider,
  HttpServer,
  InMemoryCache,
  StakePoolHttpService,
  UNLIMITED_CACHE_TTL,
  createHttpStakePoolMetadataService
} from '../../src/index.js';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { INFO, createLogger } from 'bunyan';
import { Pool } from 'pg';
import {
  clearDbPools,
  ingestDbData,
  servicesWithVersionPath as services,
  sleep,
  wrapWithTransaction
} from '../util.js';
import { findLedgerTip } from '../../src/util/DbSyncProvider/index.js';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks.js';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';
import type { CreateHttpProviderConfig } from '@cardano-sdk/cardano-services-client';
import type { DbPools, LedgerTipModel } from '../../src/util/DbSyncProvider/index.js';
import type { GenesisData, HttpServerConfig } from '../../src/index.js';
import type { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import type { PoolInfo } from './fixtures/FixtureBuilder.js';
import type { QueryStakePoolsArgs, SortField, StakePoolProvider } from '@cardano-sdk/core';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';
const cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
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

const addPledgeMetFilter = (options: QueryStakePoolsArgs, pledgeMet: boolean): QueryStakePoolsArgs => ({
  filters: { ...options.filters, pledgeMet },
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

describe('StakePoolHttpService', () => {
  let httpServer: HttpServer;
  let stakePoolProvider: DbSyncStakePoolProvider;
  let service: StakePoolHttpService;
  let port: number;
  let baseUrl: string;
  let baseUrlWithVersion: string;
  let clientConfig: CreateHttpProviderConfig<StakePoolProvider>;
  let config: HttpServerConfig;
  let provider: StakePoolProvider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: LedgerTipModel;
  let fixtureBuilder: DbSyncStakePoolFixtureBuilder;
  let poolsInfo: PoolInfo[];

  const epochPollInterval = 2 * 1000;
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };
  const dbPools: DbPools = {
    healthCheck: new Pool({
      connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC,
      max: 1,
      min: 1
    }),
    main: new Pool({
      connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC,
      max: 1,
      min: 1
    })
  };

  const epochMonitor = new DbSyncEpochPollService(dbPools.main, epochPollInterval!);
  let reqWithFilter: QueryStakePoolsArgs;
  let reqWithMultipleFilters: QueryStakePoolsArgs;
  let filterArgs: QueryStakePoolsArgs;

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
    baseUrlWithVersion = `${baseUrl}${services.stakePool.versionPath}/${services.stakePool.name}`;
    config = { listen: { port } };
    clientConfig = {
      baseUrl,
      logger: createLogger({ level: INFO, name: 'unit tests' })
    };
    fixtureBuilder = new DbSyncStakePoolFixtureBuilder(dbPools.main, logger);
    poolsInfo = await fixtureBuilder.getPools(3, { with: [PoolWith.Metadata] });

    reqWithFilter = {
      filters: {
        identifier: {
          _condition: 'or',
          values: [
            { name: poolsInfo[0].name },
            { name: poolsInfo[1].name },
            { ticker: poolsInfo[0].ticker },
            { id: poolsInfo[2].id }
          ]
        }
      },
      pagination
    };

    reqWithMultipleFilters = {
      filters: {
        ...reqWithFilter.filters,
        _condition: 'or',
        status: [
          Cardano.StakePoolStatus.Activating,
          Cardano.StakePoolStatus.Active,
          Cardano.StakePoolStatus.Retired,
          Cardano.StakePoolStatus.Retiring
        ]
      },
      pagination
    };

    filterArgs = {
      filters: {
        identifier: {
          _condition: 'or',
          values: [{ ticker: poolsInfo[0].ticker }, { name: poolsInfo[1].name }, { id: poolsInfo[2].id }]
        }
      },
      pagination
    };
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    const dbQuerySpy = {
      healthCheck: jest.spyOn(dbPools.healthCheck, 'query'),
      main: jest.spyOn(dbPools.main, 'query')
    };

    const clearCacheSpy = jest.spyOn(cache.db, 'clear');
    let genesisData: GenesisData;
    const metadataService = createHttpStakePoolMetadataService(logger);

    beforeAll(async () => {
      genesisData = await loadGenesisData(cardanoNodeConfigPath);
      lastBlockNoInDb = (await dbPools.main.query<LedgerTipModel>(findLedgerTip)).rows[0];
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({
          blockNo: lastBlockNoInDb.block_no,
          hash: lastBlockNoInDb.hash.toString('hex'),
          projectedTip: {
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            slot: Number(lastBlockNoInDb.slot_no)
          },
          slot: Number(lastBlockNoInDb.slot_no),
          withTip: true
        })
      ) as unknown as OgmiosCardanoNode;
      stakePoolProvider = new DbSyncStakePoolProvider(
        { paginationPageSizeLimit: pagination.limit, useBlockfrost: false },
        { cache, cardanoNode, dbPools, epochMonitor, genesisData, logger, metadataService }
      );
      service = new StakePoolHttpService({ logger, stakePoolProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      provider = stakePoolHttpProvider(clientConfig);
    });

    afterAll(async () => {
      await clearDbPools(dbPools);
      cache.db.shutdown();
      cache.healthCheck.shutdown();
      jest.clearAllTimers();
    });

    beforeEach(async () => {
      cache.db.clear();
      cache.healthCheck.clear();
      jest.clearAllMocks();
    });

    describe('with DbSyncStakePoolProvider', () => {
      beforeAll(async () => {
        stakePoolProvider = new DbSyncStakePoolProvider(
          { paginationPageSizeLimit: pagination.limit, useBlockfrost: false },
          { cache, cardanoNode, dbPools, epochMonitor, genesisData, logger, metadataService }
        );
        service = new StakePoolHttpService({ logger, stakePoolProvider });
        httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
        await httpServer.initialize();
        await httpServer.start();
      });

      afterAll(async () => {
        await httpServer.shutdown();
      });

      describe('start', () => {
        it('should start epoch monitor once the db provider is initialized and started', async () => {
          await sleep(epochPollInterval * 2);

          expect(await epochMonitor.getLastKnownEpoch()).toBeDefined();
          expect(clearCacheSpy).not.toHaveBeenCalled();
        });
      });

      describe('/health', () => {
        it('forwards the stakePoolProvider health response with HTTP request', async () => {
          const res = await axios.post(`${baseUrlWithVersion}/health`, {
            headers: { 'Content-Type': APPLICATION_JSON }
          });
          expect(res.status).toBe(200);
          expect(res.data).toEqual(
            healthCheckResponseMock({
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              projectedTip: {
                blockNo: lastBlockNoInDb.block_no,
                hash: lastBlockNoInDb.hash.toString('hex'),
                slot: Number(lastBlockNoInDb.slot_no)
              },
              slot: Number(lastBlockNoInDb.slot_no),
              withTip: true
            })
          );
        });

        it('forwards the stakePoolProvider health response with provider client', async () => {
          const response = await provider.healthCheck();
          expect(dbQuerySpy.main).toHaveBeenCalledTimes(0);
          expect(dbQuerySpy.healthCheck).toHaveBeenCalledTimes(1);
          expect(response).toEqual(
            healthCheckResponseMock({
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              projectedTip: {
                blockNo: lastBlockNoInDb.block_no,
                hash: lastBlockNoInDb.hash.toString('hex'),
                slot: Number(lastBlockNoInDb.slot_no)
              },
              slot: Number(lastBlockNoInDb.slot_no),
              withTip: true
            })
          );
        });
      });

      describe('/search', () => {
        const url = '/search';
        const cachedSubQueriesCount = 8;
        const cacheKeysCount = 5;
        const nonCacheableSubQueriesCount = 1; // getLastEpoch
        const filerOnePoolOptions: QueryStakePoolsArgs = {
          filters: { identifier: { values: [{ ticker: 'SP1$' }] } },
          pagination
        };

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
                  { name: 'CLI' },
                  { name: 'banderini' },
                  { ticker: 'TEST' },
                  { ticker: 'TEST2' },
                  { ticker: 'TEST3' },
                  { ticker: 'TEST4' },
                  { ticker: 'TEST5' },
                  { ticker: 'TEST6' },
                  { ticker: 'TEST7' },
                  { id: 'pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' as unknown as Cardano.PoolId },
                  { id: '98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70' as unknown as Cardano.PoolId }
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

        it('should query the DB only once when the response is cached', async () => {
          const { pageResults } = await provider.queryStakePools(filerOnePoolOptions);
          expect(pageResults.length).toBe(1);
          expect(dbQuerySpy.main).toHaveBeenCalledTimes(cachedSubQueriesCount + nonCacheableSubQueriesCount);
          dbQuerySpy.main.mockClear();
          await provider.queryStakePools(filerOnePoolOptions);
          expect(dbQuerySpy.main).toHaveBeenCalledTimes(nonCacheableSubQueriesCount);
          expect(cache.db.keys().length).toEqual(cacheKeysCount);
        });

        it('should call db-sync queries again once the cache is cleared', async () => {
          await provider.queryStakePools(filerOnePoolOptions);
          cache.db.clear();
          expect(cache.db.keys().length).toEqual(0);

          await provider.queryStakePools(filerOnePoolOptions);
          expect(dbQuerySpy.main).toBeCalledTimes((cachedSubQueriesCount + nonCacheableSubQueriesCount) * 2);
        });

        it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
          const currentEpochNo = await fixtureBuilder.getLasKnownEpoch();
          const response = await provider.queryStakePools(filerOnePoolOptions);

          expect(cache.db.keys().length).toEqual(cacheKeysCount);

          await sleep(epochPollInterval);

          expect(await epochMonitor.getLastKnownEpoch()).toEqual(currentEpochNo);
          expect(cache.db.keys().length).toEqual(cacheKeysCount);
          expect(dbQuerySpy.main).toBeCalled();
          expect(clearCacheSpy).not.toHaveBeenCalled();

          const responseCached = await provider.queryStakePools(filerOnePoolOptions);
          expect(response.totalResultCount).toEqual(responseCached.totalResultCount);
          expect(response.pageResults[0]).toEqual(responseCached.pageResults[0]);
        });

        it(
          'should invalidate cached epoch values once the epoch rollover is captured by polling',
          wrapWithTransaction(async (dbConnection) => {
            const greaterEpoch = 255;

            await provider.queryStakePools(filerOnePoolOptions);
            await sleep(epochPollInterval);

            expect(cache.db.keys().length).toEqual(cacheKeysCount);
            await ingestDbData(
              dbConnection,
              'epoch',
              ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
              [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
            );

            await sleep(epochPollInterval);
            expect(clearCacheSpy).toHaveBeenCalled();

            expect(await epochMonitor.getLastKnownEpoch()).toEqual(greaterEpoch);
            expect(cache.db.keys().length).toEqual(0);
          }, dbPools.main)
        );

        it.each(DbSyncStakePoolProvider.notSupportedSortFields)(
          "Doesn't support sorting by %s",
          async (field) =>
            await expect(provider.queryStakePools({ pagination, sort: { field, order: 'asc' } })).rejects.toThrow(
              `DbSyncStakePoolProvider doesn't support sort by ${field}`
            )
        );

        describe('pagination', () => {
          const baseArgs = { pagination: { limit: 2, startAt: 0 } };

          it('should paginate response', async () => {
            const paginatedResponse = await provider.queryStakePools(baseArgs);
            expect(paginatedResponse.pageResults.length).toEqual(baseArgs.pagination.limit);

            const paginatedResponseCached = await provider.queryStakePools(baseArgs);
            expect(paginatedResponse.pageResults).toEqual(paginatedResponseCached.pageResults);
          });

          it('should paginate response with or condition', async () => {
            const reqWithPagination: QueryStakePoolsArgs = { ...baseArgs, filters: { _condition: 'or' } };

            const paginatedResponse = await provider.queryStakePools(reqWithPagination);
            expect(paginatedResponse.pageResults.length).toEqual(baseArgs.pagination.limit);

            const paginatedResponseCached = await provider.queryStakePools(reqWithPagination);
            expect(paginatedResponse.pageResults).toEqual(paginatedResponseCached.pageResults);
          });

          it('should cache paginated response', async () => {
            const firstResponseWithPagination = await provider.queryStakePools(baseArgs);
            expect(dbQuerySpy.main).toHaveBeenCalledTimes(cachedSubQueriesCount + nonCacheableSubQueriesCount);
            dbQuerySpy.main.mockClear();
            const secondResponseWithPaginationCached = await provider.queryStakePools(baseArgs);
            expect(firstResponseWithPagination.pageResults).toEqual(secondResponseWithPaginationCached.pageResults);
            expect(firstResponseWithPagination.totalResultCount).toEqual(
              secondResponseWithPaginationCached.totalResultCount
            );
            expect(dbQuerySpy.main).toHaveBeenCalledTimes(nonCacheableSubQueriesCount);
          });
        });

        describe('search pools by identifier filter', () => {
          // response should be the same despite the high order condition
          it('or condition', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                identifier: {
                  _condition: 'or',
                  values: [
                    { name: poolsInfo[0].name },
                    { name: poolsInfo[1].name },
                    { ticker: poolsInfo[0].ticker },
                    { id: poolsInfo[0].id }
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
                  values: [{ name: poolsInfo[0].name }, { ticker: poolsInfo[0].ticker }, { id: poolsInfo[0].id }]
                }
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const responseWithAndCondition = await provider.queryStakePools(req);
            expect(responseWithOrCondition).toEqual(responseWithAndCondition);

            const responseWithAndConditionCached = await provider.queryStakePools(req);
            expect(responseWithOrCondition).toEqual(responseWithAndConditionCached);
            expect(responseWithAndCondition).toEqual(responseWithAndConditionCached);

            expect(responseWithOrCondition.pageResults[0]?.metadata?.name).toEqual(poolsInfo[0].name);
            expect(responseWithOrCondition.pageResults[0]?.metadata?.ticker).toEqual(poolsInfo[0].ticker);
            expect(responseWithOrCondition.pageResults[0]?.id).toEqual(poolsInfo[0].id);
          });
          it('is case insensitive', async () => {
            const values = [{ name: poolsInfo[0].name, ticker: poolsInfo[0].ticker }];
            const insensitiveValues = [
              { name: toInvertedCase(poolsInfo[0].name), ticker: toInvertedCase(poolsInfo[0].ticker) }
            ];
            const req: QueryStakePoolsArgs = {
              filters: {
                identifier: { _condition: 'and', values }
              },
              pagination
            };
            const reqWithInsensitiveValues: QueryStakePoolsArgs = {
              filters: {
                identifier: { _condition: 'and', values: insensitiveValues }
              },
              pagination
            };
            const response = await provider.queryStakePools(req);
            const responseWithInsensitiveValues = await provider.queryStakePools(reqWithInsensitiveValues);
            expect(response).toEqual(responseWithInsensitiveValues);

            expect(responseWithInsensitiveValues.pageResults[0]?.metadata?.name).toEqual(poolsInfo[0].name);
            expect(responseWithInsensitiveValues.pageResults[0]?.metadata?.ticker).toEqual(poolsInfo[0].ticker);
            expect(responseWithInsensitiveValues.pageResults[0]?.id).toEqual(poolsInfo[0].id);
          });
          it('no given condition equals to OR condition', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                identifier: { values: [{ name: 'Unknown Name', ticker: poolsInfo[0].ticker }] }
              },
              pagination
            };
            const response = await provider.queryStakePools(req);
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            expect(response).toEqual(responseWithOrCondition);

            const responseCached = await provider.queryStakePools(req);
            expect(response).toEqual(responseCached);
            expect(responseWithOrCondition).toEqual(responseCached);

            const responseById = response.pageResults.find((pool) => pool.id === poolsInfo[0].id);
            expect(responseById?.metadata?.name).toEqual(poolsInfo[0].name);
            expect(responseById?.metadata?.ticker).toEqual(poolsInfo[0].ticker);
            expect(responseById?.id).toEqual(poolsInfo[0].id);
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
            const secondResponseCached = await provider.queryStakePools(req);
            expect(response).toEqual(secondResponseCached);
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

            const responseCached = await provider.queryStakePools(req);
            expect(response.pageResults).toEqual(responseCached.pageResults);
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
            const responseCached = await provider.queryStakePools(req);
            expect(response.pageResults).toEqual(responseCached.pageResults);
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
            const responseCached = await provider.queryStakePools(req);
            expect(response.pageResults).toEqual(responseCached.pageResults);
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
            const responseCached = await provider.queryStakePools(req);
            expect(response.pageResults).toEqual(responseCached.pageResults);
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retiring);
          });
        });

        describe('search pools by pledge met', () => {
          it('search by pledge met on true', async () => {
            const req: QueryStakePoolsArgs = {
              filters: {
                pledgeMet: true
              },
              pagination
            };
            const responseWithAndCondition = await provider.queryStakePools(req);
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            expect(responseWithOrCondition.pageResults).toEqual(responseWithAndCondition.pageResults);
            expect(responseWithOrCondition.totalResultCount).toEqual(responseWithAndCondition.totalResultCount);
            const responseCached = await provider.queryStakePools(req);
            expect(responseWithOrCondition).toEqual(responseCached);
            expect(responseWithAndCondition).toEqual(responseCached);
            expect(responseWithAndCondition.pageResults.length).toBeGreaterThan(0);
          });
          it('search by pledge met on false', async () => {
            const req = {
              filters: {
                pledgeMet: false
              },
              pagination
            };
            const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
            const responseWithAndCondition = await provider.queryStakePools(req);
            expect(responseWithAndCondition).toEqual(responseWithAndCondition);
            const responseCached = await provider.queryStakePools(req);
            expect(responseWithOrCondition).toEqual(responseCached);
            expect(responseWithAndCondition).toEqual(responseCached);
            expect(responseWithAndCondition.pageResults.length).toBeGreaterThan(0);
          });
        });

        describe('search pools by multiple filters', () => {
          describe('identifier & status filters', () => {
            it('active with or condition', async () => {
              const active = await fixtureBuilder.getPools(1, { with: [PoolWith.ActiveState] });
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
              const active = await fixtureBuilder.getPools(1, { with: [PoolWith.ActiveState] });
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
              const activatingPool = await fixtureBuilder.getPools(1, { with: [PoolWith.ActivatingState] });
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
              const activatingPool = await fixtureBuilder.getPools(1, { with: [PoolWith.ActivatingState] });
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
              const retiredPool = await fixtureBuilder.getPools(1, { with: [PoolWith.RetiredState] });
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
              const retiredPool = await fixtureBuilder.getPools(1, { with: [PoolWith.RetiredState] });
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
              const retiring = await fixtureBuilder.getPools(1, { with: [PoolWith.RetiringState] });
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
              const retiring = await fixtureBuilder.getPools(1, { with: [PoolWith.RetiringState] });
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
          describe('identifier & status & pledgeMet filters', () => {
            it('pledgeMet true, active, or condition', async () => {
              const active = await fixtureBuilder.getPools(1, { with: [PoolWith.ActiveState, PoolWith.PledgeMet] });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: active[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filter, 'or'), Cardano.StakePoolStatus.Active),
                true
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });
            it('pledgeMet false, active,  or condition', async () => {
              const active = await fixtureBuilder.getPools(1, { with: [PoolWith.ActiveState, PoolWith.PledgeNotMet] });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: active[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filter, 'or'), Cardano.StakePoolStatus.Active),
                false
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });
            it('pledgeMet true, status active, and condition', async () => {
              const active = await fixtureBuilder.getPools(1, { with: [PoolWith.ActiveState, PoolWith.PledgeMet] });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: active[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Active), true);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });
            it('pledgeMet false, status active, and condition', async () => {
              const active = await fixtureBuilder.getPools(1, { with: [PoolWith.ActiveState, PoolWith.PledgeNotMet] });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: active[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Active), false);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });
            it('pledgeMet true, status activating, or condition', async () => {
              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filterArgs, 'or'), Cardano.StakePoolStatus.Activating),
                true
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet false, status activating, or condition', async () => {
              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filterArgs, 'or'), Cardano.StakePoolStatus.Activating),
                false
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet true, status activating, and condition', async () => {
              const activating = await fixtureBuilder.getPools(1, {
                with: [PoolWith.ActivatingState, PoolWith.PledgeMet]
              });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: activating[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Activating), true);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Activating);
            });

            it('pledgeMet false, status active, and condition', async () => {
              const activating = await fixtureBuilder.getPools(1, {
                with: [PoolWith.ActiveState, PoolWith.PledgeNotMet]
              });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: activating[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Active), false);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Active);
            });

            it('pledgeMet true, status retired, or condition', async () => {
              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filterArgs, 'or'), Cardano.StakePoolStatus.Retired),
                true
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet false, status retired, or condition', async () => {
              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filterArgs, 'or'), Cardano.StakePoolStatus.Retired),
                false
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet true, status retired, and condition', async () => {
              const retiring = await fixtureBuilder.getPools(1, { with: [PoolWith.RetiredState, PoolWith.PledgeMet] });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiring[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Retired), true);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retired);
            });
            it('pledgeMet false, status retired, and condition', async () => {
              const retiring = await fixtureBuilder.getPools(1, {
                with: [PoolWith.RetiredState, PoolWith.PledgeNotMet]
              });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiring[0].id }]
                  }
                },
                pagination
              };

              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Retired), false);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
              expect(response.pageResults[0].status).toEqual(Cardano.StakePoolStatus.Retired);
            });
            it('pledgeMet true, status retiring, or condition', async () => {
              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filterArgs, 'or'), Cardano.StakePoolStatus.Retiring),
                true
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet false, status retiring, or condition', async () => {
              const options = addPledgeMetFilter(
                addStatusFilter(setFilterCondition(filterArgs, 'or'), Cardano.StakePoolStatus.Retiring),
                false
              );
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });

            // TODO: after regenerating test db, there are no 'retiring' pools
            it.skip('pledgeMet true, status retiring, and condition', async () => {
              const retiring = await fixtureBuilder.getPools(1, { with: [PoolWith.RetiringState, PoolWith.PledgeMet] });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiring[0].id }]
                  }
                },
                pagination
              };
              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Retiring), true);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });

            // TODO: after regenerating test db, there are no 'retiring' pools
            it.skip('pledgeMet false, status retiring, and condition', async () => {
              const retiring = await fixtureBuilder.getPools(1, {
                with: [PoolWith.RetiringState, PoolWith.PledgeNotMet]
              });
              const filter: QueryStakePoolsArgs = {
                filters: {
                  identifier: {
                    values: [{ id: retiring[0].id }]
                  }
                },
                pagination
              };
              const options = addPledgeMetFilter(addStatusFilter(filter, Cardano.StakePoolStatus.Retiring), false);
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet, multiple status, or condition', async () => {
              const response = await provider.queryStakePools(reqWithMultipleFilters);
              const responseCached = await provider.queryStakePools(reqWithMultipleFilters);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
            it('pledgeMet, multiple status, and condition', async () => {
              const options = setFilterCondition(reqWithMultipleFilters, 'and');
              const response = await provider.queryStakePools(options);
              const responseCached = await provider.queryStakePools(options);
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });
          });
        });

        // eslint-disable-next-line complexity, unicorn/consistent-function-scoping
        const sortByNameThenByPoolId = (poolA: Cardano.StakePool, poolB: Cardano.StakePool) => {
          if (poolA.metadata?.name && poolB.metadata?.name === '') return 1;
          if (poolB.metadata?.name && poolA.metadata?.name === '') return -1;
          if (poolA.metadata?.name && !poolB.metadata?.name) return -1;
          if (!poolA.metadata?.name && poolB.metadata?.name) return 1;
          if (poolA.metadata?.name && poolB.metadata?.name) {
            if (poolA.metadata?.name === poolB.metadata?.name) return 0;
            return poolA.metadata.name.toLowerCase() > poolB.metadata.name.toLowerCase() ? 1 : -1;
          }

          return poolA.id > poolB.id ? 1 : -1;
        };

        describe('stake pools sort', () => {
          describe('sort by name', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'name'));
              const responseCached = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'name'));
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });

            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'name'));
              const responseCached = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'name'));
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });

            it('if sort not provided, defaults to order by name and then by poolId asc', async () => {
              const response = await provider.queryStakePools({ pagination });
              const resultSortedCopy = [...response.pageResults].sort(sortByNameThenByPoolId);
              expect(response.pageResults.length).toBeGreaterThan(0);

              expect(response.pageResults).toEqual(resultSortedCopy);
              const responseCached = await provider.queryStakePools({ pagination });
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });

            describe('positions stake pools with no name registered after named pools, sorted by poolId', () => {
              let firstNoMetadataPoolId: Cardano.PoolId;
              let secondNoMetadataPoolId: Cardano.PoolId;
              let firstNamedPoolId: Cardano.PoolId;
              let reqOptions: QueryStakePoolsArgs;

              beforeAll(async () => {
                const poolsWithoutMeta = await fixtureBuilder.getDistinctPoolIds(2, false);
                const poolsWithMeta = await fixtureBuilder.getDistinctPoolIds(1, true);

                firstNoMetadataPoolId = poolsWithoutMeta[0];
                secondNoMetadataPoolId = poolsWithoutMeta[1];
                firstNamedPoolId = poolsWithMeta[0];

                reqOptions = {
                  filters: {
                    identifier: {
                      values: [{ id: secondNoMetadataPoolId }, { id: firstNoMetadataPoolId }, { id: firstNamedPoolId }]
                    }
                  },
                  pagination
                };
              });

              it('with name ascending', async () => {
                const stakePoolIdsSorted = [firstNamedPoolId, firstNoMetadataPoolId, secondNoMetadataPoolId];
                const { pageResults } = await provider.queryStakePools({
                  ...reqOptions,
                  sort: { field: 'name', order: 'asc' }
                });

                expect(() => Cardano.PoolId(firstNoMetadataPoolId as unknown as string)).not.toThrow();
                expect(() => Hash32ByteBase16(pageResults[0].metadataJson!.hash as unknown as string)).not.toThrow();
                expect(pageResults.length).toBeGreaterThan(0);
                expect(pageResults[pageResults.length - 1].metadata?.name).toBeUndefined();
                expect(pageResults.map(({ id }) => id)).toEqual(stakePoolIdsSorted);
              });

              it('with name descending', async () => {
                const stakePoolIdsSorted = [firstNamedPoolId, firstNoMetadataPoolId, secondNoMetadataPoolId];
                const { pageResults } = await provider.queryStakePools({
                  ...reqOptions,
                  sort: { field: 'name', order: 'desc' }
                });
                expect(pageResults.length).toBeGreaterThan(0);
                expect(pageResults[0].metadata?.name).toMatchShapeOf('some string');
                expect(pageResults.map(({ id }) => id)).toEqual(stakePoolIdsSorted);
              });
            });

            it('with applied filters', async () => {
              const reqWithFilters = setSortCondition(setFilterCondition(filterArgs, 'or'), 'desc', 'name');
              const response = await provider.queryStakePools(reqWithFilters);
              const responseCached = await provider.queryStakePools(reqWithFilters);
              expect(response.pageResults).toEqual(responseCached.pageResults);
            });

            it('asc order with applied pagination', async () => {
              const firstPageReq = setSortCondition(setPagination({ pagination }, 0, 3), 'asc', 'name');
              const secondPageReq = setSortCondition(setPagination({ pagination }, 3, 3), 'asc', 'name');

              const firstPageResultSet = await provider.queryStakePools(firstPageReq);

              const secondPageResultSet = await provider.queryStakePools(secondPageReq);
              const firstResponseCached = await provider.queryStakePools(firstPageReq);
              const secondResponseCached = await provider.queryStakePools(secondPageReq);

              expect(firstPageResultSet).toEqual(firstResponseCached);
              expect(secondPageResultSet).toEqual(secondResponseCached);
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

            it('asc order with applied pagination and filters', async () => {
              const options = setSortCondition(
                setPagination(setFilterCondition(filterArgs, 'or'), 0, 5),
                'asc',
                'name'
              );
              const responsePage = await provider.queryStakePools(options);
              const responsePageCached = await provider.queryStakePools(options);
              expect(responsePage.pageResults).toEqual(responsePageCached.pageResults);
            });
          });

          describe('sort by saturation', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'saturation'));
              expect(response.pageResults.length).toBeGreaterThan(0);
            });
            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'saturation'));
              expect(response.pageResults.length).toBeGreaterThan(0);
            });
            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'saturation')
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
            });
            it('with applied pagination', async () => {
              const firstPageOptions = setSortCondition(setPagination({ pagination }, 0, 3), 'asc', 'saturation');
              const secondPageOptions = setSortCondition(setPagination({ pagination }, 3, 3), 'asc', 'saturation');

              const firstPageResultSet = await provider.queryStakePools(firstPageOptions);
              const secondPageResultSet = await provider.queryStakePools(secondPageOptions);
              const firstPageResultSetCached = await provider.queryStakePools(firstPageOptions);
              const secondPageResultSetCached = await provider.queryStakePools(secondPageOptions);

              expect(firstPageResultSet.pageResults).toEqual(firstPageResultSetCached.pageResults);
              expect(secondPageResultSet.pageResults).toEqual(secondPageResultSetCached.pageResults);
            });

            it('returns only the remaining items in a result set, on the final page when using pagination', async () => {
              const firstPageOptions = setSortCondition(setPagination({ pagination }, 0, 10), 'asc', 'saturation');
              const { totalResultCount } = await provider.queryStakePools(firstPageOptions);
              const secondPageOptions = setSortCondition(
                setPagination({ pagination }, totalResultCount - 1, 10),
                'asc',
                'saturation'
              );
              const { pageResults } = await provider.queryStakePools(secondPageOptions);

              expect(pageResults.length).toBe(1);
            });
          });

          describe('sort by APY', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'apy'));
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].metrics?.apy).toBeDefined();
            });
            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'apy'));
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].metrics?.apy).toBeDefined();
            });
            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'apy')
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
              expect(response.pageResults[0].metrics?.apy).toBeDefined();
            });
            it('with applied pagination', async () => {
              const firstPageOptions = setSortCondition(setPagination({ pagination }, 0, 3), 'desc', 'apy');
              const secondPageOptions = setSortCondition(setPagination({ pagination }, 3, 3), 'desc', 'apy');

              const firstPageResultSet = await provider.queryStakePools(firstPageOptions);
              const secondPageResultSet = await provider.queryStakePools(secondPageOptions);
              const firstPageResultSetCached = await provider.queryStakePools(firstPageOptions);
              const secondPageResultSetCached = await provider.queryStakePools(secondPageOptions);

              expect(firstPageResultSet.pageResults).toEqual(firstPageResultSetCached.pageResults);
              expect(secondPageResultSet.pageResults).toEqual(secondPageResultSetCached.pageResults);
            });
          });

          describe('sort by cost and margin', () => {
            it('desc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'cost'));
              expect(response.pageResults.length).toBeGreaterThan(0);
            });
            it('asc order', async () => {
              const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'cost'));
              expect(response.pageResults.length).toBeGreaterThan(0);
            });
            it('with applied filters', async () => {
              const response = await provider.queryStakePools(
                setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'cost')
              );
              expect(response.pageResults.length).toBeGreaterThan(0);
            });
            it('with applied pagination', async () => {
              const firstPageOptions = setSortCondition(setPagination({ pagination }, 0, 3), 'desc', 'cost');
              const secondPageOptions = setSortCondition(setPagination({ pagination }, 3, 3), 'desc', 'cost');

              const firstPageResultSet = await provider.queryStakePools(firstPageOptions);
              const secondPageResultSet = await provider.queryStakePools(secondPageOptions);
              const firstPageResultSetCached = await provider.queryStakePools(firstPageOptions);
              const secondPageResultSetCached = await provider.queryStakePools(secondPageOptions);

              expect(firstPageResultSet.pageResults).toEqual(firstPageResultSetCached.pageResults);
              expect(secondPageResultSet.pageResults).toEqual(secondPageResultSetCached.pageResults);
            });
          });
        });

        it('apyEpochsBackLimit is correctly honored', async () => {
          const limitThreeResponse = await provider.queryStakePools({ apyEpochsBackLimit: 3, pagination });
          const limitFiveResponse = await provider.queryStakePools({ apyEpochsBackLimit: 5, pagination });
          expect(limitThreeResponse.pageResults[0].metrics?.apy).not.toBe(
            limitFiveResponse.pageResults[0].metrics?.apy
          );
        });

        it('text filter is not supported', async () => {
          await expect(
            provider.queryStakePools({
              apyEpochsBackLimit: 3,
              filters: { text: 'test' },
              pagination
            })
          ).rejects.toThrow('DbSyncStakePoolProvider does not support text filter');
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
          expect(response.qty).toMatchShapeOf({ active: 0, retired: 0, retiring: 0 });

          const responseCached = await provider.stakePoolStats();
          expect(response.qty).toEqual(responseCached.qty);
        });

        describe('server and snapshot testing', () => {
          it('has active, retired and retiring stake pools count', async () => {
            const response = await provider.stakePoolStats();
            expect(response.qty).toBeDefined();
            expect(response.qty).toMatchShapeOf({ active: 0, retired: 0, retiring: 0 });
          });
        });
      });
    });
    describe('with APY metric disabled', () => {
      beforeAll(async () => {
        stakePoolProvider = new DbSyncStakePoolProvider(
          {
            paginationPageSizeLimit: pagination.limit,
            responseConfig: { search: { metrics: { apy: false } } },
            useBlockfrost: false
          },
          { cache, cardanoNode, dbPools, epochMonitor, genesisData, logger, metadataService }
        );
        service = new StakePoolHttpService({ logger, stakePoolProvider });
        httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
        await httpServer.initialize();
        await httpServer.start();
      });
      afterAll(async () => {
        await httpServer.shutdown();
      });
      describe('/search', () => {
        it('response excludes stake pool APY metric', async () => {
          const response = await provider.queryStakePools({ pagination: { limit: 1, startAt: 0 } });
          expect(response.pageResults[0].metrics?.apy).toBeUndefined();
        });
        describe('sort by APY', () => {
          it('desc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({ pagination }, 'desc', 'apy'));
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].metrics?.apy).toBeUndefined();
          });
          it('asc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({ pagination }, 'asc', 'apy'));
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].metrics?.apy).toBeUndefined();
          });
          it('with applied filters', async () => {
            const response = await provider.queryStakePools(
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'apy')
            );
            expect(response.pageResults.length).toBeGreaterThan(0);
            expect(response.pageResults[0].metrics?.apy).toBeUndefined();
          });
        });
      });
    });
  });
});
