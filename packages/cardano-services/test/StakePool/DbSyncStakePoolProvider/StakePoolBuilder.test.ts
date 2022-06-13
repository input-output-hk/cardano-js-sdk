/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-unused-vars */
import { Cardano, StakePoolQueryOptions } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { StakePoolBuilder } from '../../../src';

describe('StakePoolBuilder', () => {
  const dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  const builder = new StakePoolBuilder(dbConnection);

  afterAll(async () => {
    await dbConnection.end();
  });

  const filters: StakePoolQueryOptions['filters'] = {
    _condition: 'or',
    identifier: {
      _condition: 'and',
      values: [
        { name: 'CL' },
        { ticker: 'CLIO' },
        { id: Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70') }
      ]
    },
    pledgeMet: true,
    status: Object.values(Cardano.StakePoolStatus)
  };

  describe('queryRetirements', () => {
    it('queryRetirements', async () => {
      const retirements = (await builder.queryRetirements([1, 2, 3])).map((r) => {
        const { hashId, ...rest } = r;
        return rest;
      });
      expect(retirements).toMatchSnapshot();
    });
  });
  describe('queryRegistrations', () => {
    it('queryRegistrations', async () => {
      const registrations = (await builder.queryRegistrations([1, 2, 3])).map((r) => {
        const { hashId, ...rest } = r;
        return rest;
      });
      expect(registrations).toMatchSnapshot();
    });
  });
  describe('queryPoolRewards', () => {
    it('queryPoolRewards', async () => {
      const epochRewards = await builder.queryPoolRewards([1, 6, 15]);
      expect(epochRewards).toHaveLength(3);
      expect(epochRewards).toMatchSnapshot();
    });
  });
  describe('queryPoolRelays', () => {
    it('queryPoolRelays', async () => {
      // todo: change ids
      const relays = await builder.queryPoolRelays([1, 2, 3]);
      expect(relays).toEqual([]);
    });
  });
  describe('queryPoolOwners', () => {
    it('queryPoolOwners', async () => {
      const ownersAddresses = (await builder.queryPoolOwners([1, 2, 3])).map((o) => o.address);
      expect(ownersAddresses).toMatchSnapshot();
    });
  });
  describe('queryPoolMetrics', () => {
    const totalAda = '42021479194505231';
    describe('sort', () => {
      it('by default sort', async () => {
        const metrics = (await builder.queryPoolMetrics([14, 15, 20], totalAda)).map((m) => m.metrics);
        expect(metrics).toHaveLength(3);
        expect(metrics).toMatchSnapshot();
      });
      it('by saturation', async () => {
        const metrics = (
          await builder.queryPoolMetrics([14, 15, 20], totalAda, { sort: { field: 'saturation', order: 'asc' } })
        ).map((m) => m.metrics);
        expect(metrics).toHaveLength(3);
        expect(metrics).toMatchSnapshot();
      });
    });
    describe('pagination', () => {
      it('with limit', async () => {
        const metrics = (
          await builder.queryPoolMetrics([14, 15, 20], totalAda, { pagination: { limit: 2, startAt: 0 } })
        ).map((m) => m.metrics);
        expect(metrics).toHaveLength(2);
        expect(metrics).toMatchSnapshot();
      });
      it('with startAt', async () => {
        const metrics = (
          await builder.queryPoolMetrics([14, 15, 20], totalAda, { pagination: { limit: 3, startAt: 1 } })
        ).map((m) => m.metrics);
        expect(metrics).toHaveLength(2);
        expect(metrics).toMatchSnapshot();
      });
    });
  });
  describe('queryPoolData', () => {
    describe('sort', () => {
      it('by default sort (name asc)', async () => {
        const pools = (await builder.queryPoolData([1, 6, 14, 15, 20])).map((qR) => {
          const { hashId, updateId, ...poolData } = qR;
          return poolData;
        });
        expect(pools).toHaveLength(5);
        expect(pools).toMatchSnapshot();
      });
      it('by name desc', async () => {
        const pools = (await builder.queryPoolData([14, 15, 20], { sort: { field: 'name', order: 'desc' } })).map(
          (qR) => {
            const { hashId: _1, updateId: _2, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools).toHaveLength(3);
        expect(pools).toMatchSnapshot();
      });
      it('by real-world cost considering fixed cost and margin when specifying sort by cost desc', async () => {
        const pools = (await builder.queryPoolData([14, 15, 20], { sort: { field: 'cost', order: 'desc' } })).map(
          (qR) => {
            const { hashId: _1, updateId: _2, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools).toHaveLength(3);
        expect(pools).toMatchSnapshot();
      });
      it('by real-world cost considering fixed cost and margin when specifying sort by cost asc', async () => {
        const pools = (await builder.queryPoolData([14, 15, 20], { sort: { field: 'cost', order: 'asc' } })).map(
          (qR) => {
            const { hashId: _1, updateId: _2, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools).toHaveLength(3);
        expect(pools).toMatchSnapshot();
      });
    });
    describe('pagination', () => {
      it('with limit', async () => {
        const pools = (await builder.queryPoolData([1, 6, 14, 15, 20], { pagination: { limit: 3, startAt: 0 } })).map(
          (qR) => {
            const { hashId, updateId, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools).toHaveLength(3);
        expect(pools).toMatchSnapshot();
      });
      it('with startAt', async () => {
        const pools = (await builder.queryPoolData([1, 6, 14, 15, 20], { pagination: { limit: 5, startAt: 2 } })).map(
          (qR) => {
            const { hashId, updateId, ...poolData } = qR;
            return poolData;
          }
        );
        expect(pools).toHaveLength(3);
        expect(pools).toMatchSnapshot();
      });
    });
  });
  describe('getTotalAmountOfAda', () => {
    it('getTotalAmountOfAda', async () => {
      const totalAdaAmount = await builder.getTotalAmountOfAda();
      expect(totalAdaAmount).toMatchSnapshot();
    });
  });
  describe('getLastEpoch', () => {
    it('getLastEpoch', async () => {
      const lastEpoch = await builder.getLastEpoch();
      expect(lastEpoch).toMatchSnapshot();
    });
  });
  describe('buildPoolsByStatusQuery', () => {
    const buildPoolsByStatusQuerySpy = jest.spyOn(builder, 'buildPoolsByStatusQuery');
    afterEach(() => jest.clearAllMocks());
    afterAll(() => buildPoolsByStatusQuerySpy.mockRestore());

    it('activating', async () => {
      const activatingStatus = [Cardano.StakePoolStatus.Activating];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(activatingStatus);

      const _filters: StakePoolQueryOptions['filters'] = {
        status: activatingStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolsByStatusQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(0);
    });
    it('active', async () => {
      const activeStatus = [Cardano.StakePoolStatus.Active];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(activeStatus);

      const _filters: StakePoolQueryOptions['filters'] = {
        status: activeStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolsByStatusQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(7);
    });
    it('retiring', async () => {
      const retiringStatus = [Cardano.StakePoolStatus.Retiring];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(retiringStatus);

      const _filters: StakePoolQueryOptions['filters'] = {
        status: retiringStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolsByStatusQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(0);
    });
    it('retired', async () => {
      const retiredStatus = [Cardano.StakePoolStatus.Retired];
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(retiredStatus);

      const _filters: StakePoolQueryOptions['filters'] = {
        status: retiredStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolsByStatusQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(2);
    });
    it('active,activating,retiring,retired', async () => {
      const poolStatus = Object.values(Cardano.StakePoolStatus);
      const poolsByStatusQuery = builder.buildPoolsByStatusQuery(poolStatus);

      const _filters: StakePoolQueryOptions['filters'] = {
        status: poolStatus
      };
      const builtQuery = builder.buildOrQuery(_filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(buildPoolsByStatusQuerySpy).toHaveBeenCalledTimes(2);
      expect(buildPoolsByStatusQuerySpy).toHaveReturnedWith(poolsByStatusQuery);
      expect(poolsByStatusQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(9);
    });
  });
  describe('buildPoolsByPledgeMetQuery', () => {
    it('pledgeMet true', async () => {
      const poolsByPledgeQuery = await builder.buildPoolsByPledgeMetQuery(true);
      expect(poolsByPledgeQuery).toMatchSnapshot();
    });
    it('pledgeMet false', async () => {
      const poolsByPledgeQuery = await builder.buildPoolsByPledgeMetQuery(false);
      expect(poolsByPledgeQuery).toMatchSnapshot();
    });
  });
  describe('buildPoolsByIdentifierQuery', () => {
    it('buildPoolsByIdentifierQuery', async () => {
      const poolsByIdentifierQuery = await builder.buildPoolsByIdentifierQuery({
        _condition: 'and',
        values: [
          { name: 'CL' },
          { ticker: 'CLIO' },
          { id: Cardano.PoolId('pool1jcwn98a6rqr7a7yakanm5sz6asx9gfjsr343mus0tsye23wmg70') }
        ]
      });
      expect(poolsByIdentifierQuery).toMatchSnapshot();
    });
  });
  describe('buildOrQuery', () => {
    it('buildOrQuery, queryPoolHashes & queryTotalCount', async () => {
      const builtQuery = builder.buildOrQuery(filters);
      const { query, params } = builtQuery;
      const poolHashes = await builder.queryPoolHashes(query, params);
      const totalCount = await builder.queryTotalCount(query, params);
      expect(builtQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(9);
      expect(totalCount).toMatchSnapshot();
    });
  });
  describe('buildAndQuery', () => {
    it('buildAndQuery, queryPoolHashes & queryTotalCount', async () => {
      const builtQuery = builder.buildAndQuery(filters);
      const { query, params } = builtQuery;
      const poolHashes = await builder.queryPoolHashes(query, params);
      const totalCount = await builder.queryTotalCount(query, params);
      expect(builtQuery).toMatchSnapshot();
      expect(poolHashes).toHaveLength(1);
      expect(totalCount).toMatchSnapshot();
    });
  });
  describe('queryPoolStats', () => {
    it('returns active, retired and retiring pools count', async () => {
      const result = await builder.queryPoolStats();
      expect(result.qty).toBeDefined();
      expect(result).toMatchSnapshot();
    });
  });
  describe('queryPoolAPY', () => {
    describe('sort', () => {
      it('by default sort (APY desc)', async () => {
        const result = await builder.queryPoolAPY([1, 15]);
        expect(result).toHaveLength(2);
        expect(result[0].apy).toBeGreaterThan(result[1].apy);
        expect(result).toMatchSnapshot();
      });
      it('by APY asc', async () => {
        const result = await builder.queryPoolAPY([1, 15], { sort: { field: 'apy', order: 'asc' } });
        expect(result).toHaveLength(2);
        expect(result[0].apy).toBeLessThan(result[1].apy);
        expect(result).toMatchSnapshot();
      });
    });
    describe('pagination', () => {
      it('with limit', async () => {
        const result = await builder.queryPoolAPY([1, 15, 20], { pagination: { limit: 1, startAt: 0 } });
        expect(result).toHaveLength(1);
        expect(result).toMatchSnapshot();
      });
      it('with startAt', async () => {
        const result = await builder.queryPoolAPY([1, 15, 20], { pagination: { limit: 5, startAt: 1 } });
        expect(result).toHaveLength(2);
        expect(result).toMatchSnapshot();
      });
    });
  });
});
