/* eslint-disable no-console */
import {
  Cardano,
  CardanoNodeErrors,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  SubmitTxArgs,
  TxSubmitProvider
} from '@cardano-sdk/core';
import {
  ConnectionConfig,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  TxSubmission,
  createConnectionObject,
  createTxSubmissionClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { RunnableModule, contextLogger, isNotNil } from '@cardano-sdk/util';
import { createInteractionContextWithLogger } from '../../util';

/**
 * Connect to an [Ogmios](https://ogmios.dev/) instance
 *
 * @class OgmiosTxSubmitProvider
 */
export class OgmiosTxSubmitProvider extends RunnableModule implements TxSubmitProvider {
  #txSubmissionClient: TxSubmission.TxSubmissionClient;
  #logger: Logger;
  #connectionConfig: ConnectionConfig;

  /**
   * @param {ConnectionConfig} connectionConfig Ogmios connection configuration
   * @param {Logger} logger object implementing the Logger abstract class
   * @throws {TxSubmission.errors}
   */
  constructor(connectionConfig: ConnectionConfig, logger: Logger) {
    super('OgmiosTxSubmitProvider', logger);
    this.#logger = contextLogger(logger, 'OgmiosTxSubmitProvider');
    this.#connectionConfig = connectionConfig;
  }

  public async initializeImpl(): Promise<void> {
    this.#logger.info('Initializing OgmiosTxSubmitProvider');
    // The provider interface now includes shutdown handling
    // We can initialize the txSubmissionClient in this scope
    // once ADP-2370 is done and will enable switching to a long-running ws connection
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
      this.#txSubmissionClient = await createTxSubmissionClient(
        await createInteractionContextWithLogger(contextLogger(this.#logger, 'ogmiosTxSubmitProvider'), {
          connection: this.#connectionConfig,
          // Should be updated to a long-running once ADP-2370 is done.
          interactionType: 'OneTime'
        })
      );
      await this.#txSubmissionClient.submitTx(signedTransaction);
    } catch (error) {
      throw Cardano.util.asTxSubmissionError(error) || new CardanoNodeErrors.UnknownTxSubmissionError(error);
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
          networkSync: Cardano.Percent(networkSynchronization)
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

  async startImpl(): Promise<void> {
    return Promise.resolve();
  }
}
