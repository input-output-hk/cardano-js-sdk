import { ExtendedStakePoolMetadata, ProviderError, ProviderFailure } from '@cardano-sdk/core';

export const fetchExtendedMetadata = (extDataUrl: string): Promise<ExtendedStakePoolMetadata> => {
  throw new ProviderError(ProviderFailure.NotImplemented, null, extDataUrl);
};
