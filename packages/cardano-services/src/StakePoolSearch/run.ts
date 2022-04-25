/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import * as envalid from 'envalid';
import { DbSyncStakePoolSearchProvider } from './DbSyncStakePoolSearchProvider';
import { HttpServer } from '../Http';
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';
import { Pool } from 'pg';
import { StakePoolSearchHttpService } from './StakePoolSearchHttpService';
import { URL } from 'url';
import { config } from 'dotenv';
import { loggerMethodNames } from '../util';
import onDeath from 'death';

const envSpecs = {
  API_URL: envalid.url({ default: 'http://localhost:3000' }),
  DB_CONNECTION_STRING: envalid.str(),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' })
};

void (async () => {
  config();
  const env = envalid.cleanEnv(process.env, envSpecs);
  const apiUrl = new URL(env.API_URL);
  const connectionString = env.DB_CONNECTION_STRING;
  const logger: Logger = createLogger({
    level: env.LOGGER_MIN_SEVERITY as LogLevel,
    name: 'stake-pool-search-http-server'
  });
  let dbPool: Pool;
  try {
    dbPool = new Pool({ connectionString });
    const stakePoolSearchProvider = new DbSyncStakePoolSearchProvider(dbPool, logger);
    const stakePoolSearchHttpService = StakePoolSearchHttpService.create({ logger, stakePoolSearchProvider });
    const server = new HttpServer(
      {
        listen: {
          host: apiUrl.hostname,
          port: Number.parseInt(apiUrl.port)
        },
        name: 'StakePoolHttpServer'
      },
      { services: [stakePoolSearchHttpService] }
    );
    await server.initialize();
    await server.start();
    onDeath(async () => {
      await server.shutdown();
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(1);
    });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error(error);
  }
})();
