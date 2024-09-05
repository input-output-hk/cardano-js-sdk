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

/**
 * All projections start by obtaining a source/producer, which is an `Observable<ProjectionEvent<{}>>`.
 * These events are very similar to Chain Sync events, but there are some important differences:
 *
 * 1. Block format is compatible with types from `@cardano-sdk/core` package.
 * 2. Events include some additional properties: `{eraSummaries, genesisParameters, epochNo, crossEpochBoundary}`.
 * 3. `RollBackward` events include block data (instead of just specifying the rollback point),
 *    and are emitted once for **each** rolled back block.
 *
 * #### ExtraProps (Generic Parameter)
 *
 * Source observable can be piped through a series of RxJS operators, which may add some properties to the event.
 * In an nutshell, `type ProjectionEvent<T> = ProjectionEvent<{}> & T`.
 */
export type ProjectionEvent<ExtraProps = {}> = UnifiedExtChainSyncEvent<BootstrapExtraProps & ExtraProps>;

export type ProjectionOperator<ExtraPropsIn, ExtraPropsOut = {}> = UnifiedExtChainSyncOperator<
  BootstrapExtraProps & ExtraPropsIn,
  ExtraPropsOut
>;

/**
 * Keeps track of blocks within stability window (computed as numSlots=3k/f, or k blocks).
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
   * @returns an Observable that emits once and completes
   */
  getBlock(id: Cardano.BlockId): Observable<Cardano.Block | null>;
}

export type BaseProjectionEvent =
  | Omit<RollForwardEvent<BootstrapExtraProps>, 'requestNext'>
  | Omit<RollBackwardEvent<BootstrapExtraProps & WithBlock>, 'requestNext'>
  | Omit<ProjectionEvent<{}>, 'requestNext'>;
