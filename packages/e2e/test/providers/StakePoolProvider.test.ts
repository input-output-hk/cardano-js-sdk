/* eslint-disable no-console */
/* eslint-disable sonarjs/cognitive-complexity */
import * as envalid from 'envalid';
import { logger } from '@cardano-sdk/util-dev';
import { stakePoolHttpProvider } from '@cardano-sdk/cardano-services-client';
import type { Cardano, QueryStakePoolsArgs, StakePoolProvider } from '@cardano-sdk/core';

const stringToRegExEqualsTo = (str: string) => `^${str.replace(/[$()*+.?[\\\]^{|}-]/g, '\\$&')}$`;

describe('StakePoolProvider', () => {
  const pagination = { limit: 20, startAt: 0 };

  let notUniqueNameFilter = '';
  let notUniqueTickerFilter = '';
  let provider: StakePoolProvider;
  let pools: Cardano.StakePool[] = [];
  let uniqueNameFilter = '';
  let uniqueTickerFilter = '';

  let poolOther: Cardano.PoolId | null = null;
  let poolWithUniqueTicker: Cardano.PoolId | null = null;

  const threePoolsIds: Cardano.PoolId[] = [];

  const fetchAllPools = async (filters?: QueryStakePoolsArgs['filters'], startAt = 0): Promise<Cardano.StakePool[]> => {
    const result = await provider.queryStakePools({ filters, pagination: { ...pagination, startAt } });

    return result.pageResults.length === 0
      ? result.pageResults
      : [...result.pageResults, ...(await fetchAllPools(filters, startAt + 20))];
  };

  const pickUsefulPoolsForTest = () => {
    const pickedIds: Cardano.PoolId[] = [];
    const poolNames: Record<string, Cardano.PoolId[]> = {};
    const poolTickers: Record<string, Cardano.PoolId[]> = {};

    const pickUniqueNamePool = () => {
      for (const name in poolNames)
        if (poolNames[name].length === 1) {
          uniqueNameFilter = stringToRegExEqualsTo(name);
          pickedIds.push(poolNames[name][0]);

          return;
        }
    };

    const pickUniqueTickerPool = () => {
      for (const ticker in poolTickers)
        if (poolTickers[ticker].length === 1) {
          uniqueTickerFilter = stringToRegExEqualsTo(ticker);
          pickedIds.push((poolWithUniqueTicker = poolTickers[ticker][0]));

          return;
        }
    };

    const pickNotUniqueNamePool = () => {
      for (const name in poolNames)
        if (poolNames[name].length > 1) {
          notUniqueNameFilter = stringToRegExEqualsTo(name);
          pickedIds.push(...poolNames[name]);

          return;
        }
    };

    const pickNotUniqueTickerPool = () => {
      for (const ticker in poolTickers)
        if (poolTickers[ticker].length > 1) {
          notUniqueTickerFilter = stringToRegExEqualsTo(ticker);
          pickedIds.push(...poolTickers[ticker]);

          return;
        }
    };

    const pickAnotherPool = () => {
      for (const pool of pools)
        if (!pickedIds.includes(pool.id)) {
          poolOther = pool.id;

          return;
        }
    };

    // eslint-disable-next-line complexity, unicorn/consistent-function-scoping
    const pickThreePools = () => {
      let poolWithName = false;
      let poolWithoutMetadataFound = false;
      let poolWithoutNameFound = false;

      for (const pool of pools) {
        if (pool.metadata) {
          const { name } = pool.metadata;

          if (name) {
            if (!poolWithName) {
              poolWithName = true;
              threePoolsIds.push(pool.id);
            }
          } else if (!poolWithoutNameFound) {
            poolWithoutNameFound = true;
            threePoolsIds.push(pool.id);
          }
        } else if (!poolWithoutMetadataFound) {
          poolWithoutMetadataFound = true;
          threePoolsIds.push(pool.id);
        }

        if (poolWithName && poolWithoutMetadataFound && poolWithoutNameFound) return;
      }
    };

    for (const pool of pools)
      if (pool.metadata) {
        const { name, ticker } = pool.metadata;

        if (name) {
          if (poolNames[name]) poolNames[name].push(pool.id);
          else poolNames[name] = [pool.id];
        }

        if (ticker) {
          if (poolTickers[ticker]) poolTickers[ticker].push(pool.id);
          else poolTickers[ticker] = [pool.id];
        }
      }

    pickUniqueNamePool();
    pickUniqueTickerPool();
    pickNotUniqueNamePool();
    pickNotUniqueTickerPool();
    pickAnotherPool();
    pickThreePools();
  };

  const query = (filters: QueryStakePoolsArgs['filters'], sort?: QueryStakePoolsArgs['sort']) =>
    provider.queryStakePools({ filters, pagination, sort });

  beforeAll(async () => {
    const env = envalid.cleanEnv(process.env, { STAKE_POOL_PROVIDER_URL: envalid.url() });
    const config = { baseUrl: env.STAKE_POOL_PROVIDER_URL, logger };

    provider = stakePoolHttpProvider(config);
    pools = await fetchAllPools();

    pickUsefulPoolsForTest();
  });

  it('without filters, some pools is found', () => expect(pools.length).toBeGreaterThan(0));

  describe('filters and options', () => {
    describe('identifier filter', () => {
      it('using id as value', async () => {
        if (!poolOther) return console.log("test 'using id as value' can't run because no pools were found");

        const { totalResultCount } = await query({ identifier: { values: [{ id: poolOther }] } });
        expect(totalResultCount).toBe(1);
      });

      it('using unique name as value', async () => {
        if (!uniqueNameFilter)
          return console.log("test 'using name as value' can't run because no pools with name were found");

        const { totalResultCount } = await query({ identifier: { values: [{ name: uniqueNameFilter }] } });
        expect(totalResultCount).toBeGreaterThanOrEqual(1);
      });

      it('using unique ticker as value', async () => {
        if (!uniqueTickerFilter)
          return console.log("test 'using ticker as value' can't run because no pools with ticker were found");

        const { totalResultCount } = await query({ identifier: { values: [{ ticker: uniqueTickerFilter }] } });
        expect(totalResultCount).toBeGreaterThanOrEqual(1);
      });

      it('using id OR unique ticker as value (same pool)', async () => {
        if (!poolWithUniqueTicker || !uniqueTickerFilter)
          return console.log(
            "test 'using id OR ticker as value (same pool)' can't run because no pools with ticker were found"
          );

        const { totalResultCount } = await query({
          identifier: { values: [{ id: poolWithUniqueTicker }, { ticker: uniqueTickerFilter }] }
        });
        expect(totalResultCount).toBeGreaterThanOrEqual(1);
      });

      it('using id OR unique ticker as value (distinct pools)', async () => {
        if (!poolOther || !poolWithUniqueTicker)
          return console.log(
            "test 'using id OR ticker as value (distinct pool)' can't run because no suitable pools were found"
          );

        const { totalResultCount } = await query({
          identifier: { values: [{ id: poolOther }, { ticker: uniqueTickerFilter }] }
        });
        expect(totalResultCount).toBeGreaterThanOrEqual(2);
      });

      it('using id AND unique ticker as value (same pool)', async () => {
        if (!poolWithUniqueTicker)
          return console.log(
            "test 'using id AND ticker as value (same pool)' can't run because no pools with ticker were found"
          );

        const { totalResultCount } = await query({
          identifier: { _condition: 'and', values: [{ id: poolWithUniqueTicker }, { ticker: uniqueTickerFilter }] }
        });
        expect(totalResultCount).toBe(1);
      });

      it('using id AND unique ticker as value (distinct pools)', async () => {
        if (!poolOther || !poolWithUniqueTicker)
          return console.log(
            "test 'using id AND ticker as value (distinct pool)' can't run because no suitable pools were found"
          );

        const { totalResultCount } = await query({
          identifier: { _condition: 'and', values: [{ id: poolOther }, { ticker: uniqueTickerFilter }] }
        });
        expect(totalResultCount).toBe(0);
      });

      it('using not unique name as value', async () => {
        if (!notUniqueNameFilter)
          return console.log("test 'using not unique name as value' can't run because no suitable pools were found");

        const { totalResultCount } = await query({
          identifier: { values: [{ name: notUniqueNameFilter }] }
        });
        expect(totalResultCount).toBeGreaterThan(1);
      });

      it('using not unique ticker as value', async () => {
        if (!notUniqueTickerFilter)
          return console.log("test 'using not unique ticker as value' can't run because no suitable pools were found");

        const { totalResultCount } = await query({
          identifier: { values: [{ ticker: notUniqueTickerFilter }] }
        });
        expect(totalResultCount).toBeGreaterThan(1);
      });

      it('using ids to find pools with or without name or metadata', async () => {
        if (threePoolsIds.length !== 3)
          return console.log(
            "test 'using ids to find pools with or without name or metadata' can't run because no suitable pools were found"
          );

        const { totalResultCount } = await query({
          identifier: { _condition: 'or', values: threePoolsIds.map((id) => ({ id })) }
        });
        expect(totalResultCount).toBe(3);
      });
    });

    describe('pledgeMet filter', () => {
      it('with pledgeMet false', async () => {
        const { pageResults } = await query({ pledgeMet: false });

        for (const pool of pageResults) expect(pool.pledge > pool.metrics!.livePledge).toBeTruthy();
      });

      it('with pledgeMet true', async () => {
        const { pageResults } = await query({ pledgeMet: true });

        for (const pool of pageResults) expect(pool.pledge <= pool.metrics!.livePledge).toBeTruthy();
      });

      it('pools number = meeting pools number + not meeting pools number', async () => {
        const poolsNumber = (await query({})).totalResultCount;
        const meetingPoolsNumber = (await query({ pledgeMet: true })).totalResultCount;
        const notMeetingPoolsNumber = (await query({ pledgeMet: false })).totalResultCount;

        expect(meetingPoolsNumber + notMeetingPoolsNumber).toBe(poolsNumber);
      });
    });

    describe('sort option', () => {
      describe('sort by name', () => {
        let filters: QueryStakePoolsArgs['filters'];
        const poolsId: Cardano.PoolId[] = [];

        beforeAll(() => {
          const names: string[] = [];

          // Pick id for up to 20 pools with not null distinct name
          for (const pool of pools.sort(() => 0.5 - Math.random()))
            if (names.length < 20 && pool.metadata?.name && !names.includes(pool.metadata.name)) {
              names.push(pool.metadata.name);
              poolsId.push(pool.id);
            }

          filters = { identifier: { values: poolsId.map((id) => ({ id })) } };
        });

        it('default sort (ascending sort by name)', async () => {
          if (poolsId.length < 2)
            return console.log(
              "test 'default sort (ascending sort by name)' can't run because no suitable pools were found"
            );

          const { pageResults, totalResultCount } = await query(filters);

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map(({ id }) => id)).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .map(({ id, metadata }) => ({ id, name: metadata!.name }))
              .sort((a, b) => (a.name.toLocaleLowerCase() < b.name.toLocaleLowerCase() ? -1 : 1))
              .map(({ id }) => id)
          );
        });

        it('descending sort by name', async () => {
          if (poolsId.length < 2)
            return console.log("test 'descending sort by name' can't run because no suitable pools were found");

          const { pageResults, totalResultCount } = await query(filters, { field: 'name', order: 'desc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map(({ id }) => id)).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .map(({ id, metadata }) => ({ id, name: metadata!.name }))
              .sort((a, b) => (a.name.toLocaleLowerCase() < b.name.toLocaleLowerCase() ? 1 : -1))
              .map(({ id }) => id)
          );
        });
      });

      describe('sort by cost', () => {
        let filters: QueryStakePoolsArgs['filters'] = {};
        const poolsId: Cardano.PoolId[] = [];

        beforeAll(() => {
          const costs: bigint[] = [];

          // Pick id for up to 20 pools with distinct cost
          for (const pool of pools)
            if (costs.length < 20 && !costs.includes(pool.cost)) {
              costs.push(pool.cost);
              poolsId.push(pool.id);
            }

          filters = { identifier: { values: poolsId.map((id) => ({ id })) } };
        });

        it('ascending sort by cost', async () => {
          if (poolsId.length < 2)
            return console.log("test 'ascending sort by cost' can't run because no suitable pools were found");

          const { pageResults, totalResultCount } = await query(filters, { field: 'cost', order: 'asc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map(({ id }) => id)).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .sort((a, b) => (a.cost < b.cost ? -1 : 1))
              .map(({ id }) => id)
          );
        });

        it('descending sort by cost', async () => {
          if (poolsId.length < 2)
            return console.log("test 'descending sort by cost' can't run because no suitable pools were found");

          const { pageResults, totalResultCount } = await query(filters, { field: 'cost', order: 'desc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map(({ id }) => id)).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .sort((a, b) => (a.cost < b.cost ? 1 : -1))
              .map(({ id }) => id)
          );
        });
      });

      describe('sort by live saturation', () => {
        let filters: QueryStakePoolsArgs['filters'] = {};
        const poolsId: Cardano.PoolId[] = [];

        beforeAll(() => {
          for (const pool of pools) if (poolsId.length < 20) poolsId.push(pool.id);

          filters = { identifier: { values: poolsId.map((id) => ({ id })) } };
        });

        it('ascending sort by live saturation', async () => {
          if (poolsId.length < 2)
            return console.log(
              "test 'ascending sort by live saturation' can't run because no suitable pools were found"
            );
          const { pageResults, totalResultCount } = await query(filters, { field: 'saturation', order: 'asc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map((p) => p.metrics!.saturation)).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .sort((a, b) => (a.metrics!.saturation < b.metrics!.saturation ? -1 : 1))
              .map((p) => p.metrics?.saturation)
          );
        });

        it('descending sort by live saturation', async () => {
          if (poolsId.length < 2)
            return console.log(
              "test 'descending sort by live saturation' can't run because no suitable pools were found"
            );
          const { pageResults, totalResultCount } = await query(filters, { field: 'saturation', order: 'desc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map((p) => p.metrics?.saturation)).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .sort((a, b) => (a.metrics!.saturation > b.metrics!.saturation ? -1 : 1))
              .map((p) => p.metrics?.saturation)
          );
        });
      });

      describe.each(['lastRos', 'ros'] as const)('sort by %s', (field) => {
        let filters: QueryStakePoolsArgs['filters'] = {};
        const poolsId: Cardano.PoolId[] = [];

        beforeAll(() => {
          for (const pool of pools)
            if (poolsId.length < 20 && pool.metrics?.[field] !== undefined && pool.metrics?.[field] > 0)
              poolsId.push(pool.id);

          filters = { identifier: { values: poolsId.map((id) => ({ id })) } };
        });

        it(`ascending sort by ${field}`, async () => {
          if (poolsId.length < 2)
            return console.log(`test 'ascending sort by ${field}' can't run because no suitable pools were found`);

          const { pageResults, totalResultCount } = await query(filters, { field, order: 'asc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map((p) => p.metrics?.[field])).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .sort((a, b) => (a.metrics![field]! < b.metrics![field]! ? -1 : 1))
              .map((p) => p.metrics![field])
          );
        });

        it(`descending sort by ${field}`, async () => {
          if (poolsId.length < 2)
            return console.log(`test 'descending sort by ${field}' can't run because no suitable pools were found`);

          const { pageResults, totalResultCount } = await query(filters, { field, order: 'desc' });

          expect(totalResultCount).toBe(poolsId.length);
          expect(pageResults.map((p) => p.metrics?.[field])).toStrictEqual(
            pools
              .filter(({ id }) => poolsId.includes(id))
              .sort((a, b) => (a.metrics![field]! > b.metrics![field]! ? -1 : 1))
              .map((p) => p.metrics![field])
          );
        });
      });
    });
  });
});
