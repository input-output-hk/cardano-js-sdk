import { Cardano, StakePoolSearchProvider } from '@cardano-sdk/core';
import delay from 'delay';

export const somePartialStakePools: Cardano.StakePool[] = [
  {
    epochRewards: [
      {
        activeStake: 1_000_000_000_000n,
        epoch: 123,
        epochLength: 432_000_000,
        memberROI: 0.000_68,
        operatorFees: 340n + 50n,
        totalRewards: 680n
      }
    ],
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
    epochRewards: [],
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

/**
 * Good source for testnet pools: https://testnet.adatools.io/pools
 */
export const createStubStakePoolSearchProvider = (
  stakePools: Cardano.StakePool[] = somePartialStakePools,
  delayMs?: number
): StakePoolSearchProvider => ({
  queryStakePools: async (options) => {
    if (delayMs) await delay(delayMs);
    const identifierFilters = options?.filters?.identifier;
    const filterValues = identifierFilters ? identifierFilters.values : [];
    return stakePools.filter(({ id, metadata }) =>
      filterValues.some(
        (value) =>
          (value.id && id.includes(value.id as unknown as string)) ||
          (value.name && metadata?.name.includes(value.name)) ||
          (value.ticker && metadata?.ticker.includes(value.ticker))
      )
    );
  }
});
