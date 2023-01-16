import { Asset, AssetProvider, Cardano, GetAssetArgs, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { AssetBuilder } from './AssetBuilder';
import { DbSyncProvider, DbSyncProviderDependencies } from '../../util/DbSyncProvider';
import { NftMetadataService, TokenMetadataService } from '../types';

/**
 * Dependencies that are need to create DbSyncAssetProvider
 */
export interface DbSyncAssetProviderDependencies extends DbSyncProviderDependencies {
  /**
   * The NftMetadataService to retrieve Asset.NftMetadata.
   */
  ntfMetadataService: NftMetadataService;
  /**
   * The TokenMetadataService to retrieve Asset.TokenMetadata.
   */
  tokenMetadataService: TokenMetadataService;
}

/**
 * AssetProvider implementation using NftMetadataService, TokenMetadataService
 * and cardano-db-sync database as sources
 */
export class DbSyncAssetProvider extends DbSyncProvider() implements AssetProvider {
  #builder: AssetBuilder;
  #dependencies: DbSyncAssetProviderDependencies;

  constructor(dependencies: DbSyncAssetProviderDependencies) {
    const { db, cardanoNode, logger } = dependencies;
    super({ cardanoNode, db, logger });

    this.#builder = new AssetBuilder(db, logger);
    this.#dependencies = dependencies;
  }

  async getAsset({ assetId, extraData }: GetAssetArgs) {
    const name = Asset.util.assetNameFromAssetId(assetId);
    const policyId = Asset.util.policyIdFromAssetId(assetId);
    const multiAsset = await this.#builder.queryMultiAsset(policyId, name);

    if (!multiAsset)
      throw new ProviderError(ProviderFailure.NotFound, undefined, 'No entries found in multi_asset table');

    const fingerprint = multiAsset.fingerprint as unknown as Cardano.AssetFingerprint;
    const quantities = await this.#builder.queryMultiAssetQuantities(multiAsset.id);
    const quantity = BigInt(quantities.sum);
    const mintOrBurnCount = Number(quantities.count);

    const assetInfo: Asset.AssetInfo = { assetId, fingerprint, mintOrBurnCount, name, policyId, quantity };

    if (extraData?.history) await this.loadHistory(assetInfo);
    if (extraData?.nftMetadata)
      assetInfo.nftMetadata = await this.#dependencies.ntfMetadataService.getNftMetadata(assetInfo);
    if (extraData?.tokenMetadata) {
      try {
        assetInfo.tokenMetadata = (await this.#dependencies.tokenMetadataService.getTokenMetadata([assetId]))[0];
      } catch (error) {
        if (error instanceof ProviderError && error.reason === ProviderFailure.ConnectionFailure) {
          assetInfo.tokenMetadata = undefined;
        } else {
          throw error;
        }
      }
    }

    return assetInfo;
  }

  private async loadHistory(assetInfo: Asset.AssetInfo) {
    assetInfo.history = (
      await this.#builder.queryMultiAssetHistory(assetInfo.policyId, assetInfo.name)
    ).map<Asset.AssetMintOrBurn>(({ hash, quantity }) => ({
      quantity: BigInt(quantity),
      transactionId: hash.toString('hex') as unknown as Cardano.TransactionId
    }));
  }
}
