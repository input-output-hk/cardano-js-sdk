import { Cardano } from '@cardano-sdk/core';
import { handleAssetId, handleAssetName, handleFingerprint, handlePolicyId } from './mockData.js';
import type { Asset } from '@cardano-sdk/core';

export const asset: Asset.AssetInfo = {
  assetId: Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'),
  fingerprint: Cardano.AssetFingerprint('asset1rjklcrnsdzqp65wjgrg55sy9723kw09mlgvlc3'),
  name: Cardano.AssetName('54534c41'),
  nftMetadata: null,
  policyId: Cardano.PolicyId('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373'),
  quantity: 1000n,
  supply: 1000n,
  tokenMetadata: null
};

export const handleAssetInfo: Asset.AssetInfo = {
  assetId: handleAssetId,
  fingerprint: handleFingerprint,
  name: handleAssetName,
  policyId: handlePolicyId,
  quantity: 1n,
  supply: 1n
};

export const mockAssetProvider = () => ({
  getAsset: jest.fn().mockResolvedValue(asset),
  getAssets: jest
    .fn()
    .mockImplementation(async ({ assetIds }) =>
      assetIds.map((assetId: Cardano.AssetId) => (assetId === handleAssetId ? handleAssetInfo : asset))
    ),
  healthCheck: jest.fn().mockResolvedValue({ ok: true })
});

export type MockAssetProvider = ReturnType<typeof mockAssetProvider>;
