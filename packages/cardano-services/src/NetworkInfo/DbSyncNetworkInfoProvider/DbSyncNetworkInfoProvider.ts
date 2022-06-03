import { DbSyncProvider } from '../../DbSyncProvider';
import { GenesisData } from './types';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../InMemoryCache';
import { Logger, dummyLogger } from 'ts-log';
import { NetworkInfo, NetworkInfoProvider, timeSettingsConfig } from '@cardano-sdk/core';
import { NetworkInfoBuilder } from './NetworkInfoBuilder';
import { NetworkInfoCacheKey } from '.';
import { Pool } from 'pg';
import { Shutdown } from '@cardano-sdk/util';
import { loadGenesisData, toNetworkInfo } from './mappers';
import { pollDbSync } from './utils';

export interface NetworkInfoProviderProps {
  cardanoNodeConfigPath: string;
  dbPollInterval: number;
}
export interface NetworkInfoProviderDependencies {
  db: Pool;
  cache: InMemoryCache;
  logger?: Logger;
}
export class DbSyncNetworkInfoProvider extends DbSyncProvider implements NetworkInfoProvider {
  #logger: Logger;
  #cache: InMemoryCache;
  #builder: NetworkInfoBuilder;
  #genesisDataReady: Promise<GenesisData>;
  #dbPollInterval: number;
  #pollService: Shutdown | null;

  constructor(
    { cardanoNodeConfigPath, dbPollInterval }: NetworkInfoProviderProps,
    { db, cache, logger = dummyLogger }: NetworkInfoProviderDependencies
  ) {
    super(db);
    this.#logger = logger;
    this.#cache = cache;
    this.#builder = new NetworkInfoBuilder(db, logger);
    this.#genesisDataReady = loadGenesisData(cardanoNodeConfigPath);
    this.#dbPollInterval = dbPollInterval;
  }

  public async networkInfo(): Promise<NetworkInfo> {
    const { networkMagic, networkId, maxLovelaceSupply } = await this.#genesisDataReady;
    const timeSettings = timeSettingsConfig[networkMagic];

    this.#logger.debug('About to query network info data');

    const [liveStake, circulatingSupply, activeStake, totalSupply] = await Promise.all([
      this.#cache.get(NetworkInfoCacheKey.LIVE_STAKE, () => this.#builder.queryLiveStake()),
      this.#cache.get(NetworkInfoCacheKey.CIRCULATING_SUPPLY, () => this.#builder.queryCirculatingSupply()),
      this.#cache.get(NetworkInfoCacheKey.ACTIVE_STAKE, () => this.#builder.queryActiveStake(), UNLIMITED_CACHE_TTL),
      this.#cache.get(
        NetworkInfoCacheKey.TOTAL_SUPPLY,
        () => this.#builder.queryTotalSupply(maxLovelaceSupply),
        UNLIMITED_CACHE_TTL
      )
    ]);

    return toNetworkInfo({
      activeStake,
      circulatingSupply,
      liveStake,
      maxLovelaceSupply,
      networkId,
      networkMagic,
      timeSettings,
      totalSupply
    });
  }

  async start(): Promise<void> {
    if (!this.#pollService)
      this.#pollService = pollDbSync(this.#cache, () => this.#builder.queryLatestEpoch(), this.#dbPollInterval);
  }

  async close(): Promise<void> {
    this.#pollService?.shutdown();
    this.#pollService = null;
    this.#cache.shutdown();
  }
}
