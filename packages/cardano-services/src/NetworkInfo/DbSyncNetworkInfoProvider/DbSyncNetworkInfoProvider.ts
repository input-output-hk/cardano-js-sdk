import {
  Cardano,
  CardanoNode,
  NetworkInfoProvider,
  ProtocolParametersRequiredByWallet,
  StakeSummary,
  SupplySummary,
  TimeSettings
} from '@cardano-sdk/core';
import { DbSyncProvider } from '../../DbSyncProvider';
import { GenesisData } from './types';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../InMemoryCache';
import { Logger, dummyLogger } from 'ts-log';
import { NetworkInfoBuilder } from './NetworkInfoBuilder';
import { NetworkInfoCacheKey } from '.';
import { Pool } from 'pg';
import { Shutdown } from '@cardano-sdk/util';
import { epochPollService } from './utils';
import {
  loadGenesisData,
  toGenesisParams,
  toLedgerTip,
  toStake,
  toSupply,
  toTimeSettings,
  toWalletProtocolParams
} from './mappers';

export interface NetworkInfoProviderProps {
  cardanoNodeConfigPath: string;
  epochPollInterval: number;
}
export interface NetworkInfoProviderDependencies {
  db: Pool;
  cache: InMemoryCache;
  logger?: Logger;
  cardanoNode: CardanoNode;
}
export class DbSyncNetworkInfoProvider extends DbSyncProvider implements NetworkInfoProvider {
  #logger: Logger;
  #cache: InMemoryCache;
  #builder: NetworkInfoBuilder;
  #genesisDataReady: Promise<GenesisData>;
  #epochPollInterval: number;
  #epochPollService: Shutdown | null;
  #cardanoNode: CardanoNode;

  constructor(
    { cardanoNodeConfigPath, epochPollInterval }: NetworkInfoProviderProps,
    { db, cache, logger = dummyLogger, cardanoNode }: NetworkInfoProviderDependencies
  ) {
    super(db);
    this.#logger = logger;
    this.#cache = cache;
    this.#builder = new NetworkInfoBuilder(db, logger);
    this.#genesisDataReady = loadGenesisData(cardanoNodeConfigPath);
    this.#epochPollInterval = epochPollInterval;
    this.#cardanoNode = cardanoNode;
  }

  public async ledgerTip(): Promise<Cardano.Tip> {
    const tip = await this.#builder.queryLedgerTip();
    return toLedgerTip(tip);
  }

  public async currentWalletProtocolParameters(): Promise<ProtocolParametersRequiredByWallet> {
    const currentProtocolParams = await this.#builder.queryCurrentWalletProtocolParams();
    return toWalletProtocolParams(currentProtocolParams);
  }

  public async genesisParameters(): Promise<Cardano.CompactGenesis> {
    const genesisData = await this.#genesisDataReady;
    return toGenesisParams(genesisData);
  }

  public async lovelaceSupply(): Promise<SupplySummary> {
    const { maxLovelaceSupply } = await this.#genesisDataReady;

    const [circulatingSupply, totalSupply] = await Promise.all([
      this.#cache.get(NetworkInfoCacheKey.CIRCULATING_SUPPLY, () => this.#builder.queryCirculatingSupply()),
      this.#cache.get(
        NetworkInfoCacheKey.TOTAL_SUPPLY,
        () => this.#builder.queryTotalSupply(maxLovelaceSupply),
        UNLIMITED_CACHE_TTL
      )
    ]);

    return toSupply({ circulatingSupply, totalSupply });
  }

  public async stake(): Promise<StakeSummary> {
    this.#logger.debug('About to query stake data');

    const [liveStake, activeStake] = await Promise.all([
      this.#cache.get(NetworkInfoCacheKey.LIVE_STAKE, () => this.#builder.queryLiveStake()),
      this.#cache.get(NetworkInfoCacheKey.ACTIVE_STAKE, () => this.#builder.queryActiveStake(), UNLIMITED_CACHE_TTL)
    ]);

    return toStake({
      activeStake,
      liveStake
    });
  }

  public async timeSettings(): Promise<TimeSettings[]> {
    return (
      await this.#cache.get(
        NetworkInfoCacheKey.ERA_SUMMARIES,
        () => this.#cardanoNode.eraSummaries(),
        UNLIMITED_CACHE_TTL
      )
    ).map(toTimeSettings);
  }

  async start(): Promise<void> {
    await this.#cardanoNode.initialize();
    if (!this.#epochPollService)
      this.#epochPollService = epochPollService(
        this.#cache,
        () => this.#builder.queryLatestEpoch(),
        this.#epochPollInterval
      );
  }

  async close(): Promise<void> {
    this.#epochPollService?.shutdown();
    this.#epochPollService = null;
    this.#cache.shutdown();
    await this.#cardanoNode.shutdown();
  }
}
