import { Asset, Cardano } from '@cardano-sdk/core';
import { firstValueFrom } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import type { AssetProvider, GetAssetArgs, GetAssetsArgs, HealthCheckResponse } from '@cardano-sdk/core';
import type { Assets } from '../types.js';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';

export interface AssetProviderContext {
  assetProvider: AssetProvider;
  assetInfo$: Observable<Assets>;
  tx?: Cardano.Tx;
  logger: Logger;
}

const tryCip68NftMetadata = (
  policyId: Cardano.PolicyId,
  name: Cardano.AssetName,
  tx: Cardano.Tx,
  logger: Logger
): Asset.NftMetadata | null => {
  const decoded = Asset.AssetNameLabel.decode(name);

  if (decoded?.label === Asset.AssetNameLabelNum.UserNFT) {
    const referenceAssetId = Cardano.AssetId.fromParts(
      policyId,
      Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.ReferenceNFT)
    );

    // TODO: It is possible that the reference NFT is not in one of the outputs of the transaction and was previously minted. We
    // need a way to find the reference NFT TxOut from the current active UTXO set on the network.
    for (const output of tx.body.outputs) {
      if (output.value.assets?.get(referenceAssetId)) {
        return Asset.NftMetadata.fromPlutusData(output.datum, logger);
      }
    }
  }

  return null;
};

const getNftMetadata = (
  name: Cardano.AssetName,
  policyId: Cardano.PolicyId,
  tx: Cardano.Tx,
  logger: Logger
): Asset.NftMetadata | null => {
  // First, try CIP-68
  let metadata = tryCip68NftMetadata(policyId, name, tx, logger);

  // If metadata is not found, try CIP-25
  if (!metadata) {
    metadata = tx.auxiliaryData?.blob
      ? Asset.NftMetadata.fromMetadatum({ name, policyId }, tx.auxiliaryData.blob, logger)
      : null;
  }

  return metadata;
};

const createAssetInfo = (assetId: Cardano.AssetId, amount: bigint, tx: Cardano.Tx, logger: Logger): Asset.AssetInfo => {
  const name = Cardano.AssetId.getAssetName(assetId);
  const policyId = Cardano.AssetId.getPolicyId(assetId);
  const assetInfo: Asset.AssetInfo = {
    assetId,
    fingerprint: Cardano.AssetFingerprint.fromParts(policyId, name),
    name,
    policyId,
    quantity: amount,
    supply: amount
  };

  assetInfo.nftMetadata = getNftMetadata(name, policyId, tx, logger);

  return assetInfo;
};

const getMintedAssetInfosFromTx = async (tx: Cardano.Tx, logger: Logger): Promise<Asset.AssetInfo[] | null> => {
  const mints = tx.body.mint;

  if (!mints) return null;

  return [...mints.entries()]
    .filter(([_, amount]) => amount > 0)
    .map(([assetId, amount]) => createAssetInfo(assetId, amount, tx, logger));
};

