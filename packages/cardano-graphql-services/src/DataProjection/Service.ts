import { ChainFollower } from './ChainFollower';
import { ConnectionConfig } from '@cardano-ogmios/client';
import { DgraphClient } from './DgraphClient';
import { MetadataClient } from '../MetadataClient/MetadataClient';
import { RunnableModule } from '../RunnableModule';
import { createAssetBlockHandler } from './blockHandlers/AssetBlockHandler';
import { createBlockBlockHandler } from './blockHandlers/BlockBlockHandler';
import { dummyLogger } from 'ts-log';

export interface DataProjectorConfig {
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

export class DataProjector extends RunnableModule {
  #chainFollower: ChainFollower;
  #dgraphClient: DgraphClient;
  #metadataClient: MetadataClient;

  constructor(public config: DataProjectorConfig, logger = dummyLogger) {
    super('DataProjector', logger);
    this.#dgraphClient = new DgraphClient(config.dgraph.address, logger);
    this.#metadataClient = new MetadataClient(config.metadata.uri);
    this.#chainFollower = new ChainFollower(
      this.#dgraphClient,
      [createAssetBlockHandler(this.#metadataClient, logger), createBlockBlockHandler(logger)],
      logger
    );
  }

  async initializeImpl() {
    await this.#dgraphClient.initialize(this.config.dgraph.schema);
    await this.#chainFollower.initialize(this.config.ogmios?.connection);
    await this.#metadataClient.initialize();
  }

  async startImpl() {
    const latestBlock = await this.#dgraphClient.getLastBlock();
    const point = { hash: latestBlock.hash, slot: latestBlock.slot.number };
    await this.#chainFollower.start([point, 'origin']);
  }
  async shutdownImpl() {
    await this.#chainFollower.shutdown();
  }
}
