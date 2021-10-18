import { StakePool, StakePoolSearchProvider } from '@cardano-sdk/core';
import { fetchExtendedMetadata } from './fetchExtendedMetadata';
import { queryStakePoolsWithMetadata } from './queryStakePoolsWithMetadata';

export class CardanoGraphQLStakePoolSearchProvider implements StakePoolSearchProvider {
  async queryStakePools(fragments: string[], fetchExt?: boolean | undefined): Promise<StakePool[]> {
    const stakePools = await queryStakePoolsWithMetadata(fragments);
    if (!fetchExt) return stakePools;
    return Promise.all(
      stakePools.map(async (stakePool) => {
        if (stakePool.metadata?.extDataUrl) {
          return {
            ...stakePool,
            metadata: {
              ...stakePool.metadata,
              ext: await fetchExtendedMetadata(stakePool.metadata.extDataUrl)
            }
          };
        }
        return stakePool;
      })
    );
  }
}