const fetchAssetsFromProvider = async (
  provider: AssetProvider,
  assetIds: Cardano.AssetId[],
  logger: Logger
): Promise<Asset.AssetInfo[]> => {
  const assetsFromProvider: Asset.AssetInfo[] = [];

  // We need to fetch assets one by one because the provider will throw if any of the assets requests to the getAssets endpoint is not found.
  // We want to fetch the ones we can and return a simplified AssetInfo for the ones we can't.
  for (const assetId of assetIds) {
    try {
      const fetchedAsset = await provider.getAsset({
        assetId,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      assetsFromProvider.push(fetchedAsset);
    } catch (error) {
      logger.error(error);
    }
  }

  return assetsFromProvider;
};

const createFallbackAsset = (assetId: Cardano.AssetId): Asset.AssetInfo => {
  const name = Cardano.AssetId.getAssetName(assetId);
  const policyId = Cardano.AssetId.getPolicyId(assetId);
  return {
    assetId,
    fingerprint: Cardano.AssetFingerprint.fromParts(policyId, name),
    name,
    policyId,
    quantity: 0n,
    supply: 0n
  };
};

const mergeAssets = (
  assetIds: Cardano.AssetId[],
  cachedAssetsInfo: Map<Cardano.AssetId, Asset.AssetInfo>,
  assetsFromProvider: Asset.AssetInfo[],
  mintedAssets: Asset.AssetInfo[] | null
): Asset.AssetInfo[] =>
  assetIds.map((assetId) => {
    const asset = cachedAssetsInfo.get(assetId) || assetsFromProvider.find((a) => a.assetId === assetId);
    const mintedAsset = mintedAssets?.find((info) => info.assetId === assetId);

    if (!asset && !mintedAsset) {
      return createFallbackAsset(assetId);
    }

    if (!asset && mintedAsset) {
      return mintedAsset;
    }

    if (asset && mintedAsset) {
      asset.supply += mintedAsset.supply;
      asset.quantity = asset.supply;

      if (mintedAsset.nftMetadata) {
        asset.nftMetadata = mintedAsset.nftMetadata;
      }
    }

    return asset!;
  });

/**
 * Creates a wallet asset provider. This provider will try to first fetch the asset from the local cache (assetInfo$),
 * then from the provider and finally from the transaction if it was minted in the transaction. If the asset can not be found
 * it will return a dummy AssetInfo with both supply and quantity set to 0.
 */
export const createWalletAssetProvider = ({
  assetProvider,
  assetInfo$,
  tx,
  logger
}: AssetProviderContext): AssetProvider => ({
  async getAsset({ assetId }: GetAssetArgs): Promise<Asset.AssetInfo> {
    const mintedAssets = tx ? await getMintedAssetInfosFromTx(tx, logger) : [];
    const cachedAssetsInfo = await firstValueFrom(assetInfo$);

    let asset = cachedAssetsInfo.get(assetId);

    if (!asset) {
      try {
        asset = await assetProvider.getAsset({ assetId, extraData: { nftMetadata: true, tokenMetadata: true } });
      } catch (error) {
        logger.error(error);
      }
    }

    const mintedAsset = mintedAssets?.find((info) => info.assetId === assetId);

    // Let's create dummy AssetInfo for the unresolved asset. This is probably better than throwing as the UI can still present it as regular token.
    if (!asset && !mintedAsset) {
      const name = Cardano.AssetId.getAssetName(assetId);
      const policyId = Cardano.AssetId.getPolicyId(assetId);
      return {
        assetId,
        fingerprint: Cardano.AssetFingerprint.fromParts(policyId, name),
        name,
        policyId,
        quantity: 0n,
        supply: 0n
      };
    }

    if (!asset) return mintedAsset!;

    if (mintedAsset) {
      asset.supply += mintedAsset.supply;

      // We give preference to the metadata in the transaction if preset as this would be the most up to date.
      if (mintedAsset.nftMetadata) {
        asset.nftMetadata = mintedAsset.nftMetadata;
      }
    }

    const cip68NftMetadata = tx ? tryCip68NftMetadata(asset.policyId, asset.name, tx, logger) : null;
    if (cip68NftMetadata) asset.nftMetadata = cip68NftMetadata;

    return asset;
  },

  async getAssets({ assetIds }: GetAssetsArgs): Promise<Asset.AssetInfo[]> {
    const cachedAssetsInfo = await firstValueFrom(assetInfo$);
    const mintedAssets = tx ? await getMintedAssetInfosFromTx(tx, logger) : [];
    const missingAssetIds = assetIds.filter((assetId) => !cachedAssetsInfo.has(assetId));
    const assetsFromProvider = await fetchAssetsFromProvider(assetProvider, missingAssetIds, logger);
    const mergedAssets = mergeAssets(assetIds, cachedAssetsInfo, assetsFromProvider, mintedAssets);

    const assets = mergedAssets.filter(isNotNil);

    if (tx) {
      for (const asset of assets) {
        const cip68NftMetadata = tryCip68NftMetadata(asset.policyId, asset.name, tx, logger);
        if (cip68NftMetadata) asset.nftMetadata = cip68NftMetadata;
      }
    }

    return mergedAssets.filter(isNotNil);
  },

  healthCheck(): Promise<HealthCheckResponse> {
    return assetProvider.healthCheck();
  }
});
