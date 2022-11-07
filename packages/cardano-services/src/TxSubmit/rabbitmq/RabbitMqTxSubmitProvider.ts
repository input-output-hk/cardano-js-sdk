import {
  Cardano,
  CardanoNodeErrors,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  SubmitTxArgs,
  TxSubmitProvider,
  cmlUtil
} from '@cardano-sdk/core';
import { Channel, Connection, connect } from 'amqplib';
import { Logger } from 'ts-log';
import { TX_SUBMISSION_QUEUE, getErrorPrototype, waitForPending } from './utils';
import { fromSerializableObject, hexStringToBuffer } from '@cardano-sdk/util';

const moduleName = 'RabbitMqTxSubmitProvider';

/**
 * Configuration options parameters for the RabbitMqTxSubmitProvider
 */
export interface RabbitMqTxSubmitProviderConfig {
  /**
   * The RabbitMQ connection URL
   */
  rabbitmqUrl: URL;
}

/**
 * Dependencies for the RabbitMqTxSubmitProvider
 */
export interface RabbitMqTxSubmitProviderDependencies {
  /**
   * The logger. Default: silent
   */
  logger: Logger;
}

/**
 * Connect to a [RabbitMQ](https://www.rabbitmq.com/) instance
 */
export class RabbitMqTxSubmitProvider implements TxSubmitProvider {
  #channel?: Channel;
  #connection?: Connection;
  #queueWasCreated = false;

  /**
   * The configuration options
   */
  #config: RabbitMqTxSubmitProviderConfig;

  /**
   *  The dependency objects
   */
  #dependencies: RabbitMqTxSubmitProviderDependencies;

  /**
   * @param config The configuration options
   * @param dependencies The dependency objects
   */
  constructor(config: RabbitMqTxSubmitProviderConfig, dependencies: RabbitMqTxSubmitProviderDependencies) {
    this.#config = config;
    this.#dependencies = dependencies;
  }

  /**
   * Connects to the RabbitMQ server and create the channel
   */
  async #connectAndCreateChannel() {
    if (this.#connection) return;

    try {
      this.#connection = await connect(this.#config.rabbitmqUrl.toString());
    } catch (error) {
      this.#dependencies.logger.error(`${moduleName}: while connecting`, error);
      void this.close();
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    }
    this.#connection.on('error', (error: unknown) =>
      this.#dependencies.logger.error(`${moduleName}: connection error`, error)
    );

    try {
      this.#channel = await this.#connection.createChannel();
    } catch (error) {
      this.#dependencies.logger.error(`${moduleName}: while creating channel`, error);
      void this.close();
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    }
    this.#channel.on('error', (error: unknown) =>
      this.#dependencies.logger.error(`${moduleName}: channel error`, error)
    );
  }

  /**
   * Idempotently (channel.assertQueue does the job for us) creates the queue
   *
   * @param force Forces the creation of the queue just to have a response from the server
   */
  async #ensureQueue(force?: boolean) {
    if (this.#queueWasCreated && !force) return;

    await this.#connectAndCreateChannel();

    try {
      await this.#channel!.assertQueue(TX_SUBMISSION_QUEUE);
      this.#queueWasCreated = true;
    } catch (error) {
      void this.close();
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    }
  }

  /**
   * Closes the connection to RabbitMQ and (for internal purposes) it resets the state as well
   */
  async close() {
    // Wait for pending operations before closing
    await waitForPending(this.#channel);

    try {
      await this.#channel?.close();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      this.#dependencies.logger.error({ error: error.name, module: moduleName }, error.message);
    }

    try {
      await this.#connection?.close();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      this.#dependencies.logger.error({ error: error.name, module: moduleName }, error.message);
    }

    this.#channel = undefined;
    this.#connection = undefined;
    this.#queueWasCreated = false;
  }

  /**
   * Checks for healthy status
   *
   * @returns {HealthCheckResponse} The result of the check
   */
  async healthCheck(): Promise<HealthCheckResponse> {
    let ok = false;

    try {
      await this.#ensureQueue(true);
      ok = true;
    } catch {
      this.#dependencies.logger.error({ error: 'Connection error', module: 'rabbitmqTxSubmitProvider' });
    }

    return { ok };
  }

  /**
   * Submit a transaction to RabbitMQ
   *
   * @param args data required to submit tx
   * @param args.signedTransaction hex string representation of a signedTransaction
   */
  async submitTx({ signedTransaction }: SubmitTxArgs) {
    return new Promise<void>(async (resolve, reject) => {
      let txId = '';

      const done = (error?: unknown) => {
        this.#dependencies.logger.debug(`${moduleName}: ${error ? 'rejecting' : 'resolving'} tx id: ${txId}`);

        if (error) reject(error);
        else resolve();
      };

      try {
        txId = cmlUtil.deserializeTx(signedTransaction).id.toString();

        this.#dependencies.logger.info(`${moduleName}: queuing tx id: ${txId}`);

        // Actually send the message
        await this.#ensureQueue();
        this.#channel!.sendToQueue(TX_SUBMISSION_QUEUE, hexStringToBuffer(signedTransaction));
        this.#dependencies.logger.debug(`${moduleName}: queued tx id: ${txId}`);

        // Set the queue for response message
        this.#dependencies.logger.debug(`${moduleName}: creating queue: ${txId}`);
        await this.#channel!.assertQueue(txId);
        this.#dependencies.logger.debug(`${moduleName}: created queue: ${txId}`);

        // We noticed that may happens that the response message handler is called before the
        // Promise is resolved, that's why we are awaiting for it inside the handler itself
        const consumePromise = this.#channel!.consume(txId, async (message) => {
          try {
            this.#dependencies.logger.debug(`${moduleName}: got result message from queue: ${txId}`);

            // This should never happen, just handle it for correct logging
            if (!message) return done(new Error('null message from result queue'));

            this.#channel!.ack(message);

            const { consumerTag } = await consumePromise;

            this.#dependencies.logger.debug(`${moduleName}: canceling consumer for queue: ${txId}`);
            await this.#channel!.cancel(consumerTag);
            this.#dependencies.logger.debug(`${moduleName}: deleting queue: ${txId}`);
            await this.#channel!.deleteQueue(txId);
            this.#dependencies.logger.debug(`${moduleName}: deleted queue: ${txId}`);

            const result = JSON.parse(message.content.toString());

            // An empty result message means submission ok
            if (Object.keys(result).length === 0) return done();

            done(fromSerializableObject(result, { getErrorPrototype }));
          } catch (error) {
            this.#dependencies.logger.error(`${moduleName}: while handling response message: ${txId}`);
            this.#dependencies.logger.error(error);
            done(error);
          }
        });
      } catch (error) {
        this.#dependencies.logger.error(`${moduleName}: while queuing transaction: ${txId}`);
        this.#dependencies.logger.error(error);
        done(Cardano.util.asTxSubmissionError(error) || new CardanoNodeErrors.UnknownTxSubmissionError(error));
      }
    });
  }
}
