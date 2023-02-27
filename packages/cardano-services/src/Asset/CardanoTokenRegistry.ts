import { Asset, Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { InMemoryCache } from '../InMemoryCache';
import { Logger } from 'ts-log';
import { TokenMetadataService } from './types';
import axios, { AxiosInstance } from 'axios';

export const DEFAULT_TOKEN_METADATA_CACHE_TTL = 600;
export const DEFAULT_TOKEN_METADATA_SERVER_URL = 'https://tokens.cardano.org';

interface NumberValue {
  value?: number;
}

interface StringValue {
  value?: string;
}

interface TokenMetadataServiceRecord {
  decimals?: NumberValue;
  description?: StringValue;
  logo?: StringValue;
  name?: StringValue;
  subject?: string;
  ticker?: StringValue;
  url?: StringValue;
}

const propertiesToChange: Record<string, string> = { description: 'desc', logo: 'icon' };
export const toCoreTokenMetadata = (record: TokenMetadataServiceRecord) =>
  Object.fromEntries(
    Object.entries(record)
      .filter(([key]) => ['decimals', 'description', 'logo', 'name', 'ticker', 'url'].includes(key))
      .map(([key, value]) => [propertiesToChange[key] || key, value.value])
  ) as Asset.TokenMetadata;

const toProviderError = (error: unknown, details: string) => {
  if (error instanceof ProviderError) return error;

  const message = error instanceof Error ? `${error.message} ` : '';

  return new ProviderError(ProviderFailure.Unknown, error, `${message}${details}`);
};

/**
 * Configuration options for CardanoTokenRegistry
 */
export interface CardanoTokenRegistryConfiguration {
  /**
   * The cache TTL in seconds. Default: 10 minutes.
   */
  tokenMetadataCacheTTL?: number;

  /**
   * The Cardano Token Registry public API base URL. Default: https://tokens.cardano.org
   */
  tokenMetadataServerUrl?: string;
}

interface CardanoTokenRegistryConfigurationWithRequired extends CardanoTokenRegistryConfiguration {
  tokenMetadataCacheTTL: number;
  tokenMetadataServerUrl: string;
}

/**
 * Dependencies that are need to create CardanoTokenRegistry
 */
export interface CardanoTokenRegistryDependencies {
  /**
   * The cache engine. Default: InMemoryCache with CardanoTokenRegistryConfiguration.cacheTTL as default TTL
   */
  cache?: InMemoryCache;

  /**
   * The logger object
   */
  logger: Logger;
}

/**
 * TokenMetadataService implementation using Cardano Token Registry public API
 */
export class CardanoTokenRegistry implements TokenMetadataService {
  /**
   * The axios client used to retrieve metadata from API
   */
  #axiosClient: AxiosInstance;

  /**
   * The in memory cache engine
   */
  #cache: InMemoryCache;

  /**
   * The logger object
   */
  #logger: Logger;

  constructor({ cache, logger }: CardanoTokenRegistryDependencies, config: CardanoTokenRegistryConfiguration = {}) {
    const defaultConfig: CardanoTokenRegistryConfigurationWithRequired = {
      tokenMetadataCacheTTL: DEFAULT_TOKEN_METADATA_CACHE_TTL,
      tokenMetadataServerUrl: DEFAULT_TOKEN_METADATA_SERVER_URL,
      ...config
    };

    this.#cache = cache || new InMemoryCache(defaultConfig.tokenMetadataCacheTTL);
    this.#axiosClient = axios.create({ baseURL: defaultConfig.tokenMetadataServerUrl });
    this.#logger = logger;
  }

  shutdown() {
    this.#cache.shutdown();
  }

  async getTokenMetadata(assetIds: Cardano.AssetId[]) {
    this.#logger.debug(`Requested asset metadata for "${assetIds}"`);

    const [assetIdsToRequest, tokenMetadata] = this.getTokenMetadataFromCache(assetIds);

    // All metadata was taken from cache
    if (assetIdsToRequest.length === 0) return tokenMetadata;

    this.#logger.debug(`Fetching asset metadata for "${assetIdsToRequest}"`);

    try {
      const response = await this.#axiosClient.post<{ subjects: TokenMetadataServiceRecord[] }>('metadata/query', {
        properties: ['decimals', 'description', 'logo', 'name', 'ticker', 'url'],
        subjects: assetIdsToRequest
      });

      for (const record of response.data.subjects) {
        try {
          const { subject } = record;

          if (subject) {
            const assetId = Cardano.AssetId(subject);
            const metadata = toCoreTokenMetadata(record);

            tokenMetadata[assetIds.indexOf(assetId)] = metadata;
            this.#cache.set(assetId, metadata);
          } else
            throw new ProviderError(
              ProviderFailure.InvalidResponse,
              undefined,
              `Missing 'subject' property in metadata record ${JSON.stringify(record)}`
            );
        } catch (error) {
          throw toProviderError(error, `while evaluating metadata record ${JSON.stringify(record)}`);
        }
      }
    } catch (error) {
      if (axios.isAxiosError(error)) {
        throw new ProviderError(
          ProviderFailure.ConnectionFailure,
          error,
          'CardanoTokenRegistry failed to fetch asset metadata from the token registry server'
        );
      }

      throw error;
    }

    return tokenMetadata;
  }

  getTokenMetadataFromCache(assetIds: Cardano.AssetId[]) {
    const assetIdsToRequest: Cardano.AssetId[] = [];
    // eslint-disable-next-line unicorn/no-new-array
    const cachedTokenMetadata: (Asset.TokenMetadata | null)[] = new Array(assetIds.length).fill(null);

    for (const [i, assetId] of assetIds.entries()) {
      const cachedMetadata = this.#cache.getVal<Asset.TokenMetadata>(assetId);

      if (cachedMetadata) {
        this.#logger.debug(`Using cached asset metadata value for "${assetId}"`);
        cachedTokenMetadata[i] = cachedMetadata;
      } else assetIdsToRequest.push(assetId);
    }

    return [assetIdsToRequest, cachedTokenMetadata] as const;
  }
}
