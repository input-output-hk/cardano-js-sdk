import { StakePoolSearchProvider } from '@cardano-sdk/core';
import { StakePool } from '@cardano-sdk/core/src/Cardano';
import delay from 'delay';

export const somePartialStakePools: StakePool[] = [
  {
    id: 'pool1euf2nh92ehqfw7rpd4s9qgq34z8dg4pvfqhjmhggmzk95gcd402',
    hexId: 'cf12a9dcaacdc09778616d60502011a88ed4542c482f2ddd08d8ac5a',
    metadata: {
      name: 'Keiths PiTest',
      description: 'Keiths Pi test pool',
      ticker: 'KPIT',
      homepage: ''
    }
  },
  {
    id: 'pool1fghrkl620rl3g54ezv56weeuwlyce2tdannm2hphs62syf3vyyh',
    hexId: '4a2e3b7f4a78ff1452b91329a7673c77c98ca96dece7b55c37869502',
    metadata: {
      name: 'VEGASPool',
      description: 'VEGAS TestNet(2) ADA Pool',
      ticker: 'VEGA2',
      homepage: 'https://www.ada.vegas'
    }
  }
] as StakePool[];

/**
 * Good source for testnet pools: https://testnet.adatools.io/pools
 */
export const createStubStakePoolSearchProvider = (
  stakePools: StakePool[] = somePartialStakePools,
  delayMs?: number
): StakePoolSearchProvider => ({
  queryStakePools: async (fragments) => {
    if (delayMs) await delay(delayMs);
    return stakePools.filter(({ id, metadata }) =>
      fragments.some(
        (fragment) => id.includes(fragment) || metadata?.name.includes(fragment) || metadata?.ticker.includes(fragment)
      )
    );
  }
});
