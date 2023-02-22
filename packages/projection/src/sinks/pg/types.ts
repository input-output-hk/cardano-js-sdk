import { DataSource, QueryRunner } from 'typeorm';
import { ProjectionSinks, Sink } from '../types';
import { Subject } from 'rxjs';

export interface WithPgContext {
  dataSource: DataSource;
  queryRunner: QueryRunner;
  transactionCommit$: Subject<void>;
}

export interface WithPgSinkMetadata {
  entities: Function[];
}

export type PgSink<P> = Sink<P, WithPgContext>;

export type PgProjectionSinks<P> = {
  [k in keyof ProjectionSinks<P>]: ProjectionSinks<P>[k] & WithPgSinkMetadata;
};
