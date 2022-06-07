import { DbSyncProvider } from '../../DbSyncProvider';
import { GenesisData } from './types';
import { Logger, dummyLogger } from 'ts-log';
import { NetworkInfo, NetworkInfoProvider, timeSettingsConfig } from '@cardano-sdk/core';
import { NetworkInfoBuilder } from './NetworkInfoBuilder';
import { Pool } from 'pg';
import { loadGenesisData, toNetworkInfo } from './mappers';

export class DbSyncNetworkInfoProvider extends DbSyncProvider implements NetworkInfoProvider {
  #logger: Logger;
  #builder: NetworkInfoBuilder;
  #genesisDataReady: Promise<GenesisData>;

  constructor(cardanoNodeConfigPath: string, db: Pool, logger = dummyLogger) {
    super(db);
    this.#logger = logger;
    this.#builder = new NetworkInfoBuilder(db, logger);
    this.#genesisDataReady = loadGenesisData(cardanoNodeConfigPath);
  }

  public async networkInfo(): Promise<NetworkInfo> {
    const { networkMagic, networkId, maxLovelaceSupply } = await this.#genesisDataReady;
    const timeSettings = timeSettingsConfig[networkMagic];

    this.#logger.debug('About to query network info data');

    const [totalSupply, circulatingSupply, activeStake, liveStake] = await Promise.all([
      this.#builder.queryTotalSupply(maxLovelaceSupply),
      this.#builder.queryCirculatingSupply(),
      this.#builder.queryActiveStake(),
      this.#builder.queryLiveStake()
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
}
