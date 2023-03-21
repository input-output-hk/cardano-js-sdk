import { BlockEntity } from './entity/Block.entity';
import { Projections, Sink, UnifiedProjectorEvent } from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { Subject } from 'rxjs';
import { WithNetworkInfo } from '@cardano-sdk/projection/dist/cjs/operators';

export interface WithTypeormContext {
  queryRunner: QueryRunner;
  transactionCommitted$: Subject<void>;
  blockEntity: BlockEntity;
}

export interface WithTypeormSinkMetadata {
  entities: Function[];
}

export type TypeormSink<P> = Sink<P, WithTypeormContext> & WithTypeormSinkMetadata;

export type TypeormSinkEvent<P> = P extends Projections.Projection<infer ExtraProps>
  ? UnifiedProjectorEvent<ExtraProps & WithNetworkInfo & WithTypeormContext>
  : never;
