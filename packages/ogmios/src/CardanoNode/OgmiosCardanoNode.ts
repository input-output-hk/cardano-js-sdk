import {
  Cardano,
  CardanoNode,
  CardanoNodeErrors,
  CardanoNodeUtil,
  EraSummary,
  HealthCheckResponse,
  StakeDistribution
} from '@cardano-sdk/core';
import {
  ConnectionConfig,
  LedgerStateQuery,
  createConnectionObject,
  createLedgerStateQueryClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { RunnableModule, contextLogger } from '@cardano-sdk/util';
import { createInteractionContextWithLogger, ogmiosServerHealthToHealthCheckResponse } from '../util';
import { queryEraSummaries } from './queries';

/**
 * Access cardano-node APIs via Ogmios
 *
 * @class OgmiosCardanoNode
 */
export class OgmiosCardanoNode extends RunnableModule implements CardanoNode {
  #stateQueryClient: LedgerStateQuery.LedgerStateQueryClient;
  #logger: Logger;
  #connectionConfig: ConnectionConfig;

  constructor(connectionConfig: ConnectionConfig, logger: Logger) {
    super('OgmiosCardanoNode', logger);
    this.#logger = contextLogger(logger, 'OgmiosCardanoNode');
    this.#connectionConfig = connectionConfig;
  }

  public async initializeImpl(): Promise<void> {
    this.#logger.info('Initializing CardanoNode');
    this.#stateQueryClient = await createLedgerStateQueryClient(
      await createInteractionContextWithLogger(this.#logger, { connection: this.#connectionConfig })
    );
    this.#logger.info('CardanoNode initialized');
  }

  public async shutdownImpl(): Promise<void> {
    this.#logger.info('Shutting down CardanoNode');
    await this.#stateQueryClient.shutdown();
  }

  public async eraSummaries(): Promise<EraSummary[]> {
    if (this.state !== 'running') {
      throw new CardanoNodeErrors.NotInitializedError('eraSummaries', this.name);
    }
    return queryEraSummaries(this.#stateQueryClient, this.#logger);
  }

  public async systemStart(): Promise<Date> {
    if (this.state !== 'running') {
      throw new CardanoNodeErrors.NotInitializedError('systemStart', this.name);
    }
    try {
      this.#logger.info('Getting system start');
      return new Date((await this.#stateQueryClient.eraStart()).time);
    } catch (error) {
      throw CardanoNodeUtil.asCardanoNodeError(error) || new CardanoNodeErrors.UnknownCardanoNodeError(error);
    }
  }

  public async stakeDistribution(): Promise<StakeDistribution> {
    if (this.state !== 'running') {
      throw new CardanoNodeErrors.NotInitializedError('stakeDistribution', this.name);
    }
    try {
      this.#logger.info('Getting stake distribution');
      const map = new Map();
      for (const [key, value] of Object.entries(await this.#stateQueryClient.liveStakeDistribution())) {
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

  healthCheck(): Promise<HealthCheckResponse> {
    return OgmiosCardanoNode.healthCheck(this.#connectionConfig, this.logger);
  }

  static async healthCheck(connectionConfig: ConnectionConfig, logger: Logger): Promise<HealthCheckResponse> {
    try {
      return ogmiosServerHealthToHealthCheckResponse(
        await getServerHealth({
          connection: createConnectionObject(connectionConfig)
        })
      );
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      logger.error(error.message);
      return { ok: false };
    }
  }

  async startImpl(): Promise<void> {
    return Promise.resolve();
  }
}
