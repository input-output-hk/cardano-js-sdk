import { BlockEntity } from './entity/Block.entity';
import { QueryRunner } from 'typeorm';
import { Sink } from '@cardano-sdk/projection';
import { Subject } from 'rxjs';

export interface WithTypeormContext {
  queryRunner: QueryRunner;
  transactionCommit$: Subject<void>;
  blockEntity: BlockEntity;
}

export interface WithTypeormSinkMetadata {
  entities: Function[];
}

export type TypeormSink<P> = Sink<P, WithTypeormContext> & WithTypeormSinkMetadata;
