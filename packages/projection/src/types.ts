/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, ChainSyncRollBackward, ChainSyncRollForward, EraSummary } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { ObservableType } from '@cardano-sdk/util-rxjs';

export type RollForwardEvent<ExtraProps = {}> = ExtraProps & ChainSyncRollForward;

export type RollBackwardEvent<ExtraProps = {}> = ExtraProps & ChainSyncRollBackward;

export type ExtChainSyncEvent<ExtraRollForwardProps = {}, ExtraRollBackwardProps = {}> =
  | RollForwardEvent<ExtraRollForwardProps>
  | RollBackwardEvent<ExtraRollBackwardProps>;

export type ExtChainSyncObservable<ExtraRollForwardProps = {}, ExtraRollBackwardProps = {}> = Observable<
  ExtChainSyncEvent<ExtraRollForwardProps, ExtraRollBackwardProps>
>;

export type ExtChainSyncOperator<
  ExtraRollForwardPropsIn,
  ExtraRollBackwardPropsIn,
  ExtraRollForwardPropsOut,
  ExtraRollBackwardPropsOut
> = (
  evt$: ExtChainSyncObservable<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>
) => Observable<
  ExtChainSyncEvent<
    ExtraRollForwardPropsIn & ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsIn & ExtraRollBackwardPropsOut
  >
>;

export type WithBlock = Pick<ChainSyncRollForward, 'block'>;
export type UnifiedExtChainSyncOperator<ExtraPropsIn, ExtraPropsOut> = ExtChainSyncOperator<
  ExtraPropsIn,
  ExtraPropsIn & WithBlock,
  ExtraPropsOut,
  ExtraPropsOut
>;
export type UnifiedExtChainSyncEvent<ExtraProps> = ExtChainSyncEvent<ExtraProps, ExtraProps & WithBlock>;
export type UnifiedExtChainSyncObservable<ExtraProps> = ExtChainSyncObservable<ExtraProps, ExtraProps & WithBlock>;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type OperatorEventType<T extends (...args: any[]) => any> = ReturnType<T> extends (...args: any[]) => any
  ? OperatorEventType<ReturnType<T>>
  : ObservableType<ReturnType<T>>;

export type WithNetworkInfo = {
  eraSummaries: EraSummary[];
  genesisParameters: Cardano.CompactGenesis;
};

export type WithEpochNo = { epochNo: Cardano.EpochNo };

export type WithEpochBoundary = { crossEpochBoundary: boolean };

export type BootstrapExtraProps = WithNetworkInfo & WithEpochNo & WithEpochBoundary;

export type ProjectionEvent<ExtraProps = {}> = UnifiedExtChainSyncEvent<BootstrapExtraProps & ExtraProps>;

export type ProjectionOperator<ExtraPropsIn, ExtraPropsOut = {}> = UnifiedExtChainSyncOperator<
  BootstrapExtraProps & ExtraPropsIn,
  ExtraPropsOut
>;

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
