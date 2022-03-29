import { ChainFollower } from './ChainFollower';
import { ConnectionConfig, Schema } from '@cardano-ogmios/client';
import { DgraphClient, DgraphClientAddresses } from './DgraphClient';
// import { MetadataClient } from '../MetadataClient/MetadataClient';
import { RunnableModule } from '../RunnableModule';
import { createAssetBlockHandler } from './blockHandlers/AssetBlockHandler';
import { createBlockBlockHandler } from './blockHandlers/BlockBlockHandler';
import { dummyLogger } from 'ts-log';

export interface DataProjectorConfig {
  ogmios?: {
    connection?: ConnectionConfig;
  };
  dgraph: {
    addresses: DgraphClientAddresses;
    schema: string;
  };
  metadata: {
    uri: string;
  };
}

export class DataProjector extends RunnableModule {
  #chainFollower: ChainFollower;
  #dgraphClient: DgraphClient;
  // #metadataClient: MetadataClient;

  constructor(public config: DataProjectorConfig, logger = dummyLogger) {
    super('DataProjector', logger);
    this.#dgraphClient = new DgraphClient(config.dgraph.addresses, logger);
    // this.#metadataClient = new MetadataClient(config.metadata.uri);
    this.#chainFollower = new ChainFollower(
      this.#dgraphClient,
      [createAssetBlockHandler(logger), createBlockBlockHandler(logger)],
      logger
    );
  }

  async initializeImpl() {
    await this.#dgraphClient.initialize(this.config.dgraph.schema);
    await this.#chainFollower.initialize(this.config.ogmios?.connection);
    // await this.#metadataClient.initialize();
  }

  async startImpl() {
    this.logger.info('About to get last block');
    const response = await this.#dgraphClient.getLastBlock();
    const startingPoints: [string | Schema.Point] = ['origin'];
    if (response !== undefined && response?.latestBlock.length > 0) {
      const latestBlock = response.latestBlock[0];
      this.logger.info({ latestBlock }, ' Previous synched point detected ');
      const point = { hash: latestBlock['Block.hash'], slot: latestBlock['Block.slot'].number };
      startingPoints.unshift(point);
    }
    await this.#chainFollower.start(startingPoints);
  }
  async shutdownImpl() {
    await this.#chainFollower.shutdown();
  }
}
