import * as NetworkInfoCacheKey from './keys';
import {
  Cardano,
  CardanoNodeUtil,
  EraSummary,
  NetworkInfoProvider,
  Seconds,
  SlotEpochCalc,
  StakeSummary,
  SupplySummary,
  createSlotEpochCalc
} from '@cardano-sdk/core';
import { DbSyncProvider, DbSyncProviderDependencies, Disposer, EpochMonitor } from '../../util';
import { GenesisData } from '../../types';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../InMemoryCache';
import { Logger } from 'ts-log';
import { NetworkInfoBuilder } from './NetworkInfoBuilder';
import { RunnableModule } from '@cardano-sdk/util';
import { toGenesisParams, toLedgerTip, toProtocolParams, toSupply } from './mappers';
import memoize from 'lodash/memoize.js';

/** Dependencies that are need to create DbSyncNetworkInfoProvider */
export interface NetworkInfoProviderDependencies extends DbSyncProviderDependencies {
  /** The in memory cache engine. */
  cache: DbSyncProviderDependencies['cache'] & {
    db: InMemoryCache;
  };

  /** Monitor the epoch rollover through db polling. */
  epochMonitor: EpochMonitor;

  /** The genesis data loaded from the genesis file. */
  genesisData: GenesisData;
}

export class DbSyncNetworkInfoProvider extends DbSyncProvider(RunnableModule) implements NetworkInfoProvider {
  #logger: Logger;
  #cache: InMemoryCache;
  #currentEpoch: Cardano.EpochNo;
  #currentHash: Cardano.BlockId | undefined;
  #builder: NetworkInfoBuilder;
  #genesisData: GenesisData;
  #epochMonitor: EpochMonitor;
  #epochRolloverDisposer: Disposer;
  #slotEpochCalc: SlotEpochCalc;
  #ledgerTipTtl: Seconds;

  constructor({ cache, cardanoNode, dbPools, epochMonitor, genesisData, logger }: NetworkInfoProviderDependencies) {
    super({ cache, cardanoNode, dbPools, logger }, 'DbSyncNetworkInfoProvider', logger);

    this.#logger = logger;
    this.#cache = cache.db;
    this.#currentEpoch = Cardano.EpochNo(0);
    this.#ledgerTipTtl = Seconds(0);
    this.#epochMonitor = epochMonitor;
    this.#builder = new NetworkInfoBuilder(dbPools.main, logger);
    this.#genesisData = genesisData;
  }

  public async ledgerTip(): Promise<Cardano.Tip> {
    const result = await this.#cache.get(
      NetworkInfoCacheKey.LEDGER_TIP,
      async () => toLedgerTip(await this.#builder.queryLedgerTip()),
      this.#ledgerTipTtl
    );

    // Perform computation only on changed tip
    if (this.#currentHash !== result.hash) {
      this.#currentHash = result.hash;

      const slotEpochCalc = await this.#getSlotEpochCalc();
      const currentEpoch = slotEpochCalc(result.slot);

      // On epoch rollover, invalidate the cache before returning
      if (this.#currentEpoch !== currentEpoch) {
        // The first time, no need to invalidate the cache
        if (this.#currentEpoch !== 0) this.#epochMonitor.onEpoch(currentEpoch);

        this.#currentEpoch = currentEpoch;
      }
    }

    return result;
  }

  public async protocolParameters(): Promise<Cardano.ProtocolParameters> {
    const currentProtocolParams = await this.#builder.queryProtocolParams();
    return toProtocolParams(currentProtocolParams);
  }

  public async genesisParameters(): Promise<Cardano.CompactGenesis> {
    return toGenesisParams(this.#genesisData);
  }

  public async lovelaceSupply(): Promise<SupplySummary> {
    const { maxLovelaceSupply } = this.#genesisData;

    const [circulatingSupply, totalSupply] = await Promise.all([
      this.#cache.get(
        NetworkInfoCacheKey.CIRCULATING_SUPPLY,
        () => this.#builder.queryCirculatingSupply(),
        UNLIMITED_CACHE_TTL
      ),
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
    this.#ledgerTipTtl = await this.#getLedgerTipTtl();
  }

  async shutdownImpl() {
    this.#cache.shutdown();
    this.#epochRolloverDisposer();
  }

  async #getSlotEpochCalc() {
    if (!this.#slotEpochCalc) {
      this.#slotEpochCalc = memoize(createSlotEpochCalc(await this.eraSummaries()));
    }
    return this.#slotEpochCalc;
  }

  async #getLedgerTipTtl(): Promise<Seconds> {
    const genesisParams = await this.genesisParameters();
    return Seconds(genesisParams.slotLength / genesisParams.activeSlotsCoefficient / 20);
  }
}
