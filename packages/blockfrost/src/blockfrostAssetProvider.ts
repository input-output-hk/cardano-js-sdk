/* eslint-disable unicorn/no-nested-ternary */
import { Asset, AssetProvider, Cardano, ProviderUtil, util } from '@cardano-sdk/core';
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Options } from '@blockfrost/blockfrost-js/lib/types';
import { fetchSequentially, toProviderError } from './util';
import { omit } from 'lodash-es';

const mapMetadata = (
  onChain: Responses['asset']['onchain_metadata'],
  offChain: Responses['asset']['metadata']
): Asset.TokenMetadata => {
  const metadata = { ...onChain, ...offChain };
  return {
    ...util.replaceNullsWithUndefineds(omit(metadata, ['logo', 'image'])),
    desc: metadata.description,
    // The other type option is any[] - not sure what it means, omitting if no string.
    icon:
      typeof metadata.logo === 'string'
        ? metadata.logo
        : typeof metadata.image === 'string'
        ? metadata.image
        : undefined
  };
};

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {Options} options BlockFrostAPI options
 * @returns {AssetProvider} WalletProvider
 * @throws ProviderFailure
 */
export const blockfrostAssetProvider = (options: Options): AssetProvider => {
  const blockfrost = new BlockFrostAPI(options);

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

  const getAsset: AssetProvider['getAsset'] = async (assetId) => {
    const response = await blockfrost.assetsById(assetId.toString());
    const name = Asset.util.assetNameFromAssetId(assetId);
    const quantity = BigInt(response.quantity);
    return {
      assetId,
      fingerprint: Cardano.AssetFingerprint(response.fingerprint),
      history:
        response.mint_or_burn_count === 1
          ? [
              {
                quantity,
                transactionId: Cardano.TransactionId(response.initial_mint_tx_hash)
              }
            ]
          : await getAssetHistory(assetId),
      name,
      policyId: Cardano.PolicyId(response.policy_id),
      quantity,
      tokenMetadata: mapMetadata(response.onchain_metadata, response.metadata)
    };
  };

  const providerFunctions: AssetProvider = {
    getAsset
  };

  return ProviderUtil.withProviderErrors(providerFunctions, toProviderError);
};
