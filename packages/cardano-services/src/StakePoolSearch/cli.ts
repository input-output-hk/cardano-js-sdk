#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import { Command } from 'commander';
import { DbSyncStakePoolSearchProvider } from './DbSyncStakePoolSearchProvider';
import { InvalidLoggerLevel } from '../errors';
import { LogLevel, createLogger } from 'bunyan';
import { Pool } from 'pg';
import { StakePoolSearchHttpServer } from './StakePoolSearchHttpServer';
import { URL } from 'url';
import { loggerMethodNames } from '../util';
import onDeath from 'death';
const clear = require('clear');
const packageJson = require('../../package.json');

clear();
// eslint-disable-next-line no-console
console.log('Stake Pool Search CLI');

const program = new Command('tx-submit');

program.description('Search stake pools of the Cardano network').version(packageJson.version);

program
  .command('start-server')
  .description('Start the HTTP server')
  .option('--api-url <apiUrl>', 'Server URL', (url) => new URL(url))
  .option('--metrics-enabled <metricsEnabled>', 'Enable Prometheus Metrics', false)
  .option('--db-connection-string <dbConnectionString>', 'Db Connection', (connection) => connection)
  .option('--logger-min-severity <level>', 'Log level', (level) => {
    if (!loggerMethodNames.includes(level)) {
      throw new InvalidLoggerLevel(level);
    }
    return level;
  })
  .action(
    async ({
      apiUrl,
      dbConnectionString,
      loggerMinSeverity,
      metricsEnabled
    }: {
      apiUrl: URL;
      dbConnectionString: string;
      loggerMinSeverity: string;
      metricsEnabled: boolean;
    }) => {
      const logger = createLogger({ level: loggerMinSeverity as LogLevel, name: 'stake-pool-search-http-server' });
      const dbPool = new Pool({ connectionString: dbConnectionString });
      const stakePoolSearchProvider = new DbSyncStakePoolSearchProvider(dbPool, logger);
      const server = StakePoolSearchHttpServer.create(
        {
          logger,
          stakePoolSearchProvider
        },
        {
          listen: {
            host: apiUrl.hostname,
            port: Number.parseInt(apiUrl.port)
          },
          metrics: {
            enabled: metricsEnabled
          }
        }
      );
      await server.initialize();
      await server.start();
      onDeath(async () => {
        await server.shutdown();
        process.exit(1);
      });
    }
  );

if (process.argv.slice(2).length === 0) {
  program.outputHelp();
  process.exit(1);
} else {
  program.parseAsync(process.argv).catch((error) => {
    // eslint-disable-next-line no-console
    console.error(error);
    process.exit(0);
  });
}
