/* eslint-disable no-console */
import {
  Cardano,
  CardanoNodeErrors,
  HealthCheckResponse,
  ProviderDependencies,
  SubmitTxArgs,
  TxSubmitProvider
} from '@cardano-sdk/core';
import {
  ConnectionConfig,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  TxSubmission
} from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { OgmiosCardanoNode } from '../../CardanoNode';
import { RunnableModule, contextLogger, isNotNil } from '@cardano-sdk/util';
import { TxSubmissionClient, createTxSubmissionClient } from '../../Ogmios/TxSubmissionClient';
import { createInteractionContextWithLogger } from '../../util';

/**
 * Connect to an [Ogmios](https://ogmios.dev/) instance
 *
 * @class OgmiosTxSubmitProvider
 */
export class OgmiosTxSubmitProvider extends RunnableModule implements TxSubmitProvider {
  #txSubmissionClient: TxSubmissionClient;
  #logger: Logger;
  #connectionConfig: ConnectionConfig;

  /**
   * @param {ConnectionConfig} connectionConfig Ogmios connection configuration
   * @param {Logger} logger object implementing the Logger abstract class
   * @throws {TxSubmission.errors}
   */
  constructor(connectionConfig: ConnectionConfig, { logger }: ProviderDependencies) {
    super('OgmiosTxSubmitProvider', logger);
    this.#logger = contextLogger(logger, 'OgmiosTxSubmitProvider');
    this.#connectionConfig = connectionConfig;
  }

  public async initializeImpl(): Promise<void> {
    this.#logger.info('Initializing OgmiosTxSubmitProvider');

    this.#txSubmissionClient = await createTxSubmissionClient(
      await createInteractionContextWithLogger(contextLogger(this.#logger, 'ogmiosTxSubmitProvider'), {
        connection: this.#connectionConfig,
        interactionType: 'LongRunning'
      })
    );

    this.#logger.info('OgmiosTxSubmitProvider initialized');
  }

  public async shutdownImpl(): Promise<void> {
    this.#logger.info('Shutting down OgmiosTxSubmitProvider');
    if (
      isNotNil(this.#txSubmissionClient) &&
      this.#txSubmissionClient.context.socket.readyState !== this.#txSubmissionClient.context.socket.CLOSED
    ) {
      await this.#txSubmissionClient.shutdown();
    }
  }

  async submitTx({ signedTransaction }: SubmitTxArgs): Promise<void> {
    if (this.state !== 'running') {
      throw new CardanoNodeErrors.NotInitializedError('submitTx', this.name);
    }
    try {
      await this.#txSubmissionClient.submitTx(signedTransaction);
    } catch (error) {
      throw Cardano.util.asTxSubmissionError(error) || new CardanoNodeErrors.UnknownTxSubmissionError(error);
    }
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return OgmiosCardanoNode.healthCheck(this.#connectionConfig, this.logger);
  }

  async startImpl(): Promise<void> {
    return Promise.resolve();
  }
}
