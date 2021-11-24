import { Asset, AssetProvider, Cardano, util } from '@cardano-sdk/core';
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Options } from '@blockfrost/blockfrost-js/lib/types';
import { fetchSequentially, withProviderErrors } from './util';

const mapMetadata = (
  onChain: Responses['asset']['onchain_metadata'],
  offChain: Responses['asset']['metadata']
): Cardano.AssetMetadata => {
  const metadata = { ...onChain, ...offChain };
  return {
    ...util.replaceNullsWithUndefineds(metadata),
    desc: metadata.description,
    // The other type option is any[] - not sure what it means, omitting if no string.
    image: typeof metadata.image === 'string' ? metadata.image : undefined
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

  const getAssetHistory = async (assetId: string): Promise<Cardano.AssetMintOrBurn[]> =>
    fetchSequentially({
      arg: assetId,
      request: blockfrost.assetsHistory,
      responseTranslator: (response): Cardano.AssetMintOrBurn[] =>
        response.map(({ action, amount, tx_hash }) => ({
          action: action === 'minted' ? Cardano.AssetProvisioning.Mint : Cardano.AssetProvisioning.Burn,
          quantity: BigInt(amount),
          transactionId: Cardano.TransactionId(tx_hash)
        }))
    });

  const getAsset: AssetProvider['getAsset'] = async (assetId) => {
    const response = await blockfrost.assetsById(assetId);
    const name = Buffer.from(Asset.util.assetNameFromAssetId(assetId), 'hex').toString('utf-8');
    const quantity = BigInt(response.quantity);
    return {
      assetId,
      fingerprint: response.fingerprint,
      history:
        response.mint_or_burn_count === 1
          ? [
              {
                action: Cardano.AssetProvisioning.Mint,
                quantity,
                transactionId: Cardano.TransactionId(response.initial_mint_tx_hash)
              }
            ]
          : await getAssetHistory(assetId),
      metadata: mapMetadata(response.onchain_metadata, response.metadata),
      name,
      policyId: response.policy_id,
      quantity
    };
  };

  const providerFunctions: AssetProvider = {
    getAsset
  };

  return withProviderErrors(providerFunctions);
};
