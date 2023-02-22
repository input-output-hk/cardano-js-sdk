import 'reflect-metadata';
import { DataSource, DataSourceOptions } from 'typeorm';
import { Observable, Subject, concatMap, from, map, shareReplay, switchMap } from 'rxjs';
import { PgProjectionSinks, WithPgContext, WithPgSinkMetadata } from './types';
import { PgStabilityWindowBuffer } from './PgStabilityWindowBuffer';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { Sinks } from '../types';
import { StabilityWindowBlockEntity } from './entity/StabilityWindowBlock.entity';
import { WithLogger } from '@cardano-sdk/util';
import { typeormLogger } from './logger';
import { withEventContext, withStaticContext } from '../../operators';
import omit from 'lodash/omit';
import uniq from 'lodash/uniq';

type PostgresConnectionOptions = DataSourceOptions & { type: 'postgres' };

export type PgConnectionConfig = Pick<
  PostgresConnectionOptions,
  'host' | 'port' | 'database' | 'username' | 'password' | 'ssl'
>;

export type TypeormDevOptions = Pick<PostgresConnectionOptions, 'synchronize' | 'dropSchema'>;

// Review: 2 lines below are duplicated in createObservableInteractionContext
// Good defaults might differ for different servicies, but would be the same more likely than not.
export type ReconnectionConfig = Omit<RetryBackoffConfig, 'shouldRetry'>;
const defaultReconnectionConfig: ReconnectionConfig = { initialInterval: 10, maxInterval: 5000 };

export type TypeormOptions = Pick<
  PostgresConnectionOptions,
  'connectTimeoutMS' | 'logNotifications' | 'installExtensions' | 'extra' | 'maxQueryExecutionTime' | 'poolSize'
> & {};

export interface PgSinksProps {
  connectionConfig$: Observable<PgConnectionConfig>;
  options?: TypeormOptions;
  devOptions?: TypeormDevOptions;
  reconnectionConfig?: ReconnectionConfig;
}

type SupportedProjections = {};
const projectionSinks: PgProjectionSinks<SupportedProjections> = {};
const entities: Function[] = [
  StabilityWindowBlockEntity,
  // Review: or we could just list all entities. Not sure if there's any runtime impact, probably not.
  // If we want to do this, then we can simply inject a list of 'activated projections' into before() hook
  ...uniq(Object.values<WithPgSinkMetadata>(projectionSinks).flatMap((sink) => sink.entities))
];
// Review: if we wanted to support having partial schema then we could
// list relevant migrations for each sink, just like we list 'entities'.
// Need to test whether that would work with typeorm migrations system:
// - if it simply goes through each migration, then we can do it by having
// a constraint that each migration only touches a single table.
// - if it only checks whether it has done the last migration,
// then it's probably not viable
const migrations: Function[] = [];

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isTypeormConnectionError = (_error: any) =>
  // TODO: implement this
  true;

export const createSinks = (
  { connectionConfig$, devOptions, options, reconnectionConfig }: PgSinksProps,
  { logger }: WithLogger
): Sinks<SupportedProjections> => {
  const buffer = new PgStabilityWindowBuffer();
  return {
    after: (evt$: Observable<WithPgContext>) =>
      evt$.pipe(
        concatMap((evt) =>
          from(
            evt.queryRunner.commitTransaction().then(() => {
              evt.transactionCommit$.next();
              return evt;
            })
          )
        ),
        // This will re-subscribe all the way up to 'before' hook's shareReplay,
        // which will re-emit the last event without re-subscribing to chain sync event source,
        // but re-run the entire PgSinks initialization, including re-subscribing to connectionConfig$
        retryBackoff({
          ...reconnectionConfig,
          ...defaultReconnectionConfig,
          shouldRetry: (error) => isTypeormConnectionError(error)
        }),
        // sanitize the event object
        map((evt) => omit(evt, ['dataSource', 'queryRunner', 'transactionCommit$']))
      ),
    before: (evt$) =>
      evt$.pipe(
        // TODO: test if refCount doesn't cause source to be re-subscribed on retryBackoff
        shareReplay({ bufferSize: 1, refCount: true }),
        withStaticContext(
          connectionConfig$.pipe(
            switchMap((connectionConfig) =>
              from(
                (async () => {
                  const dataSource = new DataSource({
                    ...connectionConfig,
                    ...devOptions,
                    ...options,
                    cache: true, // TODO: not sure about this option
                    entities,
                    logger: typeormLogger(logger),
                    logging: true,
                    migrations,
                    migrationsRun: true,
                    type: 'postgres'
                  });

                  await dataSource.initialize();
                  // buffer has to emit tip$ and tail$
                  // for projector to find intersection before emitting any events
                  // TODO: not sure if this will be initialized on load,
                  // if not we might need some workaround
                  await buffer.initialize(dataSource);
                  return { dataSource: dataSource.initialize() };
                })()
              )
            )
          )
        ),
        withEventContext(
          (
            evt: Pick<WithPgContext, 'dataSource'>
          ): Observable<Pick<WithPgContext, 'queryRunner' | 'transactionCommit$'>> => {
            const queryRunner = evt.dataSource.createQueryRunner();
            return from(
              // transactionCommit$.next is called in 'after' hook.
              // used by PgStabilityWindowBuffer to emit new tip$
              // TODO: figure out which IsolationLevel we need:
              // https://typeorm.io/transactions#specifying-isolation-levels
              queryRunner.startTransaction().then(() => ({ queryRunner, transactionCommit$: new Subject<void>() }))
            );
          }
        )
      ),
    buffer,
    projectionSinks
  };
};

export type InMemorySinks = ReturnType<typeof createSinks>;
