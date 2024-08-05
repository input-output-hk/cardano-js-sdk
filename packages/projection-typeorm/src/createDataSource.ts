import 'reflect-metadata';
import { DataSource, DataSourceOptions, DefaultNamingStrategy, NamingStrategyInterface, QueryRunner } from 'typeorm';
import { Logger } from 'ts-log';
import { NEVER, Observable, concat, from, switchMap } from 'rxjs';
import { PgBossExtension, createPgBoss, createPgBossExtension } from './pgBoss';
import { WithLogger, contextLogger, patchObject } from '@cardano-sdk/util';
import { finalizeWithLatest } from '@cardano-sdk/util-rxjs';
import { typeormLogger } from './logger';
import snakeCase from 'lodash/snakeCase.js';

export interface DataSourceExtensions {
  pgBoss?: boolean;
}

type PostgresConnectionOptions = DataSourceOptions & { type: 'postgres' };

export type PgConnectionConfig = Pick<
  PostgresConnectionOptions,
  'host' | 'port' | 'database' | 'username' | 'password' | 'ssl'
>;

export type TypeormDevOptions = Pick<PostgresConnectionOptions, 'synchronize' | 'dropSchema'>;

export type TypeormOptions = Pick<
  PostgresConnectionOptions,
  | 'connectTimeoutMS'
  | 'logNotifications'
  | 'installExtensions'
  | 'extra'
  | 'maxQueryExecutionTime'
  | 'poolSize'
  | 'cache'
  | 'migrationsRun'
  | 'migrations'
> & {};

export interface CreateDataSourceProps {
  entities: Function[];
  connectionConfig: PgConnectionConfig;
  options?: TypeormOptions;
  devOptions?: TypeormDevOptions;
  extensions?: DataSourceExtensions;
  logger: Logger;
}

const toTableName = (tableOrName: string | { name: string }) =>
  (typeof tableOrName === 'string' ? tableOrName : tableOrName.name).replace('_entity', '');

const namingOverrides: Partial<NamingStrategyInterface> = {
  columnName(propertyName, customName, _embeddedPrefixes) {
    return customName || snakeCase(propertyName);
  },
  defaultConstraintName(tableOrName, columnName) {
    return `DF_${toTableName(tableOrName)}_${columnName}`;
  },
  foreignKeyName(tableOrName, columnNames, _referencedTablePath, _referencedColumnNames) {
    return `FK_${toTableName(tableOrName)}_${columnNames.join('_')}`;
  },
  indexName(tableOrName, columns, _where) {
    return `IDX_${toTableName(tableOrName)}_${columns.join('_')}`;
  },
  joinColumnName(relationName, referencedColumnName) {
    return `${snakeCase(relationName)}_${referencedColumnName}`;
  },
  joinTableColumnName(tableName, _propertyName, columnName) {
    return `${tableName}_${columnName}`;
  },
  primaryKeyName(tableOrName, columnNames) {
    return `PK_${toTableName(tableOrName)}_${columnNames.join('_')}`;
  },
  relationConstraintName(tableOrName, columnNames, _where) {
    return `REL_${toTableName(tableOrName)}_${columnNames.join('_')}`;
  },
  tableName(targetName, userSpecifiedName) {
    return userSpecifiedName || toTableName(snakeCase(targetName));
  },
  uniqueConstraintName(tableName, columnNames) {
    return `UQ_${toTableName(tableName)}_${columnNames.join('_')}}`;
  }
};

const defaultStrategy = new DefaultNamingStrategy();
const namingStrategy = new Proxy<NamingStrategyInterface>(defaultStrategy, {
  get(target, p, receiver) {
    if (p in namingOverrides) {
      return namingOverrides[p as keyof NamingStrategyInterface];
    }
    const value = target[p as keyof NamingStrategyInterface];
    if (typeof value === 'function') {
      return value.bind(receiver);
    }
    return value;
  }
});

export const pgBossSchemaExists = async (queryRunner: QueryRunner) => {
  const queryResult = await queryRunner.query(
    "SELECT exists(select schema_name FROM information_schema.schemata WHERE schema_name = 'pgboss');"
  );
  return queryResult[0]?.exists === true;
};

