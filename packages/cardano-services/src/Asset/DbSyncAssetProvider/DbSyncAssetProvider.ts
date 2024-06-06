import { AssetBuilder } from './AssetBuilder.js';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { DB_CACHE_TTL_DEFAULT, InMemoryCache, NoCache } from '../../InMemoryCache/index.js';
import { DbSyncProvider } from '../../util/index.js';
import type { Asset, AssetProvider, GetAssetArgs, GetAssetsArgs, Seconds } from '@cardano-sdk/core';
import type { AssetPolicyIdAndName, NftMetadataService, TokenMetadataService } from '../types.js';
import type { DbSyncProviderDependencies } from '../../util/index.js';

/** Properties that are need to create DbSyncAssetProvider */
export interface DbSyncAssetProviderProps {
  /** Pagination page size limit used for provider methods constraint. */
  paginationPageSizeLimit: number;
  /** Cache TTL in seconds, defaults to 2 hours */
  cacheTTL?: Seconds;
  /** Does not use in-memory cache if `true` */
  disableDbCache?: boolean;
}

/** Dependencies that are need to create DbSyncAssetProvider */
export interface DbSyncAssetProviderDependencies extends DbSyncProviderDependencies {
  /** The NftMetadataService to retrieve Asset.NftMetadata. */
  ntfMetadataService: NftMetadataService;
  /** The TokenMetadataService to retrieve Asset.TokenMetadata. */
  tokenMetadataService: TokenMetadataService;
}

const nftMetadataCacheKey = (assetId: Cardano.AssetId) => `nm_${assetId.toString()}`;
const assetInfoCacheKey = (assetId: Cardano.AssetId) => `ai_${assetId.toString()}`;

/**
 * AssetProvider implementation using {@link NftMetadataService}, {@link TokenMetadataService}
 * and `cardano-db-sync` database as sources
 */
export class DbSyncAssetProvider extends DbSyncProvider() implements AssetProvider {
  #builder: AssetBuilder;
  #dependencies: DbSyncAssetProviderDependencies;
  #paginationPageSizeLimit: number;
  #cache: InMemoryCache;

  constructor(
    { paginationPageSizeLimit, disableDbCache, cacheTTL = DB_CACHE_TTL_DEFAULT }: DbSyncAssetProviderProps,
    dependencies: DbSyncAssetProviderDependencies
  ) {
    const { cache, dbPools, cardanoNode, logger } = dependencies;
    super({ cache, cardanoNode, dbPools, logger });

    this.#builder = new AssetBuilder(dbPools.main, logger);
    this.#dependencies = dependencies;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
    this.#cache = disableDbCache ? new NoCache() : new InMemoryCache(cacheTTL);
  }

  async getAsset({ assetId, extraData }: GetAssetArgs) {
    const assetInfo = await this.#getAssetInfo(assetId);

    if (extraData?.nftMetadata) assetInfo.nftMetadata = await this.#getNftMetadata(assetInfo);
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

    const fetchTokenMetadataList = async () => {
      let tokenMetadataList: (Asset.TokenMetadata | null | undefined)[] = [];

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

      return tokenMetadataList;
    };

    const tokenMetadataListPromise = extraData?.tokenMetadata ? fetchTokenMetadataList() : undefined;

    const getAssetInfo = async (assetId: Cardano.AssetId) => {
      const assetInfo = await this.#getAssetInfo(assetId);

      if (extraData?.nftMetadata) assetInfo.nftMetadata = await this.#getNftMetadata(assetInfo);
      if (tokenMetadataListPromise)
        assetInfo.tokenMetadata = (await tokenMetadataListPromise)[assetIds.indexOf(assetId)];

      return assetInfo;
    };

    return Promise.all(assetIds.map((_) => getAssetInfo(_)));
  }

  async #getNftMetadata(asset: AssetPolicyIdAndName): Promise<Asset.NftMetadata | null> {
    return this.#cache.get(
      nftMetadataCacheKey(Cardano.AssetId.fromParts(asset.policyId, asset.name)),
      async () => await this.#dependencies.ntfMetadataService.getNftMetadata(asset)
    );
  }

  async #getAssetInfo(assetId: Cardano.AssetId): Promise<Asset.AssetInfo> {
    return this.#cache.get(assetInfoCacheKey(assetId), async () => {
      const name = Cardano.AssetId.getAssetName(assetId);
      const policyId = Cardano.AssetId.getPolicyId(assetId);
      const multiAsset = await this.#builder.queryMultiAsset(policyId, name);

      if (!multiAsset)
        throw new ProviderError(
          ProviderFailure.NotFound,
          undefined,
          `No entries found in multi_asset table for asset '${assetId}'`
        );

      const fingerprint = multiAsset.fingerprint as unknown as Cardano.AssetFingerprint;
      const supply = BigInt(multiAsset.sum);
      // Backwards compatibility
      const quantity = supply;

      return { assetId, fingerprint, name, policyId, quantity, supply };
    });
  }
}
