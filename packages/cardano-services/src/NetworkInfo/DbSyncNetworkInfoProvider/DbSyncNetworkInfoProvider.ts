import {
  Cardano,
  CardanoNode,
  CardanoNodeUtil,
  EraSummary,
  NetworkInfoProvider,
  StakeSummary,
  SupplySummary
} from '@cardano-sdk/core';
import { DbSyncProvider } from '../../util/DbSyncProvider';
import { Disposer, EpochMonitor } from '../../util/polling/types';
import { GenesisData } from './types';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../InMemoryCache';
import { Logger } from 'ts-log';
import { NetworkInfoBuilder } from './NetworkInfoBuilder';
import { NetworkInfoCacheKey } from '.';
import { Pool } from 'pg';
import { RunnableModule } from '@cardano-sdk/util';
import { loadGenesisData, toGenesisParams, toLedgerTip, toProtocolParams, toSupply } from './mappers';

export interface NetworkInfoProviderProps {
  cardanoNodeConfigPath: string;
}
export interface NetworkInfoProviderDependencies {
  db: Pool;
  cache: InMemoryCache;
  logger: Logger;
  cardanoNode: CardanoNode;
  epochMonitor: EpochMonitor;
}
export class DbSyncNetworkInfoProvider extends DbSyncProvider(RunnableModule) implements NetworkInfoProvider {
  #logger: Logger;
  #cache: InMemoryCache;
  #builder: NetworkInfoBuilder;
  #genesisDataReady: Promise<GenesisData>;
  #epochMonitor: EpochMonitor;
  #epochRolloverDisposer: Disposer;

  constructor(
    { cardanoNodeConfigPath }: NetworkInfoProviderProps,
    { db, cache, logger, cardanoNode, epochMonitor }: NetworkInfoProviderDependencies
  ) {
    super(db, cardanoNode, 'DbSyncNetworkInfoProvider', logger);
    this.#logger = logger;
    this.#cache = cache;
    this.#epochMonitor = epochMonitor;
    this.#builder = new NetworkInfoBuilder(db, logger);
    this.#genesisDataReady = loadGenesisData(cardanoNodeConfigPath);
  }

  public async ledgerTip(): Promise<Cardano.Tip> {
    const tip = await this.#builder.queryLedgerTip();
    return toLedgerTip(tip);
  }

  public async protocolParameters(): Promise<Cardano.ProtocolParameters> {
    const currentProtocolParams = await this.#builder.queryProtocolParams();
    return toProtocolParams(currentProtocolParams);
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

    const [live, activeStake] = await Promise.all([
      this.#cache.get(NetworkInfoCacheKey.LIVE_STAKE, () =>
        this.cardanoNode.stakeDistribution().then(CardanoNodeUtil.toLiveStake)
      ),
      this.#cache.get(NetworkInfoCacheKey.ACTIVE_STAKE, () => this.#builder.queryActiveStake(), UNLIMITED_CACHE_TTL)
    ]);

    return {
      active: BigInt(activeStake),
      live
    };
  }

  public async eraSummaries(): Promise<EraSummary[]> {
    return await this.#cache.get(
      NetworkInfoCacheKey.ERA_SUMMARIES,
      () => this.cardanoNode.eraSummaries(),
      UNLIMITED_CACHE_TTL
    );
  }

  async initializeImpl() {
    return Promise.resolve();
  }

  async startImpl() {
    this.#epochRolloverDisposer = this.#epochMonitor.onEpochRollover(() => this.#cache.clear());
  }

  async shutdownImpl() {
    this.#cache.shutdown();
    await this.#genesisDataReady;
    this.#epochRolloverDisposer();
  }
}
