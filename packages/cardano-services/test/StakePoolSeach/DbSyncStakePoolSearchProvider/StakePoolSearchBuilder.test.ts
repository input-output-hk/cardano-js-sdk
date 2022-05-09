import { Cardano, StakePoolQueryOptions } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { StakePoolSearchBuilder } from '../../../src';

describe('StakePoolSearchBuilder', () => {
  let dbConnection: Pool;
  let builder: StakePoolSearchBuilder;

  beforeAll(async () => {
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
    builder = new StakePoolSearchBuilder(dbConnection);
  });

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
      const retirements = await builder.queryRetirements([1, 2, 3]);
      expect(retirements).toMatchSnapshot();
    });
  });
  describe('queryRegistrations', () => {
    it('queryRegistrations', async () => {
      const registrations = await builder.queryRegistrations([1, 2, 3]);
      expect(registrations).toMatchSnapshot();
    });
  });
  describe('queryPoolRewards', () => {
    it('queryPoolRewards', async () => {
      const epochRewards = await builder.queryPoolRewards([1, 2, 3]);
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
      const owners = await builder.queryPoolOwners([1, 2, 3]);
      expect(owners).toMatchSnapshot();
    });
  });
  describe('queryPoolMetrics', () => {
    it('queryPoolMetrics', async () => {
      const totalAda = '42021479194505231';
      const metrics = await builder.queryPoolMetrics([1, 2, 3], totalAda);
      expect(metrics).toMatchSnapshot();
    });
  });
  describe('queryPoolData', () => {
    it('queryPoolData', async () => {
      const poolDatas = await builder.queryPoolData([1, 6]);
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
    it('activating', async () => {
      const poolsByStatusQuery = await builder.buildPoolsByStatusQuery([Cardano.StakePoolStatus.Activating]);
      expect(poolsByStatusQuery).toMatchSnapshot();
    });
    it('active', async () => {
      const poolsByStatusQuery = await builder.buildPoolsByStatusQuery([Cardano.StakePoolStatus.Active]);
      expect(poolsByStatusQuery).toMatchSnapshot();
    });
    it('retiring', async () => {
      const poolsByStatusQuery = await builder.buildPoolsByStatusQuery([Cardano.StakePoolStatus.Retiring]);
      expect(poolsByStatusQuery).toMatchSnapshot();
    });
    it('retired', async () => {
      const poolsByStatusQuery = await builder.buildPoolsByStatusQuery([Cardano.StakePoolStatus.Retired]);
      expect(poolsByStatusQuery).toMatchSnapshot();
    });
    it('active,activating,retiring,retired', async () => {
      const poolsByStatusQuery = await builder.buildPoolsByStatusQuery(Object.values(Cardano.StakePoolStatus));
      expect(poolsByStatusQuery).toMatchSnapshot();
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
    it('buildOrQuery & queryPoolHashes', async () => {
      const builtQuery = builder.buildOrQuery(filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(builtQuery).toMatchSnapshot();
      expect(poolHashes).toMatchSnapshot();
    });
  });
  describe('buildAndQuery', () => {
    it('buildAndQuery & queryPoolHashes', async () => {
      const builtQuery = builder.buildAndQuery(filters);
      const poolHashes = await builder.queryPoolHashes(builtQuery.query, builtQuery.params);
      expect(builtQuery).toMatchSnapshot();
      expect(poolHashes).toMatchSnapshot();
    });
  });
});
