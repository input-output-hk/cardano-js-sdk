#!/usr/bin/env node
/* eslint-disable import/imports-first */
require('../../scripts/patchRequire');
import { Command } from 'commander';
import { HttpServer } from '../Http';
import { InvalidLoggerLevel } from '../errors';
import { LogLevel, createLogger } from 'bunyan';
import { TxSubmitHttpService } from './';
import { URL } from 'url';
import { loggerMethodNames } from '../util';
import { ogmiosTxSubmitProvider } from '@cardano-sdk/ogmios';
import onDeath from 'death';
const clear = require('clear');
const packageJson = require('../../package.json');
clear();
// eslint-disable-next-line no-console
console.log('Tx Submit CLI');

const program = new Command('tx-submit');

program.description('Submit transactions to the Cardano network').version(packageJson.version);

program
  .command('start-server')
  .description('Start the HTTP server')
  .option('--api-url <apiUrl>', 'Server URL', (url) => new URL(url))
  .option('--metrics-enabled <metricsEnabled>', 'Enable Prometheus Metrics', false)
  .option('--ogmios-url <ogmiosUrl>', 'Ogmios URL', (url) => new URL(url))
  .option('--logger-min-severity <level>', 'Log level', (level) => {
    if (!loggerMethodNames.includes(level)) {
      throw new InvalidLoggerLevel(level);
    }
    return level;
  })
  .action(
    async ({
      apiUrl,
      loggerMinSeverity,
      metricsEnabled,
      ogmiosUrl
    }: {
      apiUrl: URL;
      loggerMinSeverity: string;
      metricsEnabled: boolean;
      ogmiosUrl: URL;
    }) => {
      const logger = createLogger({ level: loggerMinSeverity as LogLevel, name: 'tx-submit-http-server' });
      const txSubmitProvider = ogmiosTxSubmitProvider({
        host: ogmiosUrl?.hostname,
        port: ogmiosUrl ? Number.parseInt(ogmiosUrl.port) : undefined,
        tls: ogmiosUrl?.protocol === 'wss'
      });
      const txSubmitHttpService = await TxSubmitHttpService.create({ logger, txSubmitProvider });
      const server = new HttpServer(
        {
          listen: {
            host: apiUrl.hostname,
            port: Number.parseInt(apiUrl.port)
          },
          metrics: {
            enabled: metricsEnabled
          },
          name: 'TxSubmitHttpServer'
        },
        { services: [txSubmitHttpService] }
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
