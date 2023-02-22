/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger } from 'ts-log';
import { QueryRunner, Logger as TypeormLogger } from 'typeorm';
import { contextLogger } from '@cardano-sdk/util';

class MappedLogger implements TypeormLogger {
  #logger: Logger;

  constructor(logger: Logger) {
    this.#logger = contextLogger(logger, 'typeorm');
  }
  logQuery(query: string, parameters?: any[] | undefined, _queryRunner?: QueryRunner | undefined) {
    this.#logger.info('Query', query, parameters);
  }
  logQueryError(
    error: string | Error,
    query: string,
    parameters?: any[] | undefined,
    _queryRunner?: QueryRunner | undefined
  ) {
    this.#logger.error('QueryError', query, parameters, error);
  }
  logQuerySlow(time: number, query: string, parameters?: any[] | undefined, _queryRunner?: QueryRunner | undefined) {
    this.#logger.warn(`SlowQuery: took ${time}ms`, query, parameters);
  }
  logSchemaBuild(message: string, _queryRunner?: QueryRunner | undefined) {
    this.#logger.info('SchemaBuild', message);
  }
  logMigration(message: string, _queryRunner?: QueryRunner | undefined) {
    this.#logger.info('Migration', message);
  }
  log(level: 'log' | 'info' | 'warn', message: any, _queryRunner?: QueryRunner | undefined) {
    const method = level === 'log' ? 'debug' : level;
    this.#logger[method](message);
  }
}

export const typeormLogger = (logger: Logger) => new MappedLogger(logger);
