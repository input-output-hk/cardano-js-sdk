/* eslint-disable no-console */
import {
  ConnectionConfig,
  TransactionSubmission,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  TxSubmission
} from '@cardano-ogmios/client';
import {
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  HandleOwnerChangeError,
  HandleProvider,
  HealthCheckResponse,
  ProviderDependencies,
  ProviderError,
  ProviderFailure,
  SubmitTxArgs,
  TxSubmitProvider
} from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { OgmiosCardanoNode } from '../../CardanoNode';
import { RunnableModule, contextLogger, isNotNil } from '@cardano-sdk/util';
import { createInteractionContextWithLogger } from '../../util';
import { withCoreCardanoNodeError } from '../../CardanoNode/queries';

/**
 * Connect to an [Ogmios](https://ogmios.dev/) instance
 *
 * @class OgmiosTxSubmitProvider
 */
export class OgmiosTxSubmitProvider extends RunnableModule implements TxSubmitProvider {
  #txSubmissionClient: TransactionSubmission.TransactionSubmissionClient;
  #logger: Logger;
  #connectionConfig: ConnectionConfig;
  #handleProvider?: HandleProvider;

  /**
   * @param {ConnectionConfig} connectionConfig Ogmios connection configuration
   * @param {Logger} logger object implementing the Logger abstract class
   * @throws {TxSubmission.errors}
   */
  constructor(connectionConfig: ConnectionConfig, { logger }: ProviderDependencies, handleProvider?: HandleProvider) {
    super('OgmiosTxSubmitProvider', logger);
    this.#logger = contextLogger(logger, 'OgmiosTxSubmitProvider');
    this.#connectionConfig = connectionConfig;
    this.#handleProvider = handleProvider;
  }

  public async initializeImpl(): Promise<void> {
    this.#logger.info('Initializing OgmiosTxSubmitProvider');

    this.#txSubmissionClient = await TransactionSubmission.createTransactionSubmissionClient(
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

  async submitTx({ signedTransaction, context }: SubmitTxArgs): Promise<void> {
    if (this.state !== 'running') {
      throw new GeneralCardanoNodeError(
        GeneralCardanoNodeErrorCode.ServerNotReady,
        null,
        'OgmiosTxSubmitProvider not started'
      );
    }

    await this.throwIfHandleResolutionConflict(context);
    return withCoreCardanoNodeError(async () => {
      const id = await this.#txSubmissionClient.submitTransaction(signedTransaction);
      this.#logger.info(`Submitted ${id}`);
    });
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return OgmiosCardanoNode.healthCheck(this.#connectionConfig, this.logger);
  }

  async startImpl(): Promise<void> {
    return Promise.resolve();
  }

  private async throwIfHandleResolutionConflict(context: SubmitTxArgs['context']): Promise<void> {
    if (context?.handleResolutions && context.handleResolutions.length > 0) {
      if (!this.#handleProvider) {
        throw new ProviderError(
          ProviderFailure.NotImplemented,
          undefined,
          'No HandleProvider was set during construction.'
        );
      }

      const handleInfoList = await this.#handleProvider.resolveHandles({
        handles: context.handleResolutions.map((hndRes) => hndRes.handle)
      });

      for (const [index, handleInfo] of handleInfoList.entries()) {
        if (!handleInfo || handleInfo.cardanoAddress !== context.handleResolutions[index].cardanoAddress) {
          const handleOwnerChangeError = new HandleOwnerChangeError(
            context.handleResolutions[index].handle,
            context.handleResolutions[index].cardanoAddress,
            handleInfo ? handleInfo.cardanoAddress : null
          );
          throw new ProviderError(ProviderFailure.Conflict, handleOwnerChangeError);
        }
      }
    }
  }
}
