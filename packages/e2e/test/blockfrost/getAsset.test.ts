import * as envalid from 'envalid';
import { Cardano } from '@cardano-sdk/core';
import { assetProviderFactory } from '../../src';
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
      assetId: Cardano.AssetId(
        'b27160f0c50a9cf168bf945dcbfcabbfbee5c7a801e7b467093b41534d6574616c4d6f6e7374657230303036'
      ),
      extraData: {
        nftMetadata: true,
        tokenMetadata: true
      }
    });
    expect(asset.fingerprint).toEqual('asset1atvdgwr4xymq0d3jm90zzjzdywr9smj6h9qxsx');
    expect(asset.name).toEqual('4d6574616c4d6f6e7374657230303036');
    expect(asset.nftMetadata).toBeDefined();
    expect(asset.nftMetadata?.image).toEqual('ipfs://QmcMBRFL5DdHbtDjaz5DHqSWgP7QkikRhdC4VPXu2m7qih');
  });
});
