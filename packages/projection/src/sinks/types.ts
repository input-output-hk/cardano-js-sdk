/* eslint-disable @typescript-eslint/no-explicit-any */
import { AllProjections, DefaultProjectionProps, ProjectionsExtraProps } from '../projections';
import { Cardano } from '@cardano-sdk/core';
import { NoExtraProperties } from '@cardano-sdk/util';
import { Observable } from 'rxjs';
import { UnifiedProjectorEvent, UnifiedProjectorOperator } from '../types';

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
export interface StabilityWindowBuffer {
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
}

export type CommonSinkProps<Projections extends {}> = ProjectionsExtraProps<Projections> & DefaultProjectionProps;

export type Sink<SupportedProjections extends {}> = <P extends Partial<SupportedProjections>>(
  projections: NoExtraProperties<SupportedProjections, P>
) => UnifiedProjectorOperator<CommonSinkProps<P>, {}>;

// Utilities for defining granular sinks (per projection)

export type GranularSinkExtraProps<ProjectionIds extends keyof AllProjections, ExtraContext> = ExtraContext &
  CommonSinkProps<Pick<AllProjections, ProjectionIds>>;
export type GranularSinkEvent<ProjectionIds extends keyof AllProjections, ExtraContext> = UnifiedProjectorEvent<
  GranularSinkExtraProps<ProjectionIds, ExtraContext>
>;
export type GranularSink<ProjectionIds extends keyof AllProjections, ExtraContext> = UnifiedProjectorOperator<
  GranularSinkExtraProps<ProjectionIds, ExtraContext>,
  {}
>;

export type SinkObservable<Projections extends {}, ExtraContext> = Observable<
  UnifiedProjectorEvent<CommonSinkProps<Projections> & ExtraContext>
>;
