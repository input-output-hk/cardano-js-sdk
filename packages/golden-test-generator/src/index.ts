#!/usr/bin/env node
/* eslint-disable no-console */
import { AddressBalancesResponse, getOnChainAddressBalances } from './AddressBalance';
import { Command } from 'commander';
import { GetBlocksResponse, getBlocks } from './Block';
import { Options, SingleBar } from 'cli-progress';
import { ensureDir, writeFile } from 'fs-extra';
import { prepareContent } from './Content';
import JSONBig from 'json-bigint';
import chalk from 'chalk';
import hash from 'object-hash';
import path from 'node:path';

const clear = require('clear');
const packageJson = require('../package.json');

clear();
console.log(chalk.blue('Cardano Golden Test Generator'));

const createProgressBar = (lastblockHeight: number) =>
  new SingleBar({
    barCompleteChar: '\u2588',
    barIncompleteChar: '\u2591',
    format: `Syncing from genesis to block ${lastblockHeight} | ${chalk.blue(
      '{bar}'
    )} | {percentage}% || {value}/{total} Blocks`,
    hideCursor: true,
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
  .requiredOption('--out-dir [outDir]', 'File path to write results to')
  .action(async (addresses: string[], { atBlocks, outDir }) => {
    try {
      const { ogmiosHost, ogmiosPort, ogmiosTls } = program.opts();
      const atBlockHeights = atBlocks.sort((a: number, b: number) => a - b);
      const lastBlockHeight = atBlockHeights[atBlockHeights.length - 1];
      const progress = createProgressBar(lastBlockHeight);
      await ensureDir(outDir);
      progress.start(lastBlockHeight, 0);
      const { balances, metadata } = await getOnChainAddressBalances(addresses, atBlockHeights, {
        ogmiosConnectionConfig: { host: ogmiosHost, port: ogmiosPort, tls: ogmiosTls },
        onBlock: (blockHeight) => {
          progress.update(blockHeight);
        }
      });
      const content = await prepareContent<AddressBalancesResponse['balances']>(metadata, balances);
      progress.stop();
      const fileName = path.join(outDir, `address-balances-${hash(content)}.json`);

      console.log(`Writing ${fileName}`);
      await writeFile(fileName, JSONBig.stringify(content, undefined, 2));
      process.exit(0);
    } catch (error) {
      console.error(error);
      process.exit(1);
    }
  });

program
  .command('get-block')
  .description('Dump the requested blocks in their raw structure')
  .argument('[blockHeights]', 'Comma-separated list of blocks by number', (blockHeights) =>
    blockHeights
      .split(',')
      .filter((b) => b !== '')
      .map((blockHeight) => Number.parseInt(blockHeight))
  )
  .requiredOption('--out-dir [outDir]', 'File path to write results to')
  .action(async (blockHeights: number[], { outDir }) => {
    try {
      const { ogmiosHost, ogmiosPort, ogmiosTls } = program.opts();
      const sortedblockHeights = blockHeights.sort((a: number, b: number) => a - b);
      const lastblockHeight = sortedblockHeights[sortedblockHeights.length - 1];
      const progress = createProgressBar(lastblockHeight);
      await ensureDir(outDir);
      progress.start(lastblockHeight, 0);
      const { blocks, metadata } = await getBlocks(sortedblockHeights, {
        logger: console,
        ogmiosConnectionConfig: { host: ogmiosHost, port: ogmiosPort, tls: ogmiosTls },
        onBlock: (blockHeight) => {
          progress.update(blockHeight);
        }
      });
      progress.stop();
      const content = await prepareContent<GetBlocksResponse['blocks']>(metadata, blocks);
      const fileName = path.join(outDir, `blocks-${hash(content)}.json`);

      console.log(`Writing ${fileName}`);
      await writeFile(fileName, JSONBig.stringify(content, undefined, 2));
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
