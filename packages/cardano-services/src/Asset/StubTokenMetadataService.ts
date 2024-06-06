import type { Asset, Cardano } from '@cardano-sdk/core';
import type { TokenMetadataService } from './types.js';

export class StubTokenMetadataService implements TokenMetadataService {
  async getTokenMetadata(assetIds: Cardano.AssetId[]): Promise<(Asset.TokenMetadata | null)[]> {
    return assetIds.map(() => null);
  }
  // eslint-disable-next-line @typescript-eslint/no-empty-function
  shutdown(): void {}
}
