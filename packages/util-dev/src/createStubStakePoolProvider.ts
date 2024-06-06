import { Cardano } from '@cardano-sdk/core';
import delay from 'delay';
import type { StakePoolProvider } from '@cardano-sdk/core';

export const somePartialStakePools: Cardano.StakePool[] = [
  {
    hexId: Cardano.PoolIdHex('cf12a9dcaacdc09778616d60502011a88ed4542c482f2ddd08d8ac5a'),
    id: Cardano.PoolId('pool1euf2nh92ehqfw7rpd4s9qgq34z8dg4pvfqhjmhggmzk95gcd402'),
    metadata: {
      description: 'Keiths Pi test pool',
      homepage: '',
      name: 'Keiths PiTest',
      ticker: 'KPIT'
    }
  },
  {
    hexId: Cardano.PoolIdHex('4a2e3b7f4a78ff1452b91329a7673c77c98ca96dece7b55c37869502'),
    id: Cardano.PoolId('pool1fghrkl620rl3g54ezv56weeuwlyce2tdannm2hphs62syf3vyyh'),
    metadata: {
      description: 'VEGAS TestNet(2) ADA Pool',
      homepage: 'https://www.ada.vegas',
      name: 'VEGASPool',
      ticker: 'VEGA2'
    }
  }
] as Cardano.StakePool[];

/** Good source for testnet pools: https://testnet.adatools.io/pools */
export const createStubStakePoolProvider = (
  stakePools: Cardano.StakePool[] = somePartialStakePools,
  delayMs?: number
): StakePoolProvider => ({
  healthCheck: async () => {
    if (delayMs) await delay(delayMs);
    return { ok: true };
  },
  queryStakePools: async (options) => {
    if (delayMs) await delay(delayMs);
    const identifierFilters = options?.filters?.identifier;
    const textSearchValue = options?.filters?.text;
    const filterValues = identifierFilters ? identifierFilters.values : [];
    const pageResults = stakePools.filter(
      ({ id, metadata }) =>
        (textSearchValue && metadata?.name.includes(textSearchValue)) ||
        (textSearchValue && metadata?.ticker.includes(textSearchValue)) ||
        filterValues.some(
          (value) =>
            (value.id && id.includes(value.id)) ||
            (value.name && metadata?.name.includes(value.name)) ||
            (value.ticker && metadata?.ticker.includes(value.ticker))
        )
    );
    return {
      pageResults,
      totalResultCount: pageResults.length
    };
  },
  stakePoolStats: async () => {
    if (delayMs) await delay(delayMs);
    return {
      qty: {
        activating: 0,
        active: stakePools.filter((pool) => pool.status === Cardano.StakePoolStatus.Active).length,
        retired: stakePools.filter((pool) => pool.status === Cardano.StakePoolStatus.Retired).length,
        retiring: stakePools.filter((pool) => pool.status === Cardano.StakePoolStatus.Retiring).length
      }
    };
  }
});
