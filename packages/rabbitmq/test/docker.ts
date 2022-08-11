import { Logger } from 'ts-log';
import { RabbitMqTxSubmitProvider } from '../src/rabbitmqTxSubmitProvider';
import { connect } from 'amqplib';
import { contextLogger } from '@cardano-sdk/util';
import { getRandomPort } from 'get-port-please';
import { imageExists, pullImageAsync } from 'dockerode-utils';
import { readFile, writeFile } from 'fs/promises';
import { txsPromise } from './utils';
import Docker from 'dockerode';
import axios from 'axios';
import path from 'path';

const CONTAINER_IMAGE = 'rabbitmq:3.10-management';
const CONTAINER_NAME = 'cardano-rabbitmq-test';

/**
 * Class to handle RabbitMQ Docker Containers
 */
export class RabbitMQContainer {
  #adminPort = 0;
  #containerName: string;
  #serverPort = 0;

  constructor(containerName = CONTAINER_NAME) {
    this.#containerName = containerName;
  }

  private getPublicProperties() {
    return {
      adminPort: this.#adminPort,
      adminUrl: `http://guest:guest@localhost:${this.#adminPort}/`,
      rabbitmqPort: this.#serverPort,
      rabbitmqUrl: new URL(`amqp://localhost:${this.#serverPort}`)
    };
  }

  /**
   * Starts a new container with the given name,
   * eventually stops any other running container with the same name
   */
  async start() {
    this.#adminPort = await getRandomPort();
    this.#serverPort = await getRandomPort();

    const docker = new Docker();
    const needsToPull = !(await imageExists(docker, CONTAINER_IMAGE));

    if (needsToPull) await pullImageAsync(docker, CONTAINER_IMAGE);
    await this.stop();

    const container = await docker.createContainer({
      HostConfig: {
        PortBindings: {
          '5672/tcp': [{ HostPort: `${this.#serverPort}` }],
          '15672/tcp': [{ HostPort: `${this.#adminPort}` }]
        }
      },
      Image: CONTAINER_IMAGE,
      name: this.#containerName
    });
    await container.start();

    const ret = this.getPublicProperties();

    // Once the container starts it is not immediately ready to accept connections
    // this waits for that short delay
    await new Promise<void>(async (resolve) => {
      // eslint-disable-next-line no-constant-condition
      while (true)
        try {
          // eslint-disable-next-line @typescript-eslint/no-shadow
          await new Promise((resolve) => setTimeout(resolve, 1000));
          await connect(ret.rabbitmqUrl.toString());
          return resolve();
          // eslint-disable-next-line no-empty
        } catch {}
    });

    return ret;
  }

  /**
   * Stops the container with the given name
   */
  async stop() {
    const docker = new Docker();
    const container = docker.getContainer(this.#containerName);

    try {
      try {
        await container.stop();
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        // 304 = container already stopped
        if (error.statusCode !== 304) throw error;
      }

      await container.remove({ v: true });
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      // 404 = container not found
      if (error.statusCode !== 404) throw error;
    }
  }

  /**
   * Removes all the queues from the server
   */
  async removeQueues() {
    const { adminUrl, rabbitmqUrl } = this.getPublicProperties();
    const queues = await axios.get(`${adminUrl}api/queues/`);

    if (queues.data.length === 0) return;

    const connection = await connect(rabbitmqUrl.toString());
    const channel = await connection.createChannel();

    for (const queue of queues.data) await channel.deleteQueue(queue.name as string);

    await channel.close();
    await connection.close();
  }

  /**
   * Saves the container data.
   * This is useful when docker need to be started in jest-setup scripts;
   * once called all the test suites can use the load() method to access the same RabbitMQ
   */
  save() {
    return writeFile(
      path.join(__dirname, 'containers', `${this.#containerName}.json`),
      JSON.stringify({
        adminPort: this.#adminPort,
        serverPort: this.#serverPort
      })
    );
  }

  /**
   * Loads container data. See save() methods for details.
   */
  async load() {
    const file = await readFile(path.join(__dirname, 'containers', `${this.#containerName}.json`));
    const { adminPort, serverPort } = JSON.parse(file.toString()) as { adminPort: number; serverPort: number };

    this.#adminPort = adminPort;
    this.#serverPort = serverPort;

    return this.getPublicProperties();
  }

  /**
   * Enqueues a transaction to RabbitMQ
   *
   * @param logger the logger object
   * @param idx the index of the tx in transactions.txt file
   */
  enqueueTx(logger: Logger, idx = 0) {
    const { rabbitmqUrl } = this.getPublicProperties();

    return new Promise<void>(async (resolve, reject) => {
      const txs = await txsPromise;
      let err: unknown;
      let rabbitMqTxSubmitProvider: RabbitMqTxSubmitProvider | null = null;

      try {
        rabbitMqTxSubmitProvider = new RabbitMqTxSubmitProvider(
          { rabbitmqUrl },
          { logger: contextLogger(logger, 'enqueueTx') }
        );
        await rabbitMqTxSubmitProvider.submitTx(txs[idx].txBodyUint8Array);
      } catch (error) {
        err = error;
      } finally {
        if (rabbitMqTxSubmitProvider) await rabbitMqTxSubmitProvider.close();
        if (err) reject(err);
        else resolve();
      }
    });
  }
}
