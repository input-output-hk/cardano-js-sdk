import { Cardano } from '@cardano-sdk/core';

export const asset = {
  assetId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41',
  fingerprint: 'asset...',
  history: [{ action: Cardano.AssetProvisioning.Mint, quantity: 1000n, transactionId: 'some-tx-id...' }],
  name: 'TSLA',
  policyId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
  quantity: 1000n
} as Cardano.Asset;

export const mockAssetProvider = () => ({
  getAsset: jest.fn().mockResolvedValue(asset)
});

export type MockAssetProvider = ReturnType<typeof mockAssetProvider>;
