import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { assetProviderFactory } from '../../src/factories';
import { logger } from '@cardano-sdk/util-dev';

// Verify environment.
export const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str(),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} })
});

describe('blockfrostAssetProvider', () => {
  test('getAsset', async () => {
    const asset = await (
      await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS, logger)
    ).getAsset({
      assetId: Cardano.AssetId('6b8d07d69639e9413dd637a1a815a7323c69c86abbafb66dbfdb1aa7'),
      extraData: {
        history: true,
        nftMetadata: true,
        tokenMetadata: true
      }
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
