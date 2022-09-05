/* eslint-disable unicorn/no-nested-ternary */
import { Asset, AssetProvider, Cardano, ProviderUtil } from '@cardano-sdk/core';
import { replaceNullsWithUndefineds } from '@cardano-sdk/util';

import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { blockfrostMetadataToTxMetadata, fetchSequentially, healthCheck, toProviderError } from './util';
import omit from 'lodash/omit';

const mapMetadata = (offChain: Responses['asset']['metadata']): Asset.TokenMetadata | null => {
  const metadata = { ...offChain };
  if (Object.values(metadata).every((value) => value === undefined || value === null)) return null;
  return {
    ...replaceNullsWithUndefineds(omit(metadata, ['logo'])),
    desc: metadata.description,
    // The other type option is any[] - not sure what it means, omitting if no string.
    icon: typeof metadata.logo === 'string' ? metadata.logo : undefined
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
  const getAssetHistory = async (assetId: Cardano.AssetId): Promise<Asset.AssetMintOrBurn[]> =>
    fetchSequentially({
      arg: assetId.toString(),
      request: blockfrost.assetsHistory.bind<BlockFrostAPI['assetsHistory']>(blockfrost),
      responseTranslator: (response): Asset.AssetMintOrBurn[] =>
        response.map(({ action, amount, tx_hash }) => ({
          quantity: BigInt(amount) * (action === 'minted' ? 1n : -1n),
          transactionId: Cardano.TransactionId(tx_hash)
        }))
    });

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
    return Asset.util.metadatumToCip25(asset, metadatumMap, console) ?? null;
  };

  const getAsset: AssetProvider['getAsset'] = async ({ assetId, extraData }) => {
    const response = await blockfrost.assetsById(assetId.toString());
    const name = Asset.util.assetNameFromAssetId(assetId);
    const policyId = Cardano.PolicyId(response.policy_id);
    const quantity = BigInt(response.quantity);
    const history = async () =>
      response.mint_or_burn_count === 1
        ? [
            {
              quantity,
              transactionId: Cardano.TransactionId(response.initial_mint_tx_hash)
            }
          ]
        : await getAssetHistory(assetId);

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
      history: extraData?.history ? await history() : undefined,
      mintOrBurnCount: response.mint_or_burn_count,
      name,
      nftMetadata: extraData?.nftMetadata ? await nftMetadata() : undefined,
      policyId,
      quantity,
      tokenMetadata: extraData?.tokenMetadata ? mapMetadata(response.metadata) : undefined
    };
  };

  const providerFunctions: AssetProvider = {
    getAsset,
    healthCheck: healthCheck.bind(undefined, blockfrost)
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
