import { Asset } from '@cardano-sdk/core';
import { AssetMetadata } from '../../MetadataClient/types';

export const mapMetadata = (serverAssetMetadata: AssetMetadata): Asset.TokenMetadata => ({
  decimals: serverAssetMetadata.decimals.value,
  desc: serverAssetMetadata.description?.value,
  icon: serverAssetMetadata.logo?.value,
  name: serverAssetMetadata.name?.value,
  ticker: serverAssetMetadata.ticker?.value,
  url: serverAssetMetadata.url?.value
  // Missing fields: sizedIcons
});
