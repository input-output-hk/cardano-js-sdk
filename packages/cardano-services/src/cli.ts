#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../scripts/patchRequire');
import {
  API_URL_DEFAULT,
  OGMIOS_URL_DEFAULT,
  ProgramOptionDescriptions,
  ServiceNames,
  loadHttpServer
} from './Program';
import { Command } from 'commander';
import { InvalidLoggerLevel } from './errors';
import { LogLevel } from 'bunyan';
import { URL } from 'url';
import { loggerMethodNames } from './util';
import onDeath from 'death';
const clear = require('clear');
const packageJson = require('../package.json');

clear();
// eslint-disable-next-line no-console
console.log('Cardano Services CLI');

const program = new Command('cardano-services');

program.version(packageJson.version);

program
  .command('start-server')
  .description('Start the HTTP server')
  .argument('<serviceNames...>', `List of services to attach: ${Object.values(ServiceNames).toString()}`)
  .option('--api-url <apiUrl>', ProgramOptionDescriptions.ApiUrl, (url) => new URL(url), new URL(API_URL_DEFAULT))
  .option('--enable-metrics <metricsEnabled>', ProgramOptionDescriptions.MetricsEnabled, false)
  .option('--db-connection-string <dbConnectionString>', ProgramOptionDescriptions.DbConnection, (url) =>
    new URL(url).toString()
  )
  .option(
    '--ogmios-url <ogmiosUrl>',
    ProgramOptionDescriptions.OgmiosUrl,
    (url) => new URL(url),
    new URL(OGMIOS_URL_DEFAULT)
  )
  .option(
    '--logger-min-severity <level>',
    ProgramOptionDescriptions.LoggerMinSeverity,
    (level) => {
      if (!loggerMethodNames.includes(level)) {
        throw new InvalidLoggerLevel(level);
      }
      return level;
    },
    'info'
  )
  .action(
    async (
      serviceNames: ServiceNames[],
      {
        apiUrl,
        dbConnectionString,
        loggerMinSeverity,
        metricsEnabled,
        ogmiosUrl
      }: {
        apiUrl: URL;
        dbConnectionString?: string;
        loggerMinSeverity: LogLevel;
        metricsEnabled: boolean;
        ogmiosUrl?: URL;
      }
    ) => {
      const server = await loadHttpServer({
        apiUrl: apiUrl || API_URL_DEFAULT,
        options: {
          dbConnectionString,
          loggerMinSeverity,
          metricsEnabled,
          ogmiosUrl
        },
        serviceNames
      });
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
