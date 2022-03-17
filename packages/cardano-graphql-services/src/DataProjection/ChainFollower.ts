import { BlockHandler, CombinedQueryResult, RollBackwardContext } from './types';
import {
  ChainSync,
  ConnectionConfig,
  Schema,
  createChainSyncClient,
  createInteractionContext
} from '@cardano-ogmios/client';
import { DgraphClient } from './DgraphClient';
import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from '../RunnableModule';
import { mergedProcessingResults, mergedQuery, mergedRollBackwardUpsert, mergedRollForwardUpsert } from './util';

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
        const txn = this.#dgraphClient.newTxn();
        // let context: RollBackwardContext;
        if (point !== 'origin') {
          // context = { point, tip } as RollBackwardContext;
        } else {
          this.logger.info('Rolling back to genesis');
          // const deleteResult = await this.dgraphClient.deleteDataAfterSlot(0);
          // const genesisPoint = { slot: 0 };
          // const context = { point: genesisPoint, tip };
          // const upsert = await mergedRollBackwardUpsert(this.#blockHandlers, context);
          // await this.#dgraphClient.deleteDataAfterSlot(upsert, txn);
        }
        this.logger.info({ rollbackPoint: point, tip }, 'Rolling back');
        const context = { point, tip } as RollBackwardContext;
        const upsert = await mergedRollBackwardUpsert(this.#blockHandlers, context);
        await this.#dgraphClient.deleteDataAfterSlot(upsert, txn);
        this.logger.info('Deleted data');
        requestNext();
      },
      rollForward: async ({ block }, requestNext) => {
        this.logger.debug({ BLOCK: block }, 'Rolling forward');
        const txn = this.#dgraphClient.newTxn();
        const context = { block, txn };
        const { query, variables } = await mergedQuery(this.#blockHandlers, context);
        this.logger.debug('About to run merged query');
        const mergedQueryResults: CombinedQueryResult = await this.#dgraphClient.query(query, variables);
        this.logger.debug('About to process query results');
        const processingResults = await mergedProcessingResults(this.#blockHandlers, context, mergedQueryResults);
        this.logger.debug('Query results processed. About to merge roll forward upsert');
        const upsert = await mergedRollForwardUpsert(this.#blockHandlers, context, processingResults);
        this.logger.debug('Writting data from block');
        await this.#dgraphClient.writeDataFromBlock(upsert, txn);
        this.logger.debug('Successfully written');
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
