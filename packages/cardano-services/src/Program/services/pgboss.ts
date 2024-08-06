import {
  BlockEntity,
  CurrentPoolMetricsEntity,
  PgConnectionConfig,
  PoolDelistedEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  PoolRewardsEntity,
  StakePoolEntity,
  createDataSource,
  createPgBoss,
  isRecoverableTypeormError
} from '@cardano-sdk/projection-typeorm';
import { CommonProgramOptions, PosgresProgramOptions } from '../options';
import { DataSource } from 'typeorm';
import { HealthCheckResponse } from '@cardano-sdk/core';
import { HttpService } from '../../Http/HttpService';
import { Logger } from 'ts-log';
import {
  Observable,
  Subject,
  Subscription,
  catchError,
  concat,
  finalize,
  from,
  merge,
  share,
  switchMap,
  tap
} from 'rxjs';
import { PgBossQueue, WorkerHandler, queueHandlers } from '../../PgBoss';
import { Pool } from 'pg';
import { Router } from 'express';
import { ScheduleConfig } from '../../util/schedule';
import { StakePoolMetadataProgramOptions } from '../options/stakePoolMetadata';
import { contextLogger } from '@cardano-sdk/util';
import { retryBackoff } from 'backoff-rxjs';
import PgBoss from 'pg-boss';

/** The entities required by the job handlers */
export const pgBossEntities: Function[] = [
  CurrentPoolMetricsEntity,
  BlockEntity,
  PoolDelistedEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  PoolRewardsEntity,
  StakePoolEntity
];

export const createPgBossDataSource = (connectionConfig$: Observable<PgConnectionConfig>, logger: Logger) =>
  // TODO: use createObservableDataSource from projection-typeorm package.
  // A challenge in doing that is that we call subscriber.error on retryable errors in order to reconnect.
  // Doing that with createObservableDataSource will 'destroy' the data source that's currently used,
  // so pg-boss is then unable to update job status and it stays 'active', not available for the newly
  // recreated worker to be picked up.
  // TODO: this raises another question - what happens when database connection drops while working on a job?
  // Will it stay 'active' forever, or will pg-boss eventually update it due to some sort of timeout?
  connectionConfig$.pipe(
    switchMap((connectionConfig) =>
      from(
        (async () => {
          const dataSource = createDataSource({
            connectionConfig,
            entities: pgBossEntities,
            extensions: { pgBoss: true },
            logger,
            options: { migrationsRun: false }
          });
          await dataSource.initialize();
          const pgbossSchema = await dataSource.query(
            "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'pgboss'"
          );
          if (pgbossSchema.length === 0) {
            await dataSource.destroy();
            throw new Error('Database schema is not ready. Please make sure projector is running.');
          }
          return dataSource;
        })()
      )
    )
  );

export type PgBossWorkerArgs = CommonProgramOptions &
  StakePoolMetadataProgramOptions &
  PosgresProgramOptions<'DbSync'> &
  PosgresProgramOptions<'StakePool'> & {
    parallelJobs: number;
    queues: PgBossQueue[];
    schedules: Array<ScheduleConfig>;
  };

export interface PgBossServiceDependencies {
  connectionConfig$: Observable<PgConnectionConfig>;
  db: Pool;
  logger: Logger;
}

const hasDriverError = (error: unknown): error is { driverError: unknown } =>
  error instanceof Object && 'driverError' in error;

const isRecoverableError = (error: unknown) =>
  isRecoverableTypeormError(error) ||
  (hasDriverError(error) &&
    error.driverError instanceof Error &&
    error.driverError.message === 'invalid message format');

export class PgBossHttpService extends HttpService {
  #config: PgBossWorkerArgs;
  #dataSource$: Observable<DataSource>;
  #db: Pool;
  #subscription?: Subscription;
  #health: HealthCheckResponse = { ok: false, reason: 'PgBossHttpService not started' };
  onUnrecoverableError$ = new Subject<unknown>();

