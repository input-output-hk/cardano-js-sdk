#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import { Command } from 'commander';
import { InvalidLoggerLevel } from './errors';
import { Logger } from 'ts-log';
import { createLogger } from 'bunyan';
import onDeath from 'death';

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
  .option('--logger-min-severity <level>', 'Log level', (level) => {
    if (!['trace', 'debug', 'info', 'warn', 'error'].includes(level)) {
      throw new InvalidLoggerLevel(level);
    }
    return level;
  })
  .action((options) => {
    const logger: Logger = createLogger({
      level: options.loggerMinSeverity,
      name: 'dgraph-projector'
    });
    // Todo: Initialize and start service
    logger.info('Started');
    onDeath(async () => {
      // Todo: Shutdown service
      logger.info('Process exiting');
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
