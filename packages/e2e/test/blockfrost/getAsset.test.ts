import { Cardano } from '@cardano-sdk/core';
import { assetProvider } from '../config';

describe('blockfrostAssetProvider', () => {
  test('getAsset', async () => {
    const asset = await (
      await assetProvider
    ).getAsset(Cardano.AssetId('6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7'), {
      history: true,
      nftMetadata: true,
      tokenMetadata: true
    });
    expect(typeof asset.assetId).toBe('string');
    expect(typeof asset.fingerprint).toBe('string');
    expect(asset.history!.length).toBeGreaterThan(1);
    expect(typeof asset.history![0].quantity).toBe('bigint');
    expect(typeof asset.history![0].transactionId).toBe('string');
    expect(typeof asset.tokenMetadata).toBe('object');
    expect(typeof asset.tokenMetadata!.ticker).toBe('string');
    expect(typeof asset.name).toBe('string');
    expect(typeof asset.policyId).toBe('string');
    expect(typeof asset.quantity).toBe('bigint');
  });
});
