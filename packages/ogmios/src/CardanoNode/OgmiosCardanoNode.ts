import { Cardano, CardanoNode, CardanoNodeErrors, CardanoNodeUtil, StakeDistribution } from '@cardano-sdk/core';
import { ConnectionConfig, StateQuery, createInteractionContext, createStateQueryClient } from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { mapEraSummary } from './mappers';

type CardanoNodeState = 'initialized' | 'initializing' | null;

/**
 * Access cardano-node APIs via Ogmios
 *
 * @class OgmiosCardanoNode
 */
export class OgmiosCardanoNode implements CardanoNode {
  #stateQueryClient: StateQuery.StateQueryClient;
  #logger: Logger;
  #state: CardanoNodeState;
  #connectionConfig: ConnectionConfig;

  constructor(connectionConfig: ConnectionConfig, logger: Logger) {
    this.#logger = logger;
    this.#state = null;
    this.#connectionConfig = connectionConfig;
  }

  public async initialize() {
    if (this.#state !== null) return;
    this.#state = 'initializing';
    this.#logger.info('Initializing CardanoNode');
    this.#stateQueryClient = await createStateQueryClient(
      await createInteractionContext(
        (error) => {
          this.#logger.error.bind(this.#logger)({ error: error.name, module: 'CardanoNode' }, error.message);
        },
        this.#logger.info.bind(this.#logger),
        { connection: this.#connectionConfig, interactionType: 'LongRunning' }
      )
    );
    this.#state = 'initialized';
    this.#logger.info('CardanoNode initialized');
  }

  public async shutdown(): Promise<void> {
    if (this.#state !== 'initialized') {
      throw new CardanoNodeErrors.CardanoNodeNotInitializedError('shutdown');
    }
    this.#logger.info('Shutting down CardanoNode');
    await this.#stateQueryClient.shutdown();
    this.#state = null;
  }

  public async eraSummaries() {
    if (this.#state !== 'initialized') {
      throw new CardanoNodeErrors.CardanoNodeNotInitializedError('eraSummaries');
    }
    try {
      this.#logger.info('Getting era summaries');
      const systemStart = await this.#stateQueryClient.systemStart();
      const eraSummaries = await this.#stateQueryClient.eraSummaries();
      return eraSummaries.map((era) => mapEraSummary(era, systemStart));
    } catch (error) {
      throw CardanoNodeUtil.asCardanoNodeError(error) || new CardanoNodeErrors.UnknownCardanoNodeError(error);
    }
  }

  public async systemStart() {
    if (this.#state !== 'initialized') {
      throw new CardanoNodeErrors.CardanoNodeNotInitializedError('systemStart');
    }
    try {
      this.#logger.info('Getting system start');
      return await this.#stateQueryClient.systemStart();
    } catch (error) {
      throw CardanoNodeUtil.asCardanoNodeError(error) || new CardanoNodeErrors.UnknownCardanoNodeError(error);
    }
  }

  public async stakeDistribution(): Promise<StakeDistribution> {
    if (this.#state !== 'initialized') {
      throw new CardanoNodeErrors.CardanoNodeNotInitializedError('stakeDistribution');
    }
    try {
      this.#logger.info('Getting stake distribution');
      const map = new Map();
      for (const [key, value] of Object.entries(await this.#stateQueryClient.stakeDistribution())) {
        const splitStake = value.stake.split('/');
        map.set(Cardano.PoolId(key), {
          ...value,
          stake: { pool: BigInt(splitStake[0]), supply: BigInt(splitStake[1]) }
        });
      }
      return map;
    } catch (error) {
      throw CardanoNodeUtil.asCardanoNodeError(error) || new CardanoNodeErrors.UnknownCardanoNodeError(error);
    }
  }
}
