import { ChainFollower } from './ChainFollower';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { DgraphClient } from './DgraphClient';
import { RunnableModule } from './RunnableModule';
import { createAssetBlockHandler } from './blockHandlers/AssetBlockHandler';
import { dummyLogger } from 'ts-log';

export interface ServiceConfig {
  ogmios?: {
    connection?: ConnectionConfig;
  };
  dgraph: {
    address: string;
    schema: string;
  };
}

export class Service extends RunnableModule {
  #chainFollower: ChainFollower;
  #dgraphClient: DgraphClient;

  constructor(public config: ServiceConfig, logger = dummyLogger) {
    super('Service', logger);
    this.#dgraphClient = new DgraphClient(config.dgraph.address, logger);
    this.#chainFollower = new ChainFollower(this.#dgraphClient, [createAssetBlockHandler(logger)], logger);
  }

  async initialize() {
    super.initializeBefore();
    await this.#dgraphClient.initialize(this.config.dgraph.schema);
    await this.#chainFollower.initialize(this.config.ogmios?.connection);
    super.initializeAfter();
  }

  async start() {
    super.startBefore();
    // Todo: Get most recent point to start sync from
    await this.#chainFollower.start(['origin']);
    super.startAfter();
  }

  async shutdown() {
    super.shutdownBefore();
    await this.#chainFollower.shutdown();
    super.shutdownAfter();
  }
}
