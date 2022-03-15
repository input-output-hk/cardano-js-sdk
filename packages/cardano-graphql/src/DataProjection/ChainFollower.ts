import { BlockHandler, CombinedQueryResult } from './types';
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
import { mergedProcessingResults, mergedQuery, mergedRollForwardUpsert } from './util';

export class ChainFollower extends RunnableModule {
  #blockHandlers: BlockHandler[];
  #chainSyncClient: ChainSync.ChainSyncClient;
  #dgraphClient: DgraphClient;

  constructor(dgraphClient: DgraphClient, blockHandlers: BlockHandler[], logger: Logger = dummyLogger) {
    super('ChainFollower', logger);
    this.#blockHandlers = blockHandlers;
    this.#dgraphClient = dgraphClient;
  }

  public async initializeImpl(ogmiosConnectionConfig?: ConnectionConfig) {
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
        const { query, variables } = await mergedQuery(this.#blockHandlers, context);
        this.logger.info('About to run merged query');
        const mergedQueryResults: CombinedQueryResult = await this.#dgraphClient.query(query, variables);
        this.logger.info('About to process query results');
        const processingResults = await mergedProcessingResults(this.#blockHandlers, context, mergedQueryResults);
        this.logger.info('Query results processed. About to merge roll forward upsert');
        const upsert = await mergedRollForwardUpsert(this.#blockHandlers, context, processingResults);
        this.logger.info('Writting data from block');
        await this.#dgraphClient.writeDataFromBlock(upsert, txn);
        this.logger.info('Successfully written');
        requestNext();
      }
    });
    super.initializeAfter();
  }

  public async startImpl(points: Schema.PointOrOrigin[]) {
    await this.#chainSyncClient.startSync(points);
  }

  public async shutdownImpl() {
    await this.#chainSyncClient.shutdown();
  }
}
