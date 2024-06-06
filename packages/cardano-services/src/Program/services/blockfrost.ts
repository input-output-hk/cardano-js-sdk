import { BlockfrostService } from '../../Blockfrost/index.js';
import { HttpServer, getListen } from '../../Http/index.js';
import type { BlockfrostServiceConfig, BlockfrostServiceDependencies } from '../../Blockfrost/index.js';
import type { Pool } from 'pg';

export type BlockfrostWorkerConfig = BlockfrostServiceConfig & {
  apiUrl: URL;
  createSchema: boolean;
  dropSchema: boolean;
  dryRun: boolean;
  scanInterval: number;
};

export type BlockfrostWorkerDependencies = BlockfrostServiceDependencies;

const schema = [
  `
CREATE TABLE IF NOT EXISTS blockfrost.pool_metric (
  pool_hash_id integer NOT NULL,
  last_reward_epoch smallint NOT NULL,
  cache_time double precision NOT NULL,
  blocks_created integer NOT NULL,
  delegators integer NOT NULL,
  active_stake numeric NOT NULL,
  live_stake numeric NOT NULL,
  live_pledge numeric NOT NULL,
  saturation double precision NOT NULL,
  reward_address varchar NOT NULL,
  extra varchar NOT NULL,
  status varchar NOT NULL
)`,
  'CREATE UNIQUE INDEX IF NOT EXISTS "blockfrost.pool_metric_id" ON blockfrost.pool_metric (pool_hash_id)'
];

export class BlockfrostWorker extends HttpServer {
  #blockfrostService: BlockfrostService;
  #createSchema: boolean;
  #db: Pool;
  #dropSchema: boolean;
  #dryRun: boolean;
  #scanInterval: number;
  #timeOut?: NodeJS.Timeout;

  constructor(cfg: BlockfrostWorkerConfig, deps: BlockfrostWorkerDependencies) {
    const { apiUrl, createSchema, dropSchema, dryRun, scanInterval } = cfg;
    const { db, logger } = deps;
    const blockfrostService = new BlockfrostService(cfg, deps);

    super(
      { listen: getListen(apiUrl), name: 'blockfrost-worker' },
      { logger, runnableDependencies: [], services: [blockfrostService] }
    );

    this.#blockfrostService = blockfrostService;
    this.#createSchema = createSchema;
    this.#db = db;
    this.#dropSchema = dropSchema;
    this.#dryRun = dryRun;
    this.#scanInterval = scanInterval;
  }

  protected async initializeImpl() {
    await super.initializeImpl();

    if (!this.#dryRun) {
      if (this.#dropSchema) {
        this.logger.info('Going to drop the schema');
        await this.#db.query('DROP SCHEMA IF EXISTS blockfrost CASCADE');
        this.logger.info('Schema dropped');
      }

      if (this.#createSchema) {
        this.logger.info('Going to create the schema');
        await this.#db.query('CREATE SCHEMA IF NOT EXISTS blockfrost');
        this.logger.info('Schema created');
      }

      this.logger.info('Going to create tables and indexes');
      for (const obj of schema) await this.#db.query(obj);
      this.logger.info('Tables and indexes created');
    }
  }

  protected async startImpl() {
    await super.startImpl();

    this.run();
  }

  protected async shutdownImpl() {
    if (this.#timeOut) clearTimeout(this.#timeOut);

    await super.shutdownImpl();
  }

  private dryRun() {
    this.logger.info('Dry run');

    return new Promise((resolve) => setTimeout(resolve, 100));
  }

  private async main() {
    const start = Date.now();

    this.#timeOut = undefined;
    this.logger.info('Starting new run');

    try {
      await (this.#dryRun ? this.dryRun() : this.#blockfrostService.refreshCache());
    } catch (error) {
      this.logger.error('Process failed with', error);
    }

    const restart = this.#scanInterval * 60_000 - (Date.now() - start);

    if (restart <= 0) {
      this.logger.info('Restarting immediately due to scanInterval expired in previous run');
      this.run();
    } else {
      this.logger.info(`Sleeping for ${restart} milliseconds to start next run`);
      this.#timeOut = setTimeout(() => this.run(), restart);
    }
  }

  private run() {
    this.main().catch((error) => {
      this.logger.error('Error while run', error);
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(1);
    });
  }
}
