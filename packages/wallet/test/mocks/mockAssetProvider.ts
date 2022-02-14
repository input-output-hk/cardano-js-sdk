import { Asset, Cardano } from '@cardano-sdk/core';

export const asset = {
  assetId: Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'),
  fingerprint: Cardano.AssetFingerprint('asset1rjklcrnsdzqp65wjgrg55sy9723kw09mlgvlc3'),
  history: [
    {
      quantity: 1000n,
      transactionId: Cardano.TransactionId('886206542d63b23a047864021fbfccf291d78e47c1e59bd4c75fbc67b248c5e8')
    }
  ],
  name: Cardano.AssetName('54534c41'),
  policyId: Cardano.PolicyId('7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373'),
  quantity: 1000n
} as Asset.AssetInfo;

export const mockAssetProvider = () => ({
  getAsset: jest.fn().mockResolvedValue(asset)
});

export type MockAssetProvider = ReturnType<typeof mockAssetProvider>;
