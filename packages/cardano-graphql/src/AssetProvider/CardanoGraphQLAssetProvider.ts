import { Asset, AssetProvider, Cardano, util } from '@cardano-sdk/core';
import { createProvider, getExactlyOneObject } from '../util';

export const createGraphQLAssetProvider = createProvider<AssetProvider>((sdk) => ({
  async getAsset(assetId) {
    const { tokenMetadata, nftMetadata, fingerprint, history, assetName, policy, totalQuantity } = getExactlyOneObject(
      (await sdk.Asset({ assetId: assetId.toString() })).queryAsset?.filter(util.isNotNil),
      'Asset'
    );
    return {
      assetId,
      fingerprint: Cardano.AssetFingerprint(fingerprint),
      history: history.map(({ quantity, transaction: { hash } }) => ({
        quantity: BigInt(quantity),
        transactionId: Cardano.TransactionId(hash)
      })),
      name: Cardano.AssetName(assetName),
      nftMetadata: nftMetadata
        ? {
            description: nftMetadata.descriptions,
            files: nftMetadata.files.map(({ mediaType, name, src }) => ({
              mediaType: Asset.MediaType(mediaType),
              name,
              src: src.map(Asset.Uri)
            })),
            image: nftMetadata.images.map(Asset.Uri),
            mediaType: nftMetadata.mediaType ? Asset.ImageMediaType(nftMetadata.mediaType) : undefined,
            name: nftMetadata.name,
            version: nftMetadata.version
          }
        : undefined,
      policyId: Cardano.PolicyId(policy.id),
      quantity: BigInt(totalQuantity),
      tokenMetadata: tokenMetadata
        ? {
            decimals: tokenMetadata.decimals || undefined,
            desc: tokenMetadata.desc || undefined,
            icon: tokenMetadata.icon || undefined,
            name: tokenMetadata.name,
            ref: tokenMetadata.ref || undefined,
            sizedIcons: tokenMetadata.sizedIcons,
            ticker: tokenMetadata.ticker || undefined,
            url: tokenMetadata.url || undefined,
            version: tokenMetadata.version as Asset.TokenMetadata['version']
          }
        : undefined
    };
  }
}));
