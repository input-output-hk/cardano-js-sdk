import { Buffer } from 'buffer';
import { Cardano, HealthCheckResponse, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { Channel, Connection, connect } from 'amqplib';
import { Logger, dummyLogger } from 'ts-log';

const queue = 'tx-submit';

/**
 * Connect to a [RabbitMQ](https://www.rabbitmq.com/) instance
 */
export class RabbitMqTxSubmitProvider implements TxSubmitProvider {
  #channel?: Channel;
  #connection?: Connection;
  #connectionURL: URL;
  #logger: Logger;
  #queueWasCreated = false;

  /**
   * @param {URL} connectionURL RabbitMQ connection URL
   * @param {Logger} logger object implementing the Logger abstract class
   */
  constructor(connectionURL: URL, logger: Logger = dummyLogger) {
    this.#connectionURL = connectionURL;
    this.#logger = logger;
  }

  /**
   * Connects to the RabbitMQ server and create the channel
   */
  async #connectAndCreateChannel() {
    if (this.#connection) return;

    try {
      this.#connection = await connect(this.#connectionURL.toString());
    } catch (error) {
      await this.close();
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    }

    try {
      this.#channel = await this.#connection.createChannel();
    } catch (error) {
      await this.close();
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    }
  }

  /**
   * Idempotently (channel.assertQueue does the job for us) creates the queue
   *
   * @param {boolean} force Forces the creation of the queue just to have a response from the server
   */
  async #ensureQueue(force?: boolean) {
    if (this.#queueWasCreated && !force) return;

    await this.#connectAndCreateChannel();
    this.#queueWasCreated = true;

    try {
      await this.#channel!.assertQueue(queue);
    } catch (error) {
      await this.close();
      throw new ProviderError(ProviderFailure.ConnectionFailure, error);
    }
  }

  /**
   * Closes the connection to RabbitMQ and (for interl purposes) it resets the state as well
   */
  async close() {
    try {
      await this.#connection?.close();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      this.#logger.error({ error: error.name, module: 'rabbitmqTxSubmitProvider' }, error.message);
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
      this.#logger.error({ error: 'Connection error', module: 'rabbitmqTxSubmitProvider' });
    }

    return { ok };
  }

  /**
   * Submit a transaction to RabbitMQ
   *
   * @param {Uint8Array} signedTransaction The Uint8Array representation of a signedTransaction
   */
  async submitTx(signedTransaction: Uint8Array) {
    try {
      await this.#ensureQueue();
      this.#channel!.sendToQueue(queue, Buffer.from(signedTransaction));
    } catch (error) {
      throw Cardano.util.asTxSubmissionError(error) || new Cardano.UnknownTxSubmissionError(error);
    }
  }
}
