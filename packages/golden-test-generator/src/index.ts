#!/usr/bin/env node
/* eslint-disable no-console */
import { AddressBalancesResponse, getOnChainAddressBalances } from './AddressBalance';
import { Command } from 'commander';
import { GeneratorMetadata, prepareContent } from './Content';
import { GetChainSyncEventsResponse, getChainSyncEvents as chainSync } from './ChainSyncEvents';
import { Options, SingleBar } from 'cli-progress';
import { createLogger } from 'bunyan';
import { ensureDir, writeFile } from 'fs-extra';
import { toSerializableObject } from '@cardano-sdk/util';
import chalk from 'chalk';
import clear from 'clear';
import hash from 'object-hash';
import path from 'path';

const packageJson = require('../../package.json');

clear();
console.log(chalk.blue('Cardano Golden Test Generator'));

const createProgressBar = (lastblockHeight: number) =>
  new SingleBar({
    barCompleteChar: '\u2588',
    barIncompleteChar: '\u2591',
    format: `Syncing from genesis to block ${lastblockHeight} | ${chalk.blue(
      '{bar}'
    )} | {percentage}% || {value}/{total} Blocks`,
    hideCursor: false,
    renderThrottle: 300
  } as Options);

const program = new Command('cardano-golden-test-generator');

program
  .option('--ogmios-host [ogmiosHost]', 'Ogmios host. Defaults to localhost')
  .option('--ogmios-port [ogmiosPort]', 'Ogmios TCP port. Defaults to 1337', (port) => Number.parseInt(port))
  .option('--ogmios-tls [ogmiosTls]', 'Is Ogmios being served over a secure connection?. Defaults to false', (port) =>
    Number.parseInt(port)
  );

program
  .command('address-balance')
  .description('Balance of addresses, determined by syncing the chain from genesis')
  .argument('[addresses]', 'Comma-separated list of addresses', (addresses) =>
    addresses.split(',').filter((a) => a !== '')
  )
  .requiredOption('--at-blocks [atBlocks]', 'Balance of the addresses at block heights', (heights) =>
    heights
      .split(',')
      .filter((b) => b !== '')
      .map((height) => Number.parseInt(height))
  )
  .option('--log-level [logLevel]', 'Minimum log level', 'info')
  .requiredOption('--out-dir [outDir]', 'File path to write results to')
  .action(async (addresses: string[], { atBlocks, logLevel, outDir }) => {
    try {
      const { ogmiosHost, ogmiosPort, ogmiosTls } = program.opts();
      const atBlockHeights = atBlocks.sort((a: number, b: number) => a - b);
      const lastBlockHeight = atBlockHeights[atBlockHeights.length - 1];
      const logger = createLogger({ level: logLevel, name: 'address-balance' });
      const progress = createProgressBar(lastBlockHeight);
      await ensureDir(outDir);
      progress.start(lastBlockHeight, 0);
      const { balances, metadata } = await getOnChainAddressBalances(addresses, atBlockHeights, {
        logger,
        ogmiosConnectionConfig: { host: ogmiosHost, port: ogmiosPort, tls: ogmiosTls },
        onBlock: (blockHeight) => progress.update(blockHeight)
      });
      const content = await prepareContent<AddressBalancesResponse['balances']>(metadata, balances);
      progress.stop();
      const fileName = path.join(outDir, `address-balances-${hash(content)}.json`);

      logger.info(`Writing ${fileName}`);
      await writeFile(fileName, JSON.stringify(toSerializableObject(content), undefined, 2));
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    }
  });

const mapBlockHeights = (blockHeights: string) =>
  blockHeights
    .split(',')
    .filter((b) => b !== '')
    .flatMap((blockHeightSpec) => {
      const [from, to] = blockHeightSpec.split('..').map((blockHeight) => Number.parseInt(blockHeight));
      if (!to) {
        // 0 is not supported, as such range doesn't make sense
        if (!Number.isNaN(from)) return [from]; // single block
        throw new Error('blockHeights must be either numbers or ranges, see --help');
      }
      const result: number[] = [];
      for (let blockHeight = from; blockHeight <= to; blockHeight++) {
        result.push(blockHeight);
      }
      return result;
    });

program
  .command('chain-sync-events')
  .description('Dump the requested blocks (rollForward) in their raw structure and simulate rollbacks')
  .argument(
    '[blockHeights]',
    `Comma-separated sorted list of blocks by number.
  Use "-" for rollback to a block, e.g. 10,11,-10,11
  Use ".." for block ranges (inclusive), e.g. 0..9`
  )
  .requiredOption('--out-dir [outDir]', 'File path to write results to')
  .option('--log-level [logLevel]', 'Minimum log level', 'info')
  .action(async (blockHeightsInput: string, { logLevel, outDir }) => {
    try {
      const { ogmiosHost, ogmiosPort, ogmiosTls } = program.opts();
      const blockHeights = mapBlockHeights(blockHeightsInput);
      const lastblockHeight = blockHeights[blockHeights.length - 1];
      const logger = createLogger({ level: logLevel, name: 'chain-sync-events' });
      const progress = createProgressBar(lastblockHeight);
      await ensureDir(outDir);
      progress.start(lastblockHeight, 0);
      const { events: data, metadata } = await chainSync(blockHeights, {
        logger,
        ogmiosConnectionConfig: { host: ogmiosHost, port: ogmiosPort, tls: ogmiosTls },
        onBlock: (blockHeight) => {
          progress.update(blockHeight);
        }
      });
      const fullMetadata: GeneratorMetadata['metadata'] = {
        ...metadata,
        options: {
          blockHeights: blockHeightsInput
        }
      };
      progress.stop();
      const content = await prepareContent<GetChainSyncEventsResponse['events']>(fullMetadata, data);
      const fileName = path.join(outDir, `blocks-${hash(content)}.json`);

      logger.info(`Writing ${fileName}`);
      await writeFile(fileName, JSON.stringify(toSerializableObject(content), undefined, 2));
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    }
  });

program.version(packageJson.version);
if (process.argv.slice(2).length === 0) {
  program.outputHelp();
  process.exit(1);
} else {
  program.parseAsync(process.argv).catch((error) => {
    console.error(error);
    process.exit(0);
  });
}

type PromiseType<P> = P extends Promise<infer T> ? T : never;
export type ChainSyncData = PromiseType<ReturnType<typeof prepareContent<GetChainSyncEventsResponse['events']>>>;
