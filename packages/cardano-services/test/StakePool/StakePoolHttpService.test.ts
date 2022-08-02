/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */
import {
  Cardano,
  ProviderError,
  ProviderFailure,
  SortField,
  StakePoolProvider,
  StakePoolQueryOptions
} from '@cardano-sdk/core';
import { CreateHttpProviderConfig, stakePoolHttpProvider } from '../../../cardano-services-client';
import { DbSyncEpochPollService } from '../../src/util';
import { DbSyncStakePoolProvider, HttpServer, HttpServerConfig, StakePoolHttpService } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../src/InMemoryCache';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { ingestDbData, sleep, wrapWithTransaction } from '../util';
import { dummyLogger as logger } from 'ts-log';
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
  let httpServer: HttpServer;
  let stakePoolProvider: DbSyncStakePoolProvider;
  let service: StakePoolHttpService;
  let port: number;
  let baseUrl: string;
  let clientConfig: CreateHttpProviderConfig<StakePoolProvider>;
  let config: HttpServerConfig;
  let provider: StakePoolProvider;

  const epochPollInterval = 2 * 1000;
  const cache = new InMemoryCache(UNLIMITED_CACHE_TTL);
  const db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING, max: 1, min: 1 });
  const epochMonitor = new DbSyncEpochPollService(db, epochPollInterval!);

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/stake-pool`;
    config = { listen: { port } };
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
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
      expect(() => new StakePoolHttpService({ logger, stakePoolProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the StakePoolProvider is unhealthy', async () => {
      service = new StakePoolHttpService({ logger, stakePoolProvider });
      httpServer = new HttpServer(config, { logger, services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    const dbConnectionQuerySpy = jest.spyOn(db, 'query');
    const clearCacheSpy = jest.spyOn(cache, 'clear');

    beforeAll(async () => {
      stakePoolProvider = new DbSyncStakePoolProvider({ cache, db, epochMonitor, logger });
      service = new StakePoolHttpService({ logger, stakePoolProvider });
      httpServer = new HttpServer(config, { logger, services: [service] });
      provider = stakePoolHttpProvider(clientConfig);

      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await db.end();
      await httpServer.shutdown();
      cache.shutdown();
      jest.clearAllTimers();
    });

    beforeEach(async () => {
      cache.clear();
      jest.clearAllMocks();
      dbConnectionQuerySpy.mockClear();
      clearCacheSpy.mockClear();
    });

    describe('start', () => {
      it('should start epoch monitor once the db provider is initialized and started', async () => {
        await sleep(epochPollInterval * 2);

        expect(await epochMonitor.getLastKnownEpoch()).toBeDefined();
        expect(clearCacheSpy).not.toHaveBeenCalled();
      });
    });

    describe('/health', () => {
      it('forwards the stakePoolProvider health response', async () => {
        const res = await axios.post(`${baseUrl}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/search', () => {
      const url = '/search';
      const DB_POLL_QUERIES_COUNT = 1;
      const cachedSubQueriesCount = 10;
      const cacheKeysCount = 6;
      const nonCacheableSubQueriesCount = 2; // queryTotalCount and getLastEpoch
      const filerOnePoolOptions: StakePoolQueryOptions = {
        filters: {
          identifier: {
            values: [{ id: Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70') }]
          }
        }
      };

      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}${url}`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}${url}`, undefined, { headers: { 'Content-Type': APPLICATION_CBOR } });
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
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

      it('should query the DB only once when the response is cached', async () => {
        await provider.queryStakePools(filerOnePoolOptions);
        expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(cachedSubQueriesCount + nonCacheableSubQueriesCount);
        dbConnectionQuerySpy.mockClear();
        await provider.queryStakePools(filerOnePoolOptions);
        expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(nonCacheableSubQueriesCount);
        expect(cache.keys().length).toEqual(cacheKeysCount);
      });

      it('should call db-sync queries again once the cache is cleared', async () => {
        await provider.queryStakePools(filerOnePoolOptions);
        cache.clear();
        expect(cache.keys().length).toEqual(0);

        await provider.queryStakePools(filerOnePoolOptions);
        expect(dbConnectionQuerySpy).toBeCalledTimes((cachedSubQueriesCount + nonCacheableSubQueriesCount) * 2);
      });

      it('should not invalidate the epoch values from the cache if there is no epoch rollover', async () => {
        const currentEpochNo = 205;
        const response = await provider.queryStakePools(filerOnePoolOptions);

        expect(cache.keys().length).toEqual(cacheKeysCount);

        await sleep(epochPollInterval);

        expect(await epochMonitor.getLastKnownEpoch()).toEqual(currentEpochNo);
        expect(cache.keys().length).toEqual(cacheKeysCount);
        expect(dbConnectionQuerySpy).toBeCalledTimes(
          cachedSubQueriesCount + nonCacheableSubQueriesCount + DB_POLL_QUERIES_COUNT
        );
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

          expect(cache.keys().length).toEqual(cacheKeysCount);
          await ingestDbData(
            dbConnection,
            'epoch',
            ['id', 'out_sum', 'fees', 'tx_count', 'blk_count', 'no', 'start_time', 'end_time'],
            [greaterEpoch, 58_389_393_484_858, 43_424_552, 55_666, 10_000, greaterEpoch, '2022-05-28', '2022-06-02']
          );

          await sleep(epochPollInterval);
          expect(clearCacheSpy).toHaveBeenCalled();

          expect(await epochMonitor.getLastKnownEpoch()).toEqual(greaterEpoch);
          expect(cache.keys().length).toEqual(0);
        }, db)
      );

      describe('pagination', () => {
        it('should paginate response', async () => {
          const req: StakePoolQueryOptions = {};
          const reqWithPagination: StakePoolQueryOptions = { pagination: { limit: 2, startAt: 1 } };
          const responseWithPagination = await provider.queryStakePools(reqWithPagination);
          const response = await provider.queryStakePools(req);
          expect(response.pageResults.length).toEqual(10);
          expect(responseWithPagination.pageResults.length).toEqual(2);
          expect(response.pageResults[0]).not.toEqual(responseWithPagination.pageResults[0]);

          const responseWithPaginationCached = await provider.queryStakePools(reqWithPagination);
          expect(responseWithPagination.pageResults).toEqual(responseWithPaginationCached.pageResults);
        });
        it('should paginate response with or condition', async () => {
          const req: StakePoolQueryOptions = { filters: { _condition: 'or' } };
          const reqWithPagination: StakePoolQueryOptions = { ...req, pagination: { limit: 2, startAt: 1 } };
          const responseWithPagination = await provider.queryStakePools(reqWithPagination);
          const response = await provider.queryStakePools(req);
          expect(response.pageResults.length).toEqual(10);
          expect(responseWithPagination.pageResults.length).toEqual(2);
          expect(response.pageResults[0]).not.toEqual(responseWithPagination.pageResults[0]);

          const responseWithPaginationCached = await provider.queryStakePools(reqWithPagination);
          expect(responseWithPagination.pageResults).toEqual(responseWithPaginationCached.pageResults);
        });
        it('should paginate rewards response', async () => {
          const req = { pagination: { limit: 1, startAt: 1 } };
          const reqWithRewardsPagination = { pagination: { limit: 1, startAt: 1 }, rewardsHistoryLimit: 0 };
          const responseWithPagination = await provider.queryStakePools(reqWithRewardsPagination);
          const response = await provider.queryStakePools(req);
          expect(response.pageResults[0].epochRewards.length).toEqual(1);
          expect(responseWithPagination.pageResults[0].epochRewards.length).toEqual(0);

          const responseCached = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual(responseCached.pageResults);
          const responsePaginatedCached = await provider.queryStakePools(reqWithRewardsPagination);
          expect(responseWithPagination.pageResults).toEqual(responsePaginatedCached.pageResults);
        });
        it('should paginate rewards response with or condition', async () => {
          const req: StakePoolQueryOptions = { filters: { _condition: 'or' }, pagination: { limit: 1, startAt: 1 } };
          const reqWithRewardsPagination = { pagination: { limit: 1, startAt: 1 }, rewardsHistoryLimit: 0 };
          const responseWithPagination = await provider.queryStakePools(reqWithRewardsPagination);
          const response = await provider.queryStakePools(req);
          expect(response.pageResults[0].epochRewards.length).toEqual(1);
          expect(responseWithPagination.pageResults[0].epochRewards.length).toEqual(0);

          const responseCached = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual(responseCached.pageResults);
          const responsePaginatedCached = await provider.queryStakePools(reqWithRewardsPagination);
          expect(responseWithPagination.pageResults).toEqual(responsePaginatedCached.pageResults);
        });
        it('should cache paginated response', async () => {
          const reqWithPagination: StakePoolQueryOptions = { pagination: { limit: 2, startAt: 1 } };
          const firstResponseWithPagination = await provider.queryStakePools(reqWithPagination);
          expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(
            cachedSubQueriesCount + nonCacheableSubQueriesCount + DB_POLL_QUERIES_COUNT
          );
          dbConnectionQuerySpy.mockClear();
          const secondResponseWithPaginationCached = await provider.queryStakePools(reqWithPagination);
          expect(firstResponseWithPagination.pageResults).toEqual(secondResponseWithPaginationCached.pageResults);
          expect(firstResponseWithPagination.totalResultCount).toEqual(
            secondResponseWithPaginationCached.totalResultCount
          );
          expect(dbConnectionQuerySpy).toHaveBeenCalledTimes(nonCacheableSubQueriesCount);
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
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          const responseWithAndCondition = await provider.queryStakePools(req);
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
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          const responseWithAndCondition = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(responseWithOrCondition).toEqual(responseWithAndCondition);

          const responseWithAndConditionCached = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toEqual(responseWithAndConditionCached);
          expect(responseWithAndCondition).toEqual(responseWithAndConditionCached);
        });
        it('no given condition equals to OR condition', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              identifier: { values: [{ name: 'Unknown Name', ticker: 'TEST' }] }
            }
          };
          const response = await provider.queryStakePools(req);
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          expect(response).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);

          const responseCached = await provider.queryStakePools(req);
          expect(response).toEqual(responseCached);
          expect(responseWithOrCondition).toEqual(responseCached);
        });
        it('stake pools do not match identifier filter', async () => {
          const req = {
            filters: {
              identifier: {
                condition: 'and',
                values: [{ name: 'Unknown Name' }]
              }
            }
          };
          const response = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual([]);

          const secondRsponseCached = await provider.queryStakePools(req);
          expect(response).toEqual(secondRsponseCached);
        });
        it('empty values ignores identifier filter', async () => {
          const req = {
            filters: {
              identifier: {
                values: []
              }
            }
          };
          const reqWithNoFilters = {};
          const response = await provider.queryStakePools(req);
          const responseWithNoFilters = await provider.queryStakePools(reqWithNoFilters);
          expect(response).toEqual(responseWithNoFilters);
        });
      });
      describe('search pools by status', () => {
        it('search by active status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              status: [Cardano.StakePoolStatus.Active]
            }
          };
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          const response = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);

          const responseCached = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual(responseCached.pageResults);
        });
        it('search by activating status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              _condition: 'or',
              status: [Cardano.StakePoolStatus.Activating]
            }
          };
          const response = await provider.queryStakePools(req);
          expect(response).toMatchSnapshot();

          const responseCached = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual(responseCached.pageResults);
        });
        it('search by retired status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              status: [Cardano.StakePoolStatus.Retired]
            }
          };
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          const response = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);

          const responseCached = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual(responseCached.pageResults);
        });
        it('search by retiring status', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              status: [Cardano.StakePoolStatus.Retiring]
            }
          };
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          const response = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(response).toEqual(responseWithOrCondition);

          const responseCached = await provider.queryStakePools(req);
          expect(response.pageResults).toEqual(responseCached.pageResults);
        });
      });

      describe('search pools by pledge met', () => {
        it('search by pledge met on true', async () => {
          const req: StakePoolQueryOptions = {
            filters: {
              pledgeMet: true
            }
          };
          const responseWithAndCondition = await provider.queryStakePools(req);
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          expect(responseWithOrCondition.pageResults).toEqual(responseWithAndCondition.pageResults);
          expect(responseWithOrCondition.totalResultCount).toEqual(responseWithAndCondition.totalResultCount);

          const responseCached = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toEqual(responseCached);
          expect(responseWithAndCondition).toEqual(responseCached);
        });
        it('search by pledge met on false', async () => {
          const req = {
            filters: {
              pledgeMet: false
            }
          };
          const responseWithOrCondition = await provider.queryStakePools(setFilterCondition(req, 'or'));
          const responseWithAndCondition = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toMatchSnapshot();
          expect(responseWithAndCondition).toEqual(responseWithAndCondition);

          const responseCached = await provider.queryStakePools(req);
          expect(responseWithOrCondition).toEqual(responseCached);
          expect(responseWithAndCondition).toEqual(responseCached);
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
            const response = await provider.queryStakePools(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active)
            );
            expect(response).toMatchSnapshot();
          });
          it('active with and condition', async () => {
            const response = await provider.queryStakePools(addStatusFilter(req, Cardano.StakePoolStatus.Active));
            expect(response).toMatchSnapshot();
          });
          it('activating with or condition', async () => {
            const response = await provider.queryStakePools(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating)
            );
            expect(response).toMatchSnapshot();
          });
          it('activating with and condition', async () => {
            const response = await provider.queryStakePools(addStatusFilter(req, Cardano.StakePoolStatus.Activating));
            expect(response).toMatchSnapshot();
          });
          it('retired with or condition', async () => {
            const response = await provider.queryStakePools(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired)
            );
            expect(response).toMatchSnapshot();
          });
          it('retired with and condition', async () => {
            const response = await provider.queryStakePools(addStatusFilter(req, Cardano.StakePoolStatus.Retired));
            expect(response).toMatchSnapshot();
          });
          it('retiring with or condition', async () => {
            const response = await provider.queryStakePools(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring)
            );
            expect(response).toMatchSnapshot();
          });
          it('retiring with and condition', async () => {
            const response = await provider.queryStakePools(addStatusFilter(req, Cardano.StakePoolStatus.Retiring));
            expect(response).toMatchSnapshot();
          });
        });
        describe('identifier & status & pledgeMet filters', () => {
          it('pledgeMet true, active, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active),
              true
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, active,  or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Active),
              false
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status active, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), true);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status active, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Active), false);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status activating, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
              true
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status activating, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Activating),
              false
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status activating, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), true);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status activating, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Activating), false);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status retired, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired),
              true
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status retired, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retired),
              false
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status retired, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), true);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status retired, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retired), false);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status retiring, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring),
              true
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status retiring, or condition', async () => {
            const options = addPledgeMetFilter(
              addStatusFilter(setFilterCondition(req, 'or'), Cardano.StakePoolStatus.Retiring),
              false
            );
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet true, status retiring, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), true);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet false, status retiring, and condition', async () => {
            const options = addPledgeMetFilter(addStatusFilter(req, Cardano.StakePoolStatus.Retiring), false);
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet, multiple status, or condition', async () => {
            const response = await provider.queryStakePools(reqWithMultipleFilters);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(reqWithMultipleFilters);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });
          it('pledgeMet, multiple status, and condition', async () => {
            const options = setFilterCondition(reqWithMultipleFilters, 'and');
            const response = await provider.queryStakePools(options);
            expect(response).toMatchSnapshot();
            const responseCached = await provider.queryStakePools(options);
            expect(response.pageResults).toEqual(responseCached.pageResults);
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
            const response = await provider.queryStakePools(setSortCondition({}, 'desc', 'name'));
            expect(response).toMatchSnapshot();

            const responseCached = await provider.queryStakePools(setSortCondition({}, 'desc', 'name'));
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });

          it('asc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'asc', 'name'));
            expect(response).toMatchSnapshot();

            const responseCached = await provider.queryStakePools(setSortCondition({}, 'asc', 'name'));
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });

          it('if sort not provided, defaults to order by name and then by poolId asc', async () => {
            const response = await provider.queryStakePools({});
            const resultSortedCopy = [...response.pageResults].sort(sortByNameThenByPoolId);

            expect(response.pageResults).toEqual(resultSortedCopy);
            expect(response).toMatchSnapshot();

            const responseCached = await provider.queryStakePools({});
            expect(response.pageResults).toEqual(responseCached.pageResults);
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
              const { pageResults } = await provider.queryStakePools({
                ...reqOptions,
                sort: { field: 'name', order: 'asc' }
              });

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
              const { pageResults } = await provider.queryStakePools({
                ...reqOptions,
                sort: { field: 'name', order: 'desc' }
              });
              expect(pageResults.length).toEqual(4);
              expect(pageResults[0].metadata?.name).toEqual('Farts');
              expect(pageResults[pageResults.length - 1].metadata?.name).toBeUndefined();
              expect(pageResults.map(({ id }) => id)).toEqual(stakePoolIdsSorted);
            });
          });

          it('with applied filters', async () => {
            const reqWithFilters = setSortCondition(setFilterCondition(filterArgs, 'or'), 'desc', 'name');
            const response = await provider.queryStakePools(reqWithFilters);
            expect(response).toMatchSnapshot();

            const responseCached = await provider.queryStakePools(reqWithFilters);
            expect(response.pageResults).toEqual(responseCached.pageResults);
          });

          it('asc order with applied pagination', async () => {
            const firstPageReq = setSortCondition(setPagination({}, 0, 3), 'asc', 'name');
            const secondPageReq = setSortCondition(setPagination({}, 3, 3), 'asc', 'name');

            const firstPageResultSet = await provider.queryStakePools(firstPageReq);

            const secondPageResultSet = await provider.queryStakePools(secondPageReq);

            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();

            const firstResponseCached = await provider.queryStakePools(firstPageReq);
            const secondResponseCached = await provider.queryStakePools(secondPageReq);

            expect(firstPageResultSet).toEqual(firstResponseCached);
            expect(secondPageResultSet).toEqual(secondResponseCached);
          });

          it('asc order with applied pagination, with change sort order on next page', async () => {
            const firstPageResponse = await provider.queryStakePools(
              setSortCondition(setPagination({}, 0, 5), 'asc', 'name')
            );

            const secondPageResponse = await provider.queryStakePools(
              setSortCondition(setPagination({}, 5, 5), 'asc', 'name')
            );
            const firstPageIds = firstPageResponse.pageResults.map(({ id }) => id);

            const hasDuplicatedIdsBetweenPages = firstPageIds.some((id) =>
              secondPageResponse.pageResults.map((stake) => stake.id).includes(id)
            );

            expect(firstPageResponse).toMatchSnapshot();
            expect(secondPageResponse).toMatchSnapshot();
            expect(hasDuplicatedIdsBetweenPages).toBe(false);
          });

          it('asc order with applied pagination and filters', async () => {
            const options = setSortCondition(setPagination(setFilterCondition(filterArgs, 'or'), 0, 5), 'asc', 'name');
            const responsePage = await provider.queryStakePools(options);

            expect(responsePage).toMatchSnapshot();

            const responsePageCached = await provider.queryStakePools(options);
            expect(responsePage.pageResults).toEqual(responsePageCached.pageResults);
          });
        });

        describe('sort by saturation', () => {
          it('desc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'desc', 'saturation'));
            expect(response).toMatchSnapshot();
          });
          it('asc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'asc', 'saturation'));
            expect(response).toMatchSnapshot();
          });
          it('with applied filters', async () => {
            const response = await provider.queryStakePools(
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'saturation')
            );
            expect(response).toMatchSnapshot();
          });
          it('with applied pagination', async () => {
            const firstPageOptions = setSortCondition(setPagination({}, 0, 3), 'asc', 'saturation');
            const secondPageOptions = setSortCondition(setPagination({}, 3, 3), 'asc', 'saturation');

            const firstPageResultSet = await provider.queryStakePools(firstPageOptions);
            const secondPageResultSet = await provider.queryStakePools(secondPageOptions);

            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();

            const firstPageResultSetCached = await provider.queryStakePools(firstPageOptions);
            const secondPageResultSetCached = await provider.queryStakePools(secondPageOptions);

            expect(firstPageResultSet.pageResults).toEqual(firstPageResultSetCached.pageResults);
            expect(secondPageResultSet.pageResults).toEqual(secondPageResultSetCached.pageResults);
          });
        });

        describe('sort by APY', () => {
          it('desc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'desc', 'apy'));
            expect(response).toMatchSnapshot();
          });
          it('asc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'asc', 'apy'));
            expect(response).toMatchSnapshot();
          });
          it('with applied filters', async () => {
            const response = await provider.queryStakePools(
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'apy')
            );
            expect(response).toMatchSnapshot();
          });
          it('with applied pagination', async () => {
            const firstPageOptions = setSortCondition(setPagination({}, 0, 3), 'desc', 'apy');
            const secondPageOptions = setSortCondition(setPagination({}, 3, 3), 'desc', 'apy');

            const firstPageResultSet = await provider.queryStakePools(firstPageOptions);
            const secondPageResultSet = await provider.queryStakePools(secondPageOptions);
            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();

            const firstPageResultSetCached = await provider.queryStakePools(firstPageOptions);
            const secondPageResultSetCached = await provider.queryStakePools(secondPageOptions);

            expect(firstPageResultSet.pageResults).toEqual(firstPageResultSetCached.pageResults);
            expect(secondPageResultSet.pageResults).toEqual(secondPageResultSetCached.pageResults);
          });
        });

        describe('sort by cost and margin', () => {
          it('desc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'desc', 'cost'));
            expect(response).toMatchSnapshot();
          });
          it('asc order', async () => {
            const response = await provider.queryStakePools(setSortCondition({}, 'asc', 'cost'));
            expect(response).toMatchSnapshot();
          });
          it('with applied filters', async () => {
            const response = await provider.queryStakePools(
              setSortCondition(setFilterCondition(filterArgs, 'or'), 'asc', 'cost')
            );
            expect(response).toMatchSnapshot();
          });
          it('with applied pagination', async () => {
            const firstPageOptions = setSortCondition(setPagination({}, 0, 3), 'desc', 'cost');
            const secondPageOptions = setSortCondition(setPagination({}, 3, 3), 'desc', 'cost');

            const firstPageResultSet = await provider.queryStakePools(firstPageOptions);
            const secondPageResultSet = await provider.queryStakePools(secondPageOptions);

            expect(firstPageResultSet).toMatchSnapshot();
            expect(secondPageResultSet).toMatchSnapshot();

            const firstPageResultSetCached = await provider.queryStakePools(firstPageOptions);
            const secondPageResultSetCached = await provider.queryStakePools(secondPageOptions);

            expect(firstPageResultSet.pageResults).toEqual(firstPageResultSetCached.pageResults);
            expect(secondPageResultSet.pageResults).toEqual(secondPageResultSetCached.pageResults);
          });
        });
      });
    });

    describe('/stats', () => {
      const url = '/stats';
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}${url}`, { args: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}${url}`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('response is an object with stake pool stats', async () => {
        const response = await provider.stakePoolStats();
        expect(response.qty.active).toBe(8);
        expect(response.qty.retired).toBe(2);
        expect(response.qty.retiring).toBe(0);

        const responseCached = await provider.stakePoolStats();
        expect(response.qty).toEqual(responseCached.qty);
      });

      describe('server and snapshot testing', () => {
        it('has active, retired and retiring stake pools count', async () => {
          const response = await provider.stakePoolStats();
          expect(response.qty).toBeDefined();
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