  constructor(cfg: PgBossWorkerArgs, deps: PgBossServiceDependencies) {
    const { connectionConfig$, db, logger } = deps;

    super('pg-boss-service', { healthCheck: async () => this.#health }, Router(), __dirname, logger);

    this.#config = cfg;
    this.#db = db;
    this.#dataSource$ = createPgBossDataSource(connectionConfig$, this.logger);
  }

  protected async startImpl() {
    await super.startImpl();

    if (this.#subscription) {
      this.logger.warn('Unsubscribing from an observable which should never happen');
      this.#subscription.unsubscribe();
    }

    // Used for later use of firstValueFrom() to avoid it subscribes again
    const sharedWork$ = this.work().pipe(share());

    return new Promise<void>((resolve, reject) => {
      // Subscribe to work() to create the first DataSource and start pg-boss
      this.#subscription = sharedWork$.subscribe({
        error: (error) => {
          this.onUnrecoverableError$.next(error);
          reject(error);
        },
        next: () => resolve()
      });
    });
  }

  protected async shutdownImpl() {
    await super.shutdownImpl();

    this.#subscription?.unsubscribe();
  }

  private work() {
    return this.#dataSource$.pipe(
      switchMap((dataSource) => {
        const pgBoss = createPgBoss(null, this.logger, dataSource);

        return concat(
          from(pgBoss.start()),
          merge(
            ...this.#config.queues.map((queue) => this.createQueue(dataSource, pgBoss, queue, this.#db)),
            ...this.#config.schedules.map((schedule) => this.createSchedule(dataSource, pgBoss, schedule, this.#db))
          )
        ).pipe(finalize(() => pgBoss.stop().catch((error) => this.logger.warn('Error stopping pgBoss', error))));
      }),
      tap(() => (this.#health = { ok: true })),
      retryBackoff({
        // TODO: set this in the config
        initialInterval: 10,
        maxInterval: 5000,
        resetOnSuccess: true,
        // This ensures that if an error which can't be retried arrives here is handled as a FATAL error
        shouldRetry: (error: unknown) => {
          const retry = isRecoverableError(error);
          this.logger.debug('work() shouldRetry', retry, error);

          this.#health = {
            ok: false,
            reason: retry ? 'DataBase error: reconnecting...' : 'Fatal error! Shutting down'
          };

          return retry;
        }
      }),
      catchError((error) => {
        this.logger.error('Fatal worker error', error);
        throw error;
      })
    );
  }

  private createQueue(dataSource: DataSource, pgBoss: PgBoss, queue: PgBossQueue, db: Pool) {
    const logger = contextLogger(this.logger, queue);
    const handler = queueHandlers[queue]({
      dataSource,
      db,
      logger,
      ...this.#config
    });

    logger.info('Creating worker');
    return this.workQueue(handler, logger, pgBoss, queue);
  }

  private workQueue(handler: WorkerHandler, logger: Logger, pgBoss: PgBoss, queue: PgBossQueue) {
    return new Observable((subscriber) => {
      const workOption = {
        teamConcurrency: this.#config.parallelJobs,
        teamRefill: true,
        teamSize: this.#config.parallelJobs
      };

      const baseHandler = async (job: PgBoss.JobWithDoneCallback<unknown, unknown>) => {
        const { id, data } = job;

        try {
          logger.info(`Job ${id} started`, data);

          await handler(data);

          // Emit an unused value just to:
          // - make the tap() in work() to set the healthy state
          // - reset the retryBackoff in work() to reset the counter of its retry strategy
          subscriber.next(null);

          logger.info(`Job ${id} successfully completed`, data);
        } catch (error) {
          // pg-boss may retry the job eventually, but this is opaque,
          // so the error is logged here for more insight
          logger.error(`Job ${id} got error`, error);

          if (isRecoverableError(error)) {
            logger.info('The error is recoverable: re-creating DB connection');
            // Emit the error so retryBackoff in work() can do its job
            subscriber.error(error);
          }

          throw error;
        }
      };

      pgBoss.work(queue, workOption, baseHandler).catch((error: unknown) => {
        logger.error(`Error while starting worker for '${queue}'`, error);
        subscriber.error(error);
      });
    });
  }

  private createSchedule(
    _dataSource: DataSource,
    pgBoss: PgBoss,
    schedule: ScheduleConfig,
    _db: Pool
  ): Observable<unknown> {
    const { queue, cron, data, scheduleOptions } = schedule;
    const logger = contextLogger(this.logger, queue);

    return new Observable((subscriber) => {
      pgBoss.schedule(queue, cron, data, scheduleOptions).catch((error: unknown) => {
        logger.error('Error while scheduling', error);
        subscriber.error(error);
      });
      logger.info('Schedule created');
    });
  }
}
