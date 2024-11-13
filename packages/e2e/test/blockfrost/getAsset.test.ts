import { Cardano } from '@cardano-sdk/core';
import { assetProviderFactory, getEnv, walletVariables } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

describe('BlockfrostAssetProvider', () => {
  beforeAll(() => {
    if (env.TEST_CLIENT_ASSET_PROVIDER !== 'blockfrost')
      throw new Error('TEST_CLIENT_ASSET_PROVIDER must be "blockfrost" to run these tests');
  });

  test('getAsset', async () => {
    const assetProvider = await assetProviderFactory.create(
      'blockfrost',
      env.TEST_CLIENT_ASSET_PROVIDER_PARAMS,
      logger
    );
    const asset = await assetProvider.getAsset({
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
