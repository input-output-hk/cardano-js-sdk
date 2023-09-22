import {
  Cardano,
  CardanoNode,
  EraSummary,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
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
import { queryEraSummaries, withCoreCardanoNodeError } from './queries';

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
    this.#assertIsRunning();
    return queryEraSummaries(this.#stateQueryClient, this.#logger);
  }

  public async systemStart(): Promise<Date> {
    this.#assertIsRunning();
    this.#logger.info('Getting system start');
    return withCoreCardanoNodeError(async () => this.#stateQueryClient.networkStartTime());
  }

  public async stakeDistribution(): Promise<StakeDistribution> {
    this.#assertIsRunning();
    this.#logger.info('Getting stake distribution');
    return withCoreCardanoNodeError(async () => {
      const map = new Map();
      for (const [key, value] of Object.entries(await this.#stateQueryClient.liveStakeDistribution())) {
        const splitStake = value.stake.split('/');
        map.set(Cardano.PoolId(key), {
          ...value,
          stake: { pool: BigInt(splitStake[0]), supply: BigInt(splitStake[1]) }
        });
      }
      return map;
    });
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

  #assertIsRunning() {
    if (this.state !== 'running') {
      throw new GeneralCardanoNodeError(
        GeneralCardanoNodeErrorCode.ServerNotReady,
        null,
        'OgmiosCardanoNode is not running'
      );
    }
  }
}
