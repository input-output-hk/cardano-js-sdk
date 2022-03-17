import { ChainFollower } from './ChainFollower';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { DgraphClient } from './DgraphClient';
import { MetadataClient } from '../MetadataClient/MetadataClient';
import { RunnableModule } from '../RunnableModule';
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
  metadata: {
    uri: string;
  };
}

export class Service extends RunnableModule {
  #chainFollower: ChainFollower;
  #dgraphClient: DgraphClient;
  #metadataClient: MetadataClient;

  constructor(public config: ServiceConfig, logger = dummyLogger) {
    super('Service', logger);
    this.#dgraphClient = new DgraphClient(config.dgraph.address, logger);
    this.#metadataClient = new MetadataClient(config.metadata.uri);
    this.#chainFollower = new ChainFollower(
      this.#dgraphClient,
      [createAssetBlockHandler(this.#metadataClient, logger)],
      logger
    );
  }

  async initialize() {
    super.initializeBefore();
    await this.#dgraphClient.initialize(this.config.dgraph.schema);
    await this.#chainFollower.initialize(this.config.ogmios?.connection);
    await this.#metadataClient.initialize();
    super.initializeAfter();
  }

  async startImpl() {
    // Todo: Get most recent point to start sync from
    await this.#chainFollower.start(['origin']);
  }
  // eslint-disable-next-line @typescript-eslint/no-empty-function
  async initializeImpl(): Promise<void> {}
  async shutdownImpl() {
    await this.#chainFollower.shutdown();
  }
}
