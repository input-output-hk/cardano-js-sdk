import {
  CommonProgramOptions,
  PosgresProgramOptions,
  PostgresOptionDescriptions,
  throwMissingMissingProviderUrlOption
} from '../options';
import { HttpServer } from '../../Http/HttpServer';
import { Logger } from 'ts-log';
import { MissingProgramOption } from '../errors';
import { PgBossHttpService, PgBossServiceConfig, PgBossServiceDependencies } from '../services/pgboss';
import { STAKE_POOL_METRICS_UPDATE } from '@cardano-sdk/projection-typeorm';
import { ServiceNames } from './types';
import { SrvRecord } from 'dns';
import { createDnsResolver } from '../utils';
import { createLogger } from 'bunyan';
import { getConnectionConfig, getPool } from '../services/postgres';
import { getListen } from '../../Http/util';

export const PARALLEL_JOBS_DEFAULT = 10;
export const PG_BOSS_WORKER_API_URL_DEFAULT = new URL('http://localhost:3003');

export enum PgBossWorkerOptionDescriptions {
  ParallelJobs = 'Parallel jobs to run',
  Queues = 'Comma separated queue names'
}

export type PgBossWorkerArgs = CommonProgramOptions &
  PosgresProgramOptions<'DbSync'> &
  PosgresProgramOptions<'StakePool'> &
  PgBossServiceConfig;

export interface LoadPgBossWorkerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}

const pgBossWorker = 'pg-boss-worker';

export interface PgBossWorkerConfig extends PgBossServiceConfig {
  apiUrl: URL;
}

export class PgBossWorkerHttpServer extends HttpServer {
  constructor(cfg: PgBossWorkerConfig, deps: PgBossServiceDependencies) {
    const { apiUrl } = cfg;
    const { logger } = deps;
    const pgBossService = new PgBossHttpService(cfg, deps);

    super(
      { listen: getListen(apiUrl), name: pgBossWorker },
      { logger, runnableDependencies: [], services: [pgBossService] }
    );
  }
}

export const loadPgBossWorker = async (args: PgBossWorkerArgs, deps: LoadPgBossWorkerDependencies = {}) => {
  const logger = deps?.logger || createLogger({ level: args.loggerMinSeverity, name: pgBossWorker });
  const dnsResolver =
    deps?.dnsResolver ||
    createDnsResolver(
      { factor: args.serviceDiscoveryBackoffFactor, maxRetryTime: args.serviceDiscoveryTimeout },
      logger
    );
  const connectionConfig$ = getConnectionConfig(dnsResolver, pgBossWorker, 'StakePool', args);
  const db = await getPool(dnsResolver, logger, args);

  if (!db) throw new MissingProgramOption(pgBossWorker, PostgresOptionDescriptions.ConnectionString);

  if (args.queues.includes(STAKE_POOL_METRICS_UPDATE) && !args.stakePoolProviderUrl)
    throwMissingMissingProviderUrlOption(STAKE_POOL_METRICS_UPDATE, ServiceNames.StakePool);

  return new PgBossWorkerHttpServer(args, { connectionConfig$, db, logger });
};
