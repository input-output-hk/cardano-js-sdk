import { BlockEntity } from './entity/Block.entity';
import { Cardano } from '@cardano-sdk/core';
import { GranularSink, Operators, Projections, UnifiedProjectorEvent } from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { Subject } from 'rxjs';

export interface PgBossExtension {
  send: <T extends object>(
    taskName: string,
    data: T,
    options: { blockHeight: Cardano.BlockNo }
  ) => Promise<string | null>;
}

export interface WithTypeormContext {
  queryRunner: QueryRunner;
  transactionCommitted$: Subject<void>;
  blockEntity: BlockEntity;
  extensions: {
    pgBoss?: PgBossExtension;
  };
}

export type TypeormSink<ProjectionId extends keyof Projections.AllProjections> = {
  sink$: GranularSink<ProjectionId, WithTypeormContext>;
  entities: Function[];
  dependencies?: Array<keyof Projections.AllProjections>;
  extensions?: {
    pgBoss?: boolean;
  };
};

export type TypeormSinkEvent<P> = P extends Projections.Projection<infer ExtraProps>
  ? UnifiedProjectorEvent<ExtraProps & Operators.WithNetworkInfo & WithTypeormContext>
  : never;
