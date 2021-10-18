import { ProviderError, ProviderFailure, StakePool } from '@cardano-sdk/core';

export const queryStakePoolsWithMetadata = (fragments: string[]): Promise<StakePool[]> => {
  throw new ProviderError(ProviderFailure.NotImplemented, null, fragments.join(', '));
};
