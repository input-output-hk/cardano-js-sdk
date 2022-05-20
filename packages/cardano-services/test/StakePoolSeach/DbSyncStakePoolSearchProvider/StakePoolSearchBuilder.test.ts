/* eslint-disable @typescript-eslint/no-unused-vars */
import { Cardano, StakePoolQueryOptions } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { StakePoolSearchBuilder } from '../../../src';

describe('StakePoolSearchBuilder', () => {
  const dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  const builder = new StakePoolSearchBuilder(dbConnection);

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
      const epochRewards = (await builder.queryPoolRewards([1, 2, 3])).map((eR) => eR?.epochReward);
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
    it('queryPoolMetrics', async () => {
      const totalAda = '42021479194505231';
      const metrics = (await builder.queryPoolMetrics([1, 2, 3], totalAda)).map((m) => m.metrics);
      expect(metrics).toMatchSnapshot();
    });
  });
  describe('queryPoolData', () => {
    it('queryPoolData', async () => {
      const poolDatas = (await builder.queryPoolData([1, 6])).map((qR) => {
        const { hashId, updateId, ...poolData } = qR;
        return poolData;
      });
      expect(poolDatas).toMatchSnapshot();
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
      expect(poolHashes).toHaveLength(1);
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
      expect(poolHashes).toHaveLength(6);
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
      expect(poolHashes).toHaveLength(1);
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
      expect(poolHashes).toHaveLength(1);
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
});
