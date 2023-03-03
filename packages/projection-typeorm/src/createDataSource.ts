import 'reflect-metadata';
import * as supportedSinks from './sinks';
import { BlockDataEntity } from './entity';
import { BlockEntity } from './entity/Block.entity';
import { DataSource, DataSourceOptions } from 'typeorm';
import { Logger } from 'ts-log';
import { WithTypeormSinkMetadata } from './types';
import { typeormLogger } from './logger';
import uniq from 'lodash/uniq';

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

export interface CreateDataSourceProps<P extends object> {
  projections: P;
  connectionConfig: PgConnectionConfig;
  options?: TypeormOptions;
  devOptions?: TypeormDevOptions;
  logger: Logger;
}

export const createDataSource = <P extends object>({
  connectionConfig,
  devOptions,
  options,
  projections,
  logger
}: CreateDataSourceProps<P>) => {
  const requestedProjectionEntities = Object.entries<WithTypeormSinkMetadata>(supportedSinks)
    .filter(([projectionName]) => projectionName in projections)
    .flatMap(([_, sink]) => sink.entities);
  const entities: Function[] = uniq([BlockEntity, BlockDataEntity, ...requestedProjectionEntities]);
  return new DataSource({
    ...connectionConfig,
    ...devOptions,
    ...options,
    entities,
    logger: typeormLogger(logger),
    logging: true,
    type: 'postgres'
  });
};
