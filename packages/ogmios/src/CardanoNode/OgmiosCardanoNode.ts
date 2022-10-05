import {
  Cardano,
  CardanoNode,
  CardanoNodeErrors,
  CardanoNodeUtil,
  EraSummary,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  StakeDistribution
} from '@cardano-sdk/core';
import {
  ConnectionConfig,
  StateQuery,
  createConnectionObject,
  createStateQueryClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { contextLogger } from '@cardano-sdk/util';
import { createInteractionContextWithLogger } from '../util';
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
    this.#logger = contextLogger(logger, 'OgmiosCardanoNode');
    this.#state = null;
    this.#connectionConfig = connectionConfig;
  }

  public async initialize(): Promise<void> {
    if (this.#state !== null) return;
    this.#state = 'initializing';
    this.#logger.info('Initializing CardanoNode');
    this.#stateQueryClient = await createStateQueryClient(
      await createInteractionContextWithLogger(this.#logger, { connection: this.#connectionConfig })
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

  public async eraSummaries(): Promise<EraSummary[]> {
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

  public async systemStart(): Promise<Date> {
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

  async healthCheck(): Promise<HealthCheckResponse> {
    try {
      const { networkSynchronization, lastKnownTip } = await getServerHealth({
        connection: createConnectionObject(this.#connectionConfig)
      });
      return {
        localNode: {
          ledgerTip: lastKnownTip,
          networkSync: networkSynchronization
        },
        ok: networkSynchronization > 0.99
      };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      if (error.name === 'FetchError') {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  }
}
