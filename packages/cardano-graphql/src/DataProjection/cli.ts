#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import { Command } from 'commander';
import { InvalidLoggerLevel } from './errors';
import { Logger } from 'ts-log';
import { Service } from './Service';
import { URL } from 'url';
import { createLogger } from 'bunyan';
import fs from 'fs';
import onDeath from 'death';
import path from 'path';

const clear = require('clear');
const packageJson = require('../../package.json');

clear();
// eslint-disable-next-line no-console
console.log('Dgraph Projector');

const program = new Command('projector');

program
  .name('dgraph-projector')
  .description('Project data from on-chain and off-chain sources into Dgraph')
  .version(packageJson.version);

program
  .command('start')
  .description('Start the service')
  .option('--dgraph-url <dgraphUrl>', 'Dgraph URL', (url) => new URL(url))
  .option('--ogmios-url <ogmiosUrl>', 'Ogmios URL', (url) => new URL(url))
  .option('--logger-min-severity <level>', 'Log level', (level) => {
    if (!['trace', 'debug', 'info', 'warn', 'error'].includes(level)) {
      throw new InvalidLoggerLevel(level);
    }
    return level;
  })
  .action(async ({ dgraphUrl, loggerMinSeverity, ogmiosUrl }) => {
    const logger: Logger = createLogger({
      level: loggerMinSeverity,
      name: 'dgraph-projector'
    });
    const service = new Service(
      {
        dgraph: {
          address: dgraphUrl?.toString() || 'http://localhost:8080',
          schema: fs.readFileSync(path.resolve(__dirname, '..', '..', 'dist', 'schema.graphql'), 'utf-8')
        },
        ogmios: {
          connection: {
            host: ogmiosUrl?.hostname,
            port: ogmiosUrl?.port,
            tls: ogmiosUrl?.protocol === 'wss'
          }
        }
      },
      logger
    );
    await service.initialize();
    await service.start();
    onDeath(async () => {
      await service.shutdown();
      process.exit(1);
    });
  });

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
