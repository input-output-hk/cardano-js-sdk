/* eslint-disable unicorn/no-nested-ternary */
import { Asset, AssetProvider, Cardano, GetAssetArgs, GetAssetsArgs } from '@cardano-sdk/core';
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import { blockfrostMetadataToTxMetadata, blockfrostToProviderError, fetchSequentially } from '../../util';
import { replaceNullsWithUndefineds } from '@cardano-sdk/util';

export class BlockfrostAssetProvider extends BlockfrostProvider implements AssetProvider {
  protected async getLastMintedTx(assetId: Cardano.AssetId): Promise<Responses['asset_history'][number] | undefined> {
    const [lastMintedTx] = await fetchSequentially({
      arg: assetId.toString(),
      haveEnoughItems: (items: Responses['asset_history']): boolean => items.length > 0,
      paginationOptions: { order: 'desc' },
      request: this.blockfrost.assetsHistory.bind<BlockFrostAPI['assetsHistory']>(this.blockfrost),
      responseTranslator: (response): Responses['asset_history'] => response.filter((tx) => tx.action === 'minted')
    });

    if (!lastMintedTx) return undefined;
    return lastMintedTx;
  }

  protected async getNftMetadata(
    asset: Pick<Asset.AssetInfo, 'name' | 'policyId'>,
    lastMintedTxHash: string
  ): Promise<Asset.NftMetadata | null> {
    const metadata = await this.blockfrost.txsMetadata(lastMintedTxHash);
    // Not sure if types are correct, missing 'label', but it's present in docs
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const metadatumMap = blockfrostMetadataToTxMetadata(metadata as any);
    return Asset.NftMetadata.fromMetadatum(asset, metadatumMap, console) ?? null;
  }

  protected mapMetadata(
    assetId: Cardano.AssetId,
    offChain: Responses['asset']['metadata']
  ): Asset.TokenMetadata | null {
    const { logo, ...metadata } = { ...offChain };

    if (Object.values(metadata).every((value) => value === undefined || value === null)) return null;

    return {
      ...replaceNullsWithUndefineds(metadata),
      assetId,
      desc: metadata.description,
      // The other type option is any[] - not sure what it means, omitting if no string.
      icon: typeof logo === 'string' ? logo : undefined
    };
  }

  async getAsset({ assetId, extraData }: GetAssetArgs) {
    try {
      const response = await this.blockfrost.assetsById(assetId.toString());
      const name = Cardano.AssetId.getAssetName(assetId);
      const policyId = Cardano.PolicyId(response.policy_id);
      const quantity = BigInt(response.quantity);

      const nftMetadata = async () => {
        let lastMintedTxHash: string = response.initial_mint_tx_hash;
        if (response.mint_or_burn_count > 1) {
          const lastMintedTx = await this.getLastMintedTx(assetId);
          if (lastMintedTx) lastMintedTxHash = lastMintedTx.tx_hash;
        }
        return this.getNftMetadata({ name, policyId }, lastMintedTxHash);
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
        tokenMetadata: extraData?.tokenMetadata ? this.mapMetadata(assetId, response.metadata) : undefined
      };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
  async getAssets({ assetIds, extraData }: GetAssetsArgs) {
    return Promise.all(assetIds.map((assetId) => this.getAsset({ assetId, extraData })));
  }
}
