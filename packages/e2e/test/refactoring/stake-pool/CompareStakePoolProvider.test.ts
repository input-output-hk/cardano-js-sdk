import * as envalid from 'envalid';
import { Cardano, QueryStakePoolsArgs, StakePoolProvider } from '@cardano-sdk/core';
import { Pool, PoolClient } from 'pg';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';

const sortRelays = (pool: Cardano.StakePool) =>
  // eslint-disable-next-line complexity, sonarjs/cognitive-complexity
  pool.relays.sort((a, b) => {
    if (a.__typename !== b.__typename) return a.__typename < b.__typename ? -1 : 1;

    if (a.__typename === 'RelayByNameMultihost')
      return (a as Cardano.RelayByNameMultihost).dnsName < (b as Cardano.RelayByNameMultihost).dnsName ? -1 : 1;

    if (a.__typename === 'RelayByName') {
      const A = a as Cardano.RelayByName;
      const B = b as Cardano.RelayByName;

      // eslint-disable-next-line prettier/prettier
      return A.hostname === B.hostname ? (A.port! < B.port! ? -1 : 1) : (A.hostname < B.hostname ? -1 : 1);
    }

    const A = a as Cardano.RelayByAddress;
    const B = b as Cardano.RelayByAddress;

    if (A.ipv4) {
      if (!B.ipv4) return -1;

      if (A.ipv4 !== B.ipv4) return A.ipv4 < B.ipv4 ? -1 : 1;
    } else if (B.ipv4) return 1;

    if (A.ipv6) {
      if (!B.ipv6) return -1;

      if (A.ipv6 !== B.ipv6) return A.ipv6 < B.ipv6 ? -1 : 1;
    } else if (B.ipv6) return 1;

    if (A.port) {
      if (!B.port) return -1;

      if (A.port !== B.port) return B.port - A.port;
    } else if (B.port) return 1;

    return 0;
  });

describe('StakePoolProvider', () => {
  const pagination = { limit: 20, startAt: 0 };

  let client: PoolClient;
  let targetProvider: StakePoolProvider;
  let trustedProvider: StakePoolProvider;

  const asserQuery = async (query: Omit<QueryStakePoolsArgs, 'pagination'>, startAt = 0) => {
    const params = { ...query, pagination: { ...pagination, startAt }, rewardsHistoryLimit: 1000 };
    const [trustedResult, targetResult] = await Promise.all([
      trustedProvider.queryStakePools(params),
      targetProvider.queryStakePools(params)
    ]);

    // eslint-disable-next-line unicorn/no-array-for-each
    trustedResult.pageResults.forEach(sortRelays);
    // eslint-disable-next-line unicorn/no-array-for-each
    targetResult.pageResults.forEach(sortRelays);

    expect(targetResult).toEqual(trustedResult);

    if (trustedResult.pageResults.length > 0) asserQuery(query, startAt + 20);
  };

  const describeTest = (name: string, query: Omit<QueryStakePoolsArgs, 'pagination'>) =>
    describe(name, () => {
      it('sort by apy asc', () => asserQuery({ ...query, sort: { field: 'apy', order: 'asc' } }));
      it('sort by apy desc', () => asserQuery({ ...query, sort: { field: 'apy', order: 'desc' } }));
      it('sort by cost asc', () => asserQuery({ ...query, sort: { field: 'cost', order: 'asc' } }));
      it('sort by cost desc', () => asserQuery({ ...query, sort: { field: 'cost', order: 'desc' } }));
      it('sort by name asc', () => asserQuery({ ...query, sort: { field: 'name', order: 'asc' } }));
      it('sort by name desc', () => asserQuery({ ...query, sort: { field: 'name', order: 'desc' } }));
      it('sort by saturation asc', () => asserQuery({ ...query, sort: { field: 'saturation', order: 'asc' } }));
      it('sort by saturation desc', () => asserQuery({ ...query, sort: { field: 'saturation', order: 'desc' } }));
    });

  beforeAll(async () => {
    const env = envalid.cleanEnv(process.env, {
      DB_SYNC_CONNECTION_STRING: envalid.str(),
      STAKE_POOL_PROVIDER_URL: envalid.url(),
      TRUSTED_STAKE_POOL_PROVIDER_URL: envalid.url()
    });
    const db = new Pool({ connectionString: env.DB_SYNC_CONNECTION_STRING });

    client = await db.connect();

    await client.query(`
BEGIN;
LOCK block IN EXCLUSIVE MODE;
LOCK epoch IN EXCLUSIVE MODE;
LOCK tx IN EXCLUSIVE MODE;
`);

    targetProvider = stakePoolHttpProvider({ baseUrl: env.STAKE_POOL_PROVIDER_URL, logger });
    trustedProvider = stakePoolHttpProvider({ baseUrl: env.TRUSTED_STAKE_POOL_PROVIDER_URL, logger });
  });

  afterAll(async () => {
    await client.query('ROLLBACK;');
    client.release();
  });

  describe('queries result', () => {
    describeTest('base query', {});
    describeTest('with pledgeMet false', { filters: { pledgeMet: false } });
    describeTest('with pledgeMet true', { filters: { pledgeMet: true } });
    describeTest('with status activating', { filters: { status: [Cardano.StakePoolStatus.Activating] } });
    describeTest('with status active', { filters: { status: [Cardano.StakePoolStatus.Active] } });
    describeTest('with status retired', { filters: { status: [Cardano.StakePoolStatus.Retired] } });
    describeTest('with status retiring', { filters: { status: [Cardano.StakePoolStatus.Retiring] } });
    describeTest('with status active or retired', {
      filters: { status: [Cardano.StakePoolStatus.Active, Cardano.StakePoolStatus.Retired] }
    });
    describeTest('with pledgeMet false and status retired', {
      filters: { _condition: 'and', pledgeMet: false, status: [Cardano.StakePoolStatus.Retired] }
    });
    describeTest('with pledgeMet true or status active', {
      filters: { _condition: 'or', pledgeMet: true, status: [Cardano.StakePoolStatus.Active] }
    });
  });
});
