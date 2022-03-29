import { Asset } from '../../../Schema';
import { AssetMetadata } from '../../../MetadataClient/types';
import { Cardano } from '@cardano-sdk/core';
import { Schema, isAlonzoBlock, isMaryBlock } from '@cardano-ogmios/client';

export const getAssetBlockType = (block: Schema.Block) => {
  let b: Schema.BlockMary | Schema.BlockAlonzo | undefined;

  if (isAlonzoBlock(block)) {
    b = block.alonzo as Schema.BlockAlonzo;
  } else if (isMaryBlock(block)) {
    b = block.mary as Schema.BlockMary;
  }
  return b;
};

export const getAssetIdsFromTransaction = (tx: Schema.BlockBodyAlonzo | Schema.BlockBodyMary) => {
  const assetIdList: string[] = [];
  const txBodyMintAssets = tx.body.mint.assets;
  if (txBodyMintAssets) {
    for (const entry of Object.entries(txBodyMintAssets)) {
      const [policyId, assetName] = entry[0].split('.');
      assetIdList.push(`${policyId}${assetName !== undefined ? assetName : ''}`);
    }
  }
  return assetIdList;
};

export const getAssetsFromTransaction = (tx: Schema.BlockBodyAlonzo | Schema.BlockBodyMary) => {
  const assetList: Asset[] = [];
  const txBodyMintAssets = tx.body.mint.assets;
  if (txBodyMintAssets) {
    for (const entry of Object.entries(txBodyMintAssets)) {
      const [policyId, assetName] = entry[0].split('.');
      const assetId = Cardano.AssetId(`${policyId}${assetName !== undefined ? assetName : ''}`);
      const policy = {
        id: Cardano.PolicyId(policyId)
      };
      const asset = {
        assetId,
        assetName: Cardano.AssetName(assetName),
        assetNameUTF8: Buffer.from(assetName, 'hex').toString('utf-8'),
        policy,
        totalQuantity: Number(entry[1])
      };
      assetList.push(asset);
    }
  }
  return assetList;
};

export const mapAsset = (asset: Asset) => ({
  'Asset.assetId': asset.assetId,
  'Asset.assetName': asset.assetName,
  'Asset.assetNameUTF8': asset.assetNameUTF8,
  'Asset.policy': {
    id: asset.policy.id
  },
  'dgraph.type': 'Asset'
});

export const mapAssetMetadata = (serverAssetMetadata: AssetMetadata) => ({
  decimals: serverAssetMetadata.decimals.value,
  desc: serverAssetMetadata.description?.value,
  icon: serverAssetMetadata.logo?.value,
  name: serverAssetMetadata.name?.value,
  ticker: serverAssetMetadata.ticker?.value,
  url: serverAssetMetadata.url?.value
  // Missing fields: sizedIcons
});
