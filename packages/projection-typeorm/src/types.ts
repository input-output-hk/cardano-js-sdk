import { BlockEntity } from './entity/Block.entity';
import { GranularSink, Projections, UnifiedProjectorEvent } from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { Subject } from 'rxjs';
import { WithNetworkInfo } from '@cardano-sdk/projection/dist/cjs/operators';

export interface WithTypeormContext {
  queryRunner: QueryRunner;
  transactionCommitted$: Subject<void>;
  blockEntity: BlockEntity;
}

export type TypeormSink<ProjectionId extends keyof Projections.AllProjections> = {
  sink$: GranularSink<ProjectionId, WithTypeormContext>;
  entities: Function[];
};

export type TypeormSinkEvent<P> = P extends Projections.Projection<infer ExtraProps>
  ? UnifiedProjectorEvent<ExtraProps & WithNetworkInfo & WithTypeormContext>
  : never;
