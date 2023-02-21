import { Cardano } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { ProjectionExtraProps } from '../projections';
import { RollForwardEvent, UnifiedProjectorEvent } from '../types';
import { WithNetworkInfo } from '../operators';

/**
 * Keeps track of blocks within stability window (computed as numSlots=3k/f).
 *
 * With current mainnet protocol parameters (Dec 2022),
 * it can be up to 2160 ("securityParam") * 3 = 6480 blocks,
 * which can be up to ~584 megabytes in raw serialized block data.
 *
 * Implementations should have a strategy for deleting blocks outside of the stability window.
 * Implementations are not expected to keep exactly the required # of blocks (having more blocks is ok).
 */
export interface StabilityWindowBuffer<E extends WithNetworkInfo> {
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
   * @param evt block to add to the buffer
   * @returns Observable that completes once the block is added.
   */
  rollForward(block: RollForwardEvent<E>): Observable<void>;
  /**
   * Delete a block from the buffer.
   *
   * This should be called when rollback of the block is handled (e.g. when deleting data from the database).
   * Projection rollback and deleting the block from the buffer should be implemented as atomic operation.
   *
   * @returns Observable that completes once the block is deleted.
   */
  deleteBlock(evt: Cardano.Block): Observable<void>;
}

export interface Sink<P, SinkSpecificProps = {}> {
  sink: (evt: UnifiedProjectorEvent<ProjectionExtraProps<P> & SinkSpecificProps>) => Observable<void>;
}

export type ProjectionSinks<Projections> = {
  [k in keyof Projections]: Sink<Projections[k]>;
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type SinkLifecycleOperator = (evt$: Observable<any>) => Observable<any>;

export type Sinks<Projections> = {
  projectionSinks: ProjectionSinks<Projections>;
  buffer: StabilityWindowBuffer<WithNetworkInfo>;
  before?: SinkLifecycleOperator;
  after?: SinkLifecycleOperator;
};
