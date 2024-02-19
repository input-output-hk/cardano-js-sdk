import { BlockfrostWorker, BlockfrostWorkerConfig, getPool } from '../services';
import { CommonProgramOptions, PosgresProgramOptions, PostgresOptionDescriptions } from '../options';
import { Logger } from 'ts-log';
import { MissingProgramOption } from '../errors/MissingProgramOption';
import { SrvRecord } from 'dns';
import { createDnsResolver } from '../utils';
import { createLogger } from 'bunyan';
import { readFile } from 'fs/promises';

export const BLOCKFROST_WORKER_API_URL_DEFAULT = new URL('http://localhost:3000');
export const CACHE_TTL_DEFAULT = 24 * 60; // One day
export const CREATE_SCHEMA_DEFAULT = false;
export const DROP_SCHEMA_DEFAULT = false;
export const DRY_RUN_DEFAULT = false;
export const SCAN_INTERVAL_DEFAULT = 60; // One hour

export const availableNetworks = ['mainnet', 'preprod', 'preview', 'sanchonet'] as const;
export type AvailableNetworks = typeof availableNetworks[number];

export enum BlockfrostWorkerOptionDescriptions {
  BlockfrostApiFile = 'Blockfrost API Key file path',
  BlockfrostApiKey = 'Blockfrost API Key',
  CacheTTL = 'TTL of blockfrost cached metrics in minutes',
  CreateSchema = 'create the schema; useful for development',
  DropSchema = 'drop the schema; useful for development',
  DryRun = 'dry run; useful for tests',
  Network = 'network to run against',
  ScanInterval = 'interval between a scan and the next one in minutes'
}

export type BlockfrostWorkerArgs = CommonProgramOptions &
  PosgresProgramOptions<'DbSync'> &
  BlockfrostWorkerConfig & { blockfrostApiFile?: string };

export interface LoadBlockfrostWorkerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}

const blockfrostWorker = 'Blockfrost worker';

export const loadBlockfrostWorker = async (args: BlockfrostWorkerArgs, deps: LoadBlockfrostWorkerDependencies = {}) => {
  const logger = deps?.logger || createLogger({ level: args.loggerMinSeverity, name: 'blockfrost-worker' });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      {
        factor: args.serviceDiscoveryBackoffFactor,
        maxRetryTime: args.serviceDiscoveryTimeout
      },
      logger
    );
  const db = await getPool(dnsResolver, logger, args);

  if (args.blockfrostApiFile)
    try {
      args.blockfrostApiKey = (await readFile(args.blockfrostApiFile)).toString('utf-8').replace(/[\n\r]/g, '');
    } catch (error) {
      logger.error(error);

      throw error;
    }

  if (!args.blockfrostApiKey)
    throw new MissingProgramOption(blockfrostWorker, [
      BlockfrostWorkerOptionDescriptions.BlockfrostApiFile,
      BlockfrostWorkerOptionDescriptions.BlockfrostApiKey
    ]);

  if (!db)
    throw new MissingProgramOption(blockfrostWorker, [
      PostgresOptionDescriptions.ConnectionString,
      PostgresOptionDescriptions.ServiceDiscoveryArgs
    ]);

  return new BlockfrostWorker(args, { db, logger });
};
