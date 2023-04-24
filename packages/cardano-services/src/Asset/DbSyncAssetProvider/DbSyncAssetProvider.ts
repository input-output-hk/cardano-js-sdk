import {
  Asset,
  AssetProvider,
  Cardano,
  GetAssetArgs,
  GetAssetsArgs,
  ProviderError,
  ProviderFailure
} from '@cardano-sdk/core';
import { AssetBuilder } from './AssetBuilder';
import { DbSyncProvider, DbSyncProviderDependencies } from '../../util/DbSyncProvider';
import { NftMetadataService, TokenMetadataService } from '../types';

/**
 * Properties that are need to create DbSyncAssetProvider
 */
export interface DbSyncAssetProviderProps {
  /**
   * Pagination page size limit used for provider methods constraint.
   */
  paginationPageSizeLimit: number;
}

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
 * AssetProvider implementation using {@link NftMetadataService}, {@link TokenMetadataService}
 * and `cardano-db-sync` database as sources
 */
export class DbSyncAssetProvider extends DbSyncProvider() implements AssetProvider {
  #builder: AssetBuilder;
  #dependencies: DbSyncAssetProviderDependencies;
  #paginationPageSizeLimit: number;

  constructor({ paginationPageSizeLimit }: DbSyncAssetProviderProps, dependencies: DbSyncAssetProviderDependencies) {
    const { cache, dbPools, cardanoNode, logger } = dependencies;
    super({ cache, cardanoNode, dbPools, logger });

    this.#builder = new AssetBuilder(dbPools.main, logger);
    this.#dependencies = dependencies;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
  }

  async getAsset({ assetId, extraData }: GetAssetArgs) {
    const assetInfo = await this.getAssetInfo(assetId);

    if (extraData?.history) await this.loadHistory(assetInfo);
    if (extraData?.nftMetadata)
      assetInfo.nftMetadata = await this.#dependencies.ntfMetadataService.getNftMetadata(assetInfo);
    if (extraData?.tokenMetadata) {
      try {
        assetInfo.tokenMetadata = (await this.#dependencies.tokenMetadataService.getTokenMetadata([assetId]))[0];
      } catch (error) {
        if (error instanceof ProviderError && error.reason === ProviderFailure.Unhealthy) {
          this.logger.error(`Failed to fetch token metadata for asset with ${assetId} due to: ${error.message}`);
          assetInfo.tokenMetadata = undefined;
        } else {
          throw error;
        }
      }
    }

    return assetInfo;
  }

  async getAssets({ assetIds, extraData }: GetAssetsArgs) {
    if (assetIds.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `AssetIds count of ${assetIds.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    const assetList: Asset.AssetInfo[] = [];
    let tokenMetadataList: (Asset.TokenMetadata | null | undefined)[] = [];

    if (extraData?.tokenMetadata) {
      try {
        tokenMetadataList = await this.#dependencies.tokenMetadataService.getTokenMetadata(assetIds);
      } catch (error) {
        if (error instanceof ProviderError && error.reason === ProviderFailure.Unhealthy) {
          this.logger.error(`Failed to fetch token metadata for assets ${assetIds} due to: ${error.message}`);
          tokenMetadataList = Array.from({ length: assetIds.length });
        } else {
          throw error;
        }
      }
    }

    for (const assetId of assetIds) {
      const assetInfo = await this.getAssetInfo(assetId);

      if (extraData?.nftMetadata)
        assetInfo.nftMetadata = await this.#dependencies.ntfMetadataService.getNftMetadata(assetInfo);
      if (extraData?.tokenMetadata) assetInfo.tokenMetadata = tokenMetadataList[assetIds.indexOf(assetId)];

      assetList.push(assetInfo);
    }

    return assetList;
  }

  private async loadHistory(assetInfo: Asset.AssetInfo) {
    assetInfo.history = (
      await this.#builder.queryMultiAssetHistory(assetInfo.policyId, assetInfo.name)
    ).map<Asset.AssetMintOrBurn>(({ hash, quantity }) => ({
      quantity: BigInt(quantity),
      transactionId: hash.toString('hex') as unknown as Cardano.TransactionId
    }));
  }

  private async getAssetInfo(assetId: Cardano.AssetId): Promise<Asset.AssetInfo> {
    const name = Asset.util.assetNameFromAssetId(assetId);
    const policyId = Asset.util.policyIdFromAssetId(assetId);
    const multiAsset = await this.#builder.queryMultiAsset(policyId, name);

    if (!multiAsset)
      throw new ProviderError(ProviderFailure.NotFound, undefined, 'No entries found in multi_asset table');

    const fingerprint = multiAsset.fingerprint as unknown as Cardano.AssetFingerprint;
    const supply = BigInt(multiAsset.sum);
    const mintOrBurnCount = Number(multiAsset.count);

    return { assetId, fingerprint, mintOrBurnCount, name, policyId, supply };
  }
}
