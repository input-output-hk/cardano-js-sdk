import { ChildProcess, fork } from 'child_process';
import { Logger } from 'ts-log';
import { ServiceNames } from '@cardano-sdk/cardano-services';
import { getLogger } from '../factories';
import { setupRabbitMQContainer } from '../../../rabbitmq/test/jest-setup/docker';
import path from 'path';

const CONTAINER_NAME = 'rabbitmq-load-test';

/**
 * Cardano services parameters.
 */
export class ServicesParams {
  /**
   * The list of services to be started.
   */
  services: [ServiceNames];

  /**
   * Should be the full URI to the cardano-services endpoint such as 'http://localhost:3456'.
   */
  apiUrl: string;

  /**
   * Whether to enable or not monitoring metrics in your instance of cardano-services.
   */
  enableMetrics: boolean;

  /**
   * Should be the full URI to the DBSync database such as 'http://localhost:5432'.
   */
  dbConnectionString: string;

  /**
   * Should be the absolute path of the configuration file of the node.
   */
  cardanoNodeConfigPath: string;

  /**
   * Sets a query TTL so the service remembers the results of previously executed queries. That's it,
   * The service automatically remembers the result for the given ttl (in milliseconds).
   */
  dbQueriesCacheTtl: number;

  /**
   * Number of milliseconds that must pass before the server polls the database.
   */
  dbPollInterval: number;

  /**
   * Whether to enable or not RabbitMQ.
   */
  useQueue: boolean;

  /**
   * Should be the full URI to the Ogmios endpoint such as 'ws://localhost:1338'.
   */
  ogmiosUrl: string;

  /**
   * Should be the full URI to the RabbitMQUrl endpoint such as 'ws://localhost:1338'.
   */
  rabbitMQUrl: string;

  /**
   * The lowest severity of log that will be log.
   */
  loggerMinSeverity: string;

  /**
   * Whether parallel transaction submision is enabled or not.
   */
  parallel: boolean;

  /**
   * Number of transaction to be submited in parallel.
   */
  parallelTxs: number;
}

/**
 * Cardano services wrapper class. This class allows to configure, start and stop the cardano services.
 */
export class CardanoServices {
  #server: ChildProcess;
  #worker: ChildProcess;
  #param: ServicesParams;
  static logger: Logger;

  /**
   * Initializes a new instance of the CardanoServices class.
   *
   * @param params The service parameters.
   */
  constructor(params: ServicesParams) {
    this.#param = params;
    CardanoServices.logger = getLogger(params.loggerMinSeverity ? params.loggerMinSeverity : 'info');
  }

  /**
   * Starts the cardano services.
   */
  async start() {
    if (this.#param.useQueue) await setupRabbitMQContainer(CONTAINER_NAME);

    this.#server = await CardanoServices.runCli(
      [
        'start-server',
        '--api-url',
        this.#param.apiUrl,
        '--enable-metrics',
        this.#param.enableMetrics?.toString(),
        '--db-connection-string',
        this.#param.dbConnectionString,
        '--cardano-node-config-path',
        this.#param.cardanoNodeConfigPath,
        '--db-queries-cache-ttl',
        this.#param.dbQueriesCacheTtl?.toString(),
        '--db-poll-interval',
        this.#param.dbPollInterval?.toString(),
        '--use-queue',
        this.#param.useQueue?.toString(),
        '--ogmios-url',
        this.#param.ogmiosUrl,
        '--rabbitmq-url',
        this.#param.rabbitMQUrl,
        '--logger-min-severity',
        this.#param.loggerMinSeverity,
        ...this.#param.services
      ],
      '"msg":"Started'
    );

    if (this.#param.parallel) {
      this.#worker = await CardanoServices.runCli(
        [
          'start-worker',
          '--logger-min-severity',
          this.#param.loggerMinSeverity,
          '--ogmios-url',
          this.#param.ogmiosUrl,
          '--rabbitmq-url',
          this.#param.rabbitMQUrl,
          ...(this.#param.parallel ? ['--parallel', '--parallel-txs', this.#param.parallelTxs?.toString()] : [])
        ],
        '"msg":"TxSubmitWorker: starting'
      );
    }
  }

  /**
   * Stops the cardano services.
   */
  async stop() {
    await new Promise<void>((resolve) => (this.#server?.kill() ? this.#server.on('close', resolve) : resolve()));
    await new Promise<void>((resolve) => (this.#worker?.kill() ? this.#worker.on('close', resolve) : resolve()));
  }

  /**
   * Runs a CLI command an redirect its stderr to our main process stdout.
   *
   * @param args The arguments of the CLI command.
   * @param startedString The log prefix we will filter in.
   * @private
   */
  private static runCli(args: string[], startedString: string) {
    return new Promise<ChildProcess>((resolve, reject) => {
      const proc = fork(
        path.join(__dirname, '..', '..', '..', '..', 'cardano-services', 'dist', 'cjs', 'cli.js'),
        args,
        {
          stdio: 'pipe'
        }
      );

      const logChunk = (method: typeof CardanoServices.logger.info, chunk: string) => {
        for (const line of chunk.split('\n')) {
          if (line) {
            let msg = line;

            try {
              ({ msg } = JSON.parse(line));
              // eslint-disable-next-line no-empty
            } catch {}

            method(`${args[0]}: ${msg}`);
          }
        }
      };

      proc.stderr!.once('data', (data) => reject(new Error(data.toString())));
      proc.stderr!.on('data', (data) => logChunk(CardanoServices.logger.error.bind(this.#logger), data.toString()));
      proc.stdout!.on('data', (data) => {
        const chunk = data.toString();

        logChunk(CardanoServices.logger.info.bind(CardanoServices.logger), chunk);
        if (chunk.includes(startedString)) resolve(proc);
      });
      proc.once('error', reject);
    });
  }
}
