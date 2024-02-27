/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-unused-vars */
import { Cardano, QueryStakePoolsArgs } from '@cardano-sdk/core';
import { DataMocks } from '../../data-mocks';
import { DbSyncStakePoolFixtureBuilder, PoolInfo, PoolWith } from '../fixtures/FixtureBuilder';
import { PAGINATION_PAGE_SIZE_LIMIT_DEFAULT, StakePoolBuilder } from '../../../src';
import { Pool } from 'pg';
import { logger } from '@cardano-sdk/util-dev';

describe('StakePoolBuilder', () => {
  const dbConnection = new Pool({
    connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
  });
  const pagination = { limit: PAGINATION_PAGE_SIZE_LIMIT_DEFAULT, startAt: 0 };
  const builder = new StakePoolBuilder(dbConnection, logger);
  const epochLength = 432_000_000;
  let fixtureBuilder: DbSyncStakePoolFixtureBuilder;
  let poolsInfo: PoolInfo[];
  let hashIds: number[];
  let updateIds: number[];
  let filters: QueryStakePoolsArgs['filters'];

  beforeAll(async () => {
    fixtureBuilder = new DbSyncStakePoolFixtureBuilder(dbConnection, logger);
    poolsInfo = await fixtureBuilder.getPools(3, { with: [PoolWith.Metadata] });
    hashIds = poolsInfo.map((info) => info.hashId);
    updateIds = poolsInfo.map((info) => info.updateId);
    filters = {
      _condition: 'or',
      identifier: {
        _condition: 'and',
        values: [{ name: `${poolsInfo[0]!.name}` }, { ticker: poolsInfo[0]!.ticker }, { id: poolsInfo[0]!.id }]
      },
      pledgeMet: true,
      status: Object.values(Cardano.StakePoolStatus)
    };
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  describe('queryRetirements', () => {
    it('queryRetirements', async () => {
      const retiredPool = await fixtureBuilder.getPools(2, { with: [PoolWith.RetiredState] });
      const retiredHashes = retiredPool.map((info) => info.hashId);
      const retirements = (await builder.queryRetirements(retiredHashes)).map((r) => {
        const { hashId, ...rest } = r;
        return rest;
      });
      expect(retirements.length).toBeGreaterThan(0);
      expect(retirements[0]).toMatchShapeOf(DataMocks.Pool.retirement);
    });
  });
  describe('queryRegistrations', () => {
    it('queryRegistrations', async () => {
      const registrations = (await builder.queryRegistrations(hashIds)).map((r) => {
        const { hashId, ...rest } = r;
        return rest;
      });
      expect(registrations.length).toBeGreaterThan(0);
      expect(registrations[0]).toMatchShapeOf(DataMocks.Pool.registration);
    });
  });
  describe('queryPoolRelays', () => {
    it('queryPoolRelays', async () => {
      const relays = await builder.queryPoolRelays(updateIds);
      expect(relays.length).toBeGreaterThan(0);
      expect(relays[0]).toMatchShapeOf(DataMocks.Pool.relay);
    });
  });
  describe('queryPoolOwners', () => {
    it('queryPoolOwners', async () => {
      const ownersAddresses = (await builder.queryPoolOwners(updateIds)).map((o) => o.address);
      expect(ownersAddresses.length).toBeGreaterThan(0);
      expect(ownersAddresses[0]).toMatchShapeOf('stake_test1urryfvusd49ej55gvf3cxtje4pqmtcdswwqxw37g6uclhnsqj7d5w');
    });
  });
  describe('queryPoolMetrics', () => {
    const totalAda = '42021479194505231';
    describe('sort', () => {
      it('by default sort', async () => {
        const metrics = (await builder.queryPoolMetrics(hashIds, totalAda, false)).map((m) => m.metrics);
        expect(metrics).toHaveLength(3);

        expect(metrics).toHaveLength(3);
        expect(metrics[0]).toMatchShapeOf(DataMocks.Pool.metrics);
      });
      it('by saturation', async () => {
        const metrics = (
          await builder.queryPoolMetrics(hashIds, totalAda, false, {
            pagination,
            sort: { field: 'saturation', order: 'asc' }
          })
        ).map((m) => m.metrics);

        expect(metrics).toHaveLength(3);
        expect(metrics[0]).toMatchShapeOf(DataMocks.Pool.metrics);
      });
    });
    describe('pagination', () => {
      it('with limit', async () => {
        const metrics = (
          await builder.queryPoolMetrics(hashIds, totalAda, false, { pagination: { limit: 2, startAt: 0 } })
        ).map((m) => m.metrics);
        expect(metrics).toHaveLength(2);

        expect(metrics[0]).toMatchShapeOf(DataMocks.Pool.metrics);
      });
      it('with startAt', async () => {
        const metrics = (
          await builder.queryPoolMetrics(hashIds, totalAda, false, { pagination: { limit: 3, startAt: 1 } })
        ).map((m) => m.metrics);
        expect(metrics).toHaveLength(2);

        expect(metrics[0]).toMatchShapeOf(DataMocks.Pool.metrics);
      });
    });
  });
  describe('queryPoolData', () => {
    describe('sort', () => {
      it('by default sort (name asc)', async () => {
        const pools = (await builder.queryPoolData(hashIds, false)).map((qR) => {
          const { hashId, updateId, ...poolData } = qR;
          return poolData;
        });
        expect(pools).toHaveLength(hashIds.length);
        expect(pools[0]).toMatchShapeOf(DataMocks.Pool.info);
      });
      it('by name desc', async () => {
        const pools = (
          await builder.queryPoolData(hashIds, false, { pagination, sort: { field: 'name', order: 'desc' } })
        ).map((qR) => {
          const { hashId: _1, updateId: _2, ...poolData } = qR;
          return poolData;
        });
        expect(pools).toHaveLength(3);
        expect(pools[0]).toMatchShapeOf(DataMocks.Pool.info);
      });
      it('by real-world cost considering fixed cost and margin when specifying sort by cost desc', async () => {
        const pools = (
          await builder.queryPoolData(hashIds, false, { pagination, sort: { field: 'cost', order: 'desc' } })
        ).map((qR) => {
          const { hashId: _1, updateId: _2, ...poolData } = qR;
          return poolData;
        });
        expect(pools).toHaveLength(3);
        expect(pools[0]).toMatchShapeOf(DataMocks.Pool.info);
      });
      it('by real-world cost considering fixed cost and margin when specifying sort by cost asc', async () => {
        const pools = (
          await builder.queryPoolData(hashIds, false, { pagination, sort: { field: 'cost', order: 'asc' } })
        ).map((qR) => {
          const { hashId: _1, updateId: _2, ...poolData } = qR;
          return poolData;
        });

        expect(pools).toHaveLength(3);
        expect(pools[0]).toMatchShapeOf(DataMocks.Pool.info);
      });
    });
    describe('pagination', () => {
      it('with limit', async () => {
        const pools = (await builder.queryPoolData(hashIds, false, { pagination: { limit: 3, startAt: 0 } })).map(
          (qR) => {
            const { hashId, updateId, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools.length).toBeGreaterThan(0);
        expect(pools[0]).toMatchShapeOf(DataMocks.Pool.info);
      });
      it('with startAt', async () => {
        const pools = (await builder.queryPoolData(hashIds, false, { pagination: { limit: 5, startAt: 2 } })).map(
          (qR) => {
            const { hashId, updateId, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools.length).toBeGreaterThan(0);
        expect(pools[0]).toMatchShapeOf(DataMocks.Pool.info);
      });
    });
  });
  describe('getLastEpoch', () => {
    it('getLastEpoch', async () => {
      const lastEpoch = await builder.getLastEpoch();
      expect(lastEpoch).toBeGreaterThan(0);
    });
  });
  describe('buildPoolsByStatusQuery', () => {
    const buildPoolsByStatusQuerySpy = jest.spyOn(builder, 'buildPoolsByStatusQuery');
    afterEach(() => jest.clearAllMocks());
    afterAll(() => buildPoolsByStatusQuerySpy.mockRestore());

    it('activating', async () => {
      const activatingStatus = [Cardano.StakePoolStatus.Activating];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(activatingStatus);

      const _filters: QueryStakePoolsArgs['filters'] = {
        status: activatingStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolHashes).toBeDefined();
    });
    it('active', async () => {
      const activeStatus = [Cardano.StakePoolStatus.Active];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(activeStatus);

      const _filters: QueryStakePoolsArgs['filters'] = {
        status: activeStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolHashes).toBeDefined();
    });
    it('retiring', async () => {
      const retiringStatus = [Cardano.StakePoolStatus.Retiring];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(retiringStatus);

      const _filters: QueryStakePoolsArgs['filters'] = {
        status: retiringStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolHashes).toBeDefined();
    });
    it('retired', async () => {
      const retiredStatus = [Cardano.StakePoolStatus.Retired];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(retiredStatus);

      const _filters: QueryStakePoolsArgs['filters'] = {
        status: retiredStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolHashes).toBeDefined();
    });
    it('active,activating,retiring,retired', async () => {
      const poolStatus = Object.values(Cardano.StakePoolStatus);
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(poolStatus);

      const _filters: QueryStakePoolsArgs['filters'] = {
        status: poolStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolHashes).toBeDefined();
    });
  });
  describe('buildOrQuery', () => {
    it('buildOrQuery, queryPoolHashes & queryTotalCount', async () => {
      const builtQuery = builder.buildOrQuery(filters);
      const { query, params } = builtQuery;
      const poolHashes = await builder.queryPoolHashes(query, params);
      const totalCount = poolHashes.length;
      expect(poolHashes.length).toBeGreaterThan(0);
      expect(totalCount).toBeGreaterThan(0);
    });
  });
  describe('buildAndQuery', () => {
    // TODO: Debug and reenable after Node 8.8 upgrade
    it.skip('buildAndQuery, queryPoolHashes & queryTotalCount', async () => {
      const builtQuery = builder.buildAndQuery(filters);
      const { query, params } = builtQuery;
      const poolHashes = await builder.queryPoolHashes(query, params);
      const totalCount = poolHashes.length;
      expect(poolHashes).toHaveLength(1);
      expect(totalCount).toBeGreaterThan(0);
    });
  });
  describe('queryPoolStats', () => {
    it('returns active, retired and retiring pools count', async () => {
      const result = await builder.queryPoolStats();
      expect(result.qty).toBeDefined();
      expect(result).toMatchShapeOf({ qty: { activating: 0, active: 0, retired: 0, retiring: 0 } });
    });
  });
  describe('queryPoolAPY', () => {
    describe('sort', () => {
      it('by default sort (APY desc)', async () => {
        const result = await builder.queryPoolAPY(hashIds, epochLength);
        expect(result.length).toBeGreaterThan(0);
        expect(result[0].apy).toBeGreaterThan(result[1].apy);
        expect(result[0]).toMatchShapeOf({ apy: 0, hashId: 0 });
      });
      it('by APY asc', async () => {
        const result = await builder.queryPoolAPY(hashIds, epochLength, { sort: { field: 'apy', order: 'asc' } });
        expect(result.length).toBeGreaterThan(0);
        expect(result[0].apy).toBeLessThan(result[1].apy);
        expect(result[0]).toMatchShapeOf({ apy: 0, hashId: 0 });
      });
    });
    describe('pagination', () => {
      it('with limit', async () => {
        const result = await builder.queryPoolAPY(hashIds, epochLength, { pagination: { limit: 1, startAt: 0 } });
        expect(result.length).toBeGreaterThan(0);
        expect(result[0]).toMatchShapeOf({ apy: 0, hashId: 0 });
      });
      it('with startAt', async () => {
        const result = await builder.queryPoolAPY(hashIds, epochLength, { pagination: { limit: 5, startAt: 1 } });
        expect(result.length).toBeGreaterThan(0);
        expect(result[0]).toMatchShapeOf({ apy: 0, hashId: 0 });
      });
    });
  });
});
