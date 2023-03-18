/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { DefaultProjectionProps, ProjectionExtraProps } from '../projections';
import { Observable } from 'rxjs';
import { Shutdown } from '@cardano-sdk/util';
import { UnifiedProjectorEvent, UnifiedProjectorOperator } from '../types';
import { WithNetworkInfo } from '../operators';

/**
 * Keeps track of blocks within stability window (computed as numSlots=3k/f).
 *
 * With current mainnet protocol parameters (Dec 2022),
 * it can be up to 2160 ("securityParam"/"k") blocks,
 * which can be up to ~195 megabytes in raw serialized block data.
 *
 * Implementations should have a strategy for deleting blocks outside of the stability window.
 * Implementations are not expected to keep exactly the required # of blocks (having more blocks is ok).
 */
export interface StabilityWindowBuffer<E extends WithNetworkInfo> extends Shutdown {
  /**
   * Observable that emits current tip stored in stability window buffer.
   * 'origin' when buffer is empty.
   * Calling methods of the buffer should make this observable to emit.
   */
  tip$: Observable<Cardano.Block | 'origin'>;
  /**
   * Observable that emits current tail (the first block) stored in stability window buffer.
   * 'origin' when buffer is empty.
   */
  tail$: Observable<Cardano.Block | 'origin'>;
  /**
   * RxJS operator that applies each event to the buffer:
   * - adds a new block on RollForward
   * - deletes the block on RollBackward
   *
   * Buffer must emit new tip$ after each 'apply' takes effect.
   */
  handleEvents: UnifiedProjectorOperator<E, E>;
}

export interface Sink<P, SinkSpecificProps = {}> {
  sink: (
    evt: UnifiedProjectorEvent<ProjectionExtraProps<P> & SinkSpecificProps & DefaultProjectionProps>
  ) => Observable<void>;
}

export type ProjectionSinks<Projections> = {
  [k in keyof Projections]: Sink<Projections[k]>;
};

export type SinkLifecycleOperator = (evt$: Observable<any>) => Observable<any>;

export type Sinks<Projections> = {
  projectionSinks: ProjectionSinks<Projections>;
  buffer: StabilityWindowBuffer<DefaultProjectionProps>;
  before?: SinkLifecycleOperator;
  after?: SinkLifecycleOperator;
};

type InferArg<T> = T extends (arg: infer Arg) => any ? Arg : never;
export type SinkEventType<S extends { sink: any }> = InferArg<S['sink']>;

export type SinksFactory<P> = () => Sinks<P>;
