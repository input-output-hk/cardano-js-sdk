import { BlockHandler } from './types';
import {
  ChainSync,
  ConnectionConfig,
  Schema,
  createChainSyncClient,
  createInteractionContext
} from '@cardano-ogmios/client';
import { DgraphClient } from './DgraphClient';
import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from './RunnableModule';
import { mergedRollForwardUpsert } from './util';

export class ChainFollower extends RunnableModule {
  #blockHandlers: BlockHandler[];
  #chainSyncClient: ChainSync.ChainSyncClient;
  #dgraphClient: DgraphClient;

  constructor(dgraphClient: DgraphClient, blockHandlers: BlockHandler[], logger: Logger = dummyLogger) {
    super('ChainFollower', logger);
    this.#blockHandlers = blockHandlers;
    this.#dgraphClient = dgraphClient;
  }

  public async initialize(ogmiosConnectionConfig?: ConnectionConfig) {
    super.initializeBefore();
    const ogmiosContext = await createInteractionContext(
      this.logger.error,
      (code, reason) => {
        this.logger.error({ code }, reason);
      },
      {
        connection: ogmiosConnectionConfig,
        interactionType: 'LongRunning'
      }
    );

    this.#chainSyncClient = await createChainSyncClient(ogmiosContext, {
      rollBackward: async ({ point, tip }, requestNext) => {
        if (point !== 'origin') {
          this.logger.info({ rollbackPoint: point, tip }, 'Rolling back');
          // const deleteResult = await this.dgraphClient.deleteDataAfterSlot(point.slot);
          this.logger.info('Deleted data');
        } else {
          this.logger.info('Rolling back to genesis');
          // const deleteResult = await this.dgraphClient.deleteDataAfterSlot(0);
          this.logger.info('Deleted data');
        }
        requestNext();
      },
      rollForward: async ({ block }, requestNext) => {
        this.logger.info({ BLOCK: block }, 'Rolling forward');
        const txn = this.#dgraphClient.newTxn();
        const context = { block, txn };
        // const { query, variables } = await mergedQuery(this.#blockHandlers, context);
        this.logger.info('About to run merged query');
        // const queryResults = await this.#dgraphClient.query(query, variables);
        // const preProcessingResults = await mergedPreProcessingResults(this.#blockHandlers, context, queryResults);
        const upsert = await mergedRollForwardUpsert(this.#blockHandlers, context);
        await this.#dgraphClient.writeDataFromBlock(upsert, txn);
        requestNext();
      }
    });
    super.initializeAfter();
  }

  public async start(points: Schema.PointOrOrigin[]) {
    super.startBefore();
    await this.#chainSyncClient.startSync(points);
    super.startAfter();
  }

  public async shutdown() {
    super.shutdownBefore();
    await this.#chainSyncClient.shutdown();
    super.shutdownAfter();
  }
}
