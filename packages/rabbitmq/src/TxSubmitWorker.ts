/* eslint-disable @typescript-eslint/no-shadow */
import { Channel, Connection, Message, connect } from 'amqplib';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { TX_SUBMISSION_QUEUE } from './rabbitmqTxSubmitProvider';

const moduleName = 'TxSubmitWorker';

/**
 * Configuration options parameters for the TxSubmitWorker
 */
export interface TxSubmitWorkerConfig {
  /**
   * Instructs the worker to process multiple transactions simultaneously.
   * Default: false (serial mode)
   */
  parallel?: boolean;

  /**
   * The number of Tx submitted to the txSubmitProvider in parallel.
   * Ignored in serial mode. Default: 3
   */
  parallelTxs?: number;

  /**
   * The RabbitMQ polling cycle in milliseconds.
   * Ignored in parallel mode. Default: 500
   */
  pollingCycle?: number;

  /**
   * The RabbitMQ connection URL
   */
  rabbitmqUrl: URL;
}

/**
 * Dependencies for the TxSubmitWorker
 */
export interface TxSubmitWorkerDependencies {
  /**
   * The logger. Default: silent
   */
  logger?: Logger;

  /**
   * The provider to use to submit tx
   */
  txSubmitProvider: TxSubmitProvider;
}

/**
 * Controller class for the transactions submission worker which gets
 * transactions from RabbitMQ and submit them via the TxSubmitProvider
 */
export class TxSubmitWorker {
  /**
   * The RabbitMQ channel
   */
  #channel?: Channel;

  /**
   * The configuration options
   */
  #config: TxSubmitWorkerConfig;

  /**
   * The RabbitMQ connection
   */
  #connection?: Connection;

  /**
   * Flag to exit from the infinite loop in case of sequential tx handlig
   */
  #continueForever = false;

  /**
   * The RabbitMQ consumerTag
   */
  #consumerTag?: string;

  /**
   * Internal messages counter
   */
  #counter = 0;

  /**
   *  The dependency objects
   */
  #dependencies: TxSubmitWorkerDependencies;

  /**
   * The function to call to resolve the start method exit Promise
   */
  #exitResolver?: () => void;

  /**
   * The internal worker status
   */
  #status: 'connected' | 'connecting' | 'error' | 'idle' = 'idle';

  /**
   * @param {TxSubmitWorkerConfig} config The configuration options
   * @param {TxSubmitWorkerDependencies} dependencies The dependency objects
   */
  constructor(config: TxSubmitWorkerConfig, dependencies: TxSubmitWorkerDependencies) {
    this.#config = { parallelTxs: 3, pollingCycle: 500, ...config };
    this.#dependencies = { logger: dummyLogger, ...dependencies };
  }

  /**
   * Get the status of the worker
   *
   * @returns the status of the worker
   */
  getStatus() {
    return this.#status;
  }

  /**
   * Starts the worker
   */
  start() {
    return new Promise<void>(async (resolve, reject) => {
      const closeHandler = async (isAsync: boolean, err: unknown) => {
        if (err) {
          this.logError(err, isAsync);
          this.#exitResolver = undefined;
          this.#status = 'error';
          await this.stop();
          reject(err);
        }
      };

      try {
        this.#dependencies.logger!.info(`${moduleName} init: checking tx submission provider health status`);

        const { ok } = await this.#dependencies.txSubmitProvider.healthCheck();

        if (!ok) throw new ProviderError(ProviderFailure.Unhealthy);

        this.#dependencies.logger!.info(`${moduleName} init: opening RabbitMQ connection`);
        this.#exitResolver = resolve;
        this.#status = 'connecting';
        this.#connection = await connect(this.#config.rabbitmqUrl.toString());
        this.#connection.on('close', (error) => closeHandler(true, error));

        this.#dependencies.logger!.info(`${moduleName} init: opening RabbitMQ channel`);
        this.#channel = await this.#connection.createChannel();
        this.#channel.on('close', (error) => closeHandler(true, error));

        this.#dependencies.logger!.info(`${moduleName} init: ensuring RabbitMQ queue`);
        await this.#channel.assertQueue(TX_SUBMISSION_QUEUE);
        this.#dependencies.logger!.info(`${moduleName}: init completed`);

        if (this.#config.parallel) {
          this.#dependencies.logger!.info(`${moduleName}: starting parallel mode`);
          await this.#channel.prefetch(this.#config.parallelTxs!, true);

          const parallelHandler = (message: Message | null) => (message ? this.submitTx(message) : null);
          const { consumerTag } = await this.#channel.consume(TX_SUBMISSION_QUEUE, parallelHandler);

          this.#consumerTag = consumerTag;
          this.#status = 'connected';
        } else {
          this.#dependencies.logger!.info(`${moduleName}: starting serial mode`);
          await this.infiniteLoop();
        }
      } catch (error) {
        await closeHandler(false, error);
      }
    });
  }

