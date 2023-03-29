import 'reflect-metadata';
import { BlockDataEntity } from './entity';
import { BlockEntity } from './entity/Block.entity';
import { DataSource, DataSourceOptions, DefaultNamingStrategy, NamingStrategyInterface } from 'typeorm';
import { Logger } from 'ts-log';
import { supportedSinks } from './util';
import { typeormLogger } from './logger';
import snakeCase from 'lodash/snakeCase';
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

export const createDataSource = <P extends object>({
  connectionConfig,
  devOptions,
  options,
  projections,
  logger
}: CreateDataSourceProps<P>) => {
  const requestedProjectionEntities = Object.entries(supportedSinks)
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
    namingStrategy,
    type: 'postgres'
  });
};
