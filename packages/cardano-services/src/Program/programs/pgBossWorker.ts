import { HttpServer } from '../../Http/HttpServer';
import { Logger } from 'ts-log';
import { MissingProgramOption } from '../errors';
import { PgBossHttpService, PgBossServiceDependencies, PgBossWorkerArgs } from '../services/pgboss';
import { PostgresOptionDescriptions } from '../options';
import { SrvRecord } from 'dns';
import { createDnsResolver } from '../utils';
import { createLogger } from 'bunyan';
import { getConnectionConfig, getPool } from '../services/postgres';
import { getListen } from '../../Http/util';

export const PARALLEL_JOBS_DEFAULT = 10;
export const PG_BOSS_WORKER_API_URL_DEFAULT = new URL('http://localhost:3003');

export enum PgBossWorkerOptionDescriptions {
  ParallelJobs = 'Parallel jobs to run',
  Queues = 'Comma separated queue names',
  Schedules = 'File path for schedules configurations'
}

export interface LoadPgBossWorkerDependencies {
  dnsResolver?: (serviceName: string) => Promise<SrvRecord>;
  logger?: Logger;
}

const pgBossWorker = 'pg-boss-worker';

export class PgBossWorkerHttpServer extends HttpServer {
  constructor(cfg: PgBossWorkerArgs, deps: PgBossServiceDependencies) {
    const { apiUrl } = cfg;
    const { logger } = deps;
    const pgBossService = new PgBossHttpService(cfg, deps);
    pgBossService.onUnrecoverableError$.subscribe(() => {
      // eslint-disable-next-line unicorn/no-process-exit
      process.exit(1);
    });

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

  return new PgBossWorkerHttpServer(args, { connectionConfig$, db, logger });
};