  /**
   * Stops the worker. Once connection shutdown is completed,
   * the Promise returned by the start method is resolved as well
   */
  async stop() {
    // This method needs to call this.#exitResolver at the end.
    // Since it may be called more than once simultaneously,
    // we need to ensure this.#exitResolver is called only once,
    // so we immediately store its value in a local variable and we reset it
    const exitResolver = this.#exitResolver;
    this.#exitResolver = undefined;

    try {
      this.#dependencies.logger!.info(`${moduleName} shutdown: closing RabbitMQ channel`);

      try {
        if (this.#consumerTag) {
          const consumerTag = this.#consumerTag;
          this.#consumerTag = undefined;

          await this.#channel?.cancel(consumerTag);
        }
      } catch (error) {
        this.logError(error);
      }

      this.#dependencies.logger!.info(`${moduleName} shutdown: closing RabbitMQ connection`);

      try {
        await this.#connection?.close();
      } catch (error) {
        this.logError(error);
      }

      this.#dependencies.logger!.info(`${moduleName}: shutdown completed`);
      this.#channel = undefined;
      this.#connection = undefined;
      this.#consumerTag = undefined;
      this.#continueForever = false;
      this.#status = 'idle';
    } finally {
      // Only logging functions could throw an error here...
      // Although this is almost impossible, we want to be sure exitResolver is called
      exitResolver?.();
    }
  }

  /**
   * Wrapper to log errors from try/catch blocks
   *
   * @param {any} error the error to log
   */
  private logError(error: unknown, isAsync = false) {
    const errorMessage =
      // eslint-disable-next-line prettier/prettier
      error instanceof Error ? error.message : (typeof error === 'string' ? error : JSON.stringify(error));
    const errorObject = { error: error instanceof Error ? error.name : 'Unknown error', isAsync, module: moduleName };

    this.#dependencies.logger!.error(errorObject, errorMessage);
    if (error instanceof Error) this.#dependencies.logger!.debug(`${moduleName}:`, error.stack);
  }

  /**
   * The infinite loop to perform serial tx submission
   */
  private async infiniteLoop() {
    this.#continueForever = true;
    this.#status = 'connected';

    while (this.#continueForever) {
      const message = await this.#channel?.get(TX_SUBMISSION_QUEUE);

      // If there is a message, handle it, otherwise wait #pollingCycle ms
      await (message
        ? this.submitTx(message)
        : new Promise((resolve) => setTimeout(resolve, this.#config.pollingCycle!)));
    }
  }

  /**
   * Submit a tx to the provider and ack (or nack) the message
   *
   * @param {Message} message the message containing the transaction
   */
  private async submitTx(message: Message) {
    try {
      const counter = ++this.#counter;
      const { content } = message;

      this.#dependencies.logger!.info(`${moduleName}: submitting tx`);
      this.#dependencies.logger!.debug(`${moduleName}: tx ${counter} dump:`, content.toString('hex'));
      await this.#dependencies.txSubmitProvider.submitTx(new Uint8Array(content));

      this.#dependencies.logger!.debug(`${moduleName}: ACKing RabbitMQ message ${counter}`);
      this.#channel?.ack(message);
    } catch (error) {
      this.logError(error);

      try {
        this.#dependencies.logger!.info(`${moduleName}: NACKing RabbitMQ message`);
        this.#channel?.nack(message);
        // eslint-disable-next-line no-catch-shadow
      } catch (error) {
        this.logError(error);
      }
    }
  }
}
