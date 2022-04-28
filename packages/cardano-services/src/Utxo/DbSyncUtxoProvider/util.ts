import { Cardano } from '@cardano-sdk/core';

export const generateAssetId = (policy: string, name: string) => Cardano.AssetId(policy + name);
