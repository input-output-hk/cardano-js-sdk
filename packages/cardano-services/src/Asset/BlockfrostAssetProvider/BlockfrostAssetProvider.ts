/* eslint-disable unicorn/no-nested-ternary */
import { Asset, AssetProvider, Cardano, ProviderUtil } from '@cardano-sdk/core';
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { blockfrostMetadataToTxMetadata, fetchSequentially, healthCheck, toProviderError } from '../../util';
import { replaceNullsWithUndefineds } from '@cardano-sdk/util';

const mapMetadata = (
  assetId: Cardano.AssetId,
  offChain: Responses['asset']['metadata']
): Asset.TokenMetadata | null => {
  const { logo, ...metadata } = { ...offChain };

  if (Object.values(metadata).every((value) => value === undefined || value === null)) return null;

  return {
    ...replaceNullsWithUndefineds(metadata),
    assetId,
    desc: metadata.description,
    // The other type option is any[] - not sure what it means, omitting if no string.
    icon: typeof logo === 'string' ? logo : undefined
  };
};

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {AssetProvider} AssetProvider
 * @throws ProviderFailure
 */
export const blockfrostAssetProvider = (blockfrost: BlockFrostAPI): AssetProvider => {
  const getLastMintedTx = async (assetId: Cardano.AssetId): Promise<Responses['asset_history'][number] | undefined> => {
    const [lastMintedTx] = await fetchSequentially({
      arg: assetId.toString(),
      haveEnoughItems: (items: Responses['asset_history']): boolean => items.length > 0,
      paginationOptions: { order: 'desc' },
      request: blockfrost.assetsHistory.bind<BlockFrostAPI['assetsHistory']>(blockfrost),
      responseTranslator: (response): Responses['asset_history'] => response.filter((tx) => tx.action === 'minted')
    });

    if (!lastMintedTx) return undefined;
    return lastMintedTx;
  };

  const getNftMetadata = async (
    asset: Pick<Asset.AssetInfo, 'name' | 'policyId'>,
    lastMintedTxHash: string
  ): Promise<Asset.NftMetadata | null> => {
    const metadata = await blockfrost.txsMetadata(lastMintedTxHash);
    // Not sure if types are correct, missing 'label', but it's present in docs
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const metadatumMap = blockfrostMetadataToTxMetadata(metadata as any);
    return Asset.NftMetadata.fromMetadatum(asset, metadatumMap, console) ?? null;
  };

  const getAsset: AssetProvider['getAsset'] = async ({ assetId, extraData }) => {
    const response = await blockfrost.assetsById(assetId.toString());
    const name = Cardano.AssetId.getAssetName(assetId);
    const policyId = Cardano.PolicyId(response.policy_id);
    const quantity = BigInt(response.quantity);

    const nftMetadata = async () => {
      let lastMintedTxHash: string = response.initial_mint_tx_hash;
      if (response.mint_or_burn_count > 1) {
        const lastMintedTx = await getLastMintedTx(assetId);
        if (lastMintedTx) lastMintedTxHash = lastMintedTx.tx_hash;
      }
      return getNftMetadata({ name, policyId }, lastMintedTxHash);
    };

    return {
      assetId,
      fingerprint: Cardano.AssetFingerprint(response.fingerprint),
      // history: extraData?.history ? await history() : undefined,
      mintOrBurnCount: response.mint_or_burn_count,
      name,
      nftMetadata: extraData?.nftMetadata ? await nftMetadata() : undefined,
      policyId,
      quantity,
      supply: quantity,
      tokenMetadata: extraData?.tokenMetadata ? mapMetadata(assetId, response.metadata) : undefined
    };
  };

  const getAssets: AssetProvider['getAssets'] = async ({ assetIds, extraData }) =>
    Promise.all(assetIds.map((assetId) => getAsset({ assetId, extraData })));

  const providerFunctions: AssetProvider = {
    getAsset,
    getAssets,
    healthCheck: healthCheck.bind(undefined, blockfrost)
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