const initializePgBoss = async (dataSource: DataSource, logger: Logger, usePgBoss?: boolean, dropSchema?: boolean) => {
  const queryRunner = dataSource.createQueryRunner('master');
  try {
    if (dropSchema) {
      await queryRunner.query('DROP SCHEMA IF EXISTS pgboss CASCADE;');
    } else if (await pgBossSchemaExists(queryRunner)) {
      return;
    }
    if (!usePgBoss) {
      return;
    }
    const boss = createPgBoss(queryRunner, logger);
    await queryRunner.query('CREATE EXTENSION IF NOT EXISTS pgcrypto;');
    await boss.start();
    await boss.stop();
    await queryRunner.query(`
      ALTER TABLE pgboss.job
        ADD COLUMN block_slot INTEGER,
        ADD CONSTRAINT job_block_slot_fkey
          FOREIGN KEY (block_slot) REFERENCES public.block(slot)
          ON DELETE CASCADE;
    `);
    logger.info('"pgboss" schema created');
  } finally {
    await queryRunner.release();
  }
};

export const createDataSource = ({
  connectionConfig,
  devOptions,
  options,
  entities,
  extensions,
  logger
}: CreateDataSourceProps) => {
  const dataSource = new DataSource({
    ...connectionConfig,
    ...devOptions,
    ...options,
    entities,
    logger: typeormLogger(logger),
    logging: true,
    namingStrategy,
    type: 'postgres'
  });
  return patchObject(dataSource, {
    async initialize() {
      await dataSource.initialize();
      if (extensions?.pgBoss && (options?.migrationsRun || devOptions?.synchronize)) {
        await initializePgBoss(
          dataSource,
          contextLogger(logger, 'createDataSource'),
          extensions?.pgBoss,
          devOptions?.dropSchema
        );
      }
      return dataSource;
    }
  });
};

export type CreateObservableDataSourceProps = Omit<CreateDataSourceProps, 'connectionConfig'> & {
  connectionConfig$: Observable<PgConnectionConfig>;
};

export const createObservableDataSource = ({ connectionConfig$, ...rest }: CreateObservableDataSourceProps) =>
  connectionConfig$.pipe(
    switchMap((connectionConfig) =>
      concat(
        from(
          (async () => {
            const dataSource = createDataSource({
              connectionConfig,
              ...rest
            });
            await dataSource.initialize();
            return dataSource;
          })()
        ),
        NEVER
      ).pipe(
        finalizeWithLatest(async (dataSource) => {
          try {
            await dataSource?.destroy();
          } catch (error) {
            rest.logger.error('Failed to destroy data source', error);
          }
        })
      )
    )
  );

export interface TypeormConnection {
  queryRunner: QueryRunner;
  pgBoss?: PgBossExtension;
}

const releaseConnection =
  ({ logger }: WithLogger) =>
  async (connection: TypeormConnection | null) => {
    if (!connection) return;
    if (connection.queryRunner.isTransactionActive) {
      try {
        await connection.queryRunner.rollbackTransaction();
      } catch (error) {
        logger.warn('Failed to rollback transaction', error);
      }
    }
    if (!connection.queryRunner.isReleased) {
      try {
        await connection.queryRunner.release();
      } catch (error) {
        logger.warn('Failed to "release" query runner', error);
      }
    }
  };

export type ConnectProps = Pick<CreateObservableDataSourceProps, 'extensions' | 'logger'>;

const createConnection = async (dataSource: DataSource, { logger, extensions }: ConnectProps) => {
  const queryRunner = dataSource.createQueryRunner('master');
  await queryRunner.connect();
  if (extensions?.pgBoss) {
    const pgBoss = createPgBossExtension(queryRunner, logger);
    return { pgBoss, queryRunner };
  }
  return { queryRunner };
};

export const connect =
  ({ logger, extensions }: ConnectProps) =>
  (dataSource$: Observable<DataSource>) =>
    dataSource$.pipe(
      switchMap((dataSource) =>
        concat(from(createConnection(dataSource, { extensions, logger })), NEVER).pipe(
          finalizeWithLatest(releaseConnection({ logger }))
        )
      )
    );

export const createObservableConnection = (props: CreateObservableDataSourceProps): Observable<TypeormConnection> =>
  createObservableDataSource(props).pipe(connect(props));
