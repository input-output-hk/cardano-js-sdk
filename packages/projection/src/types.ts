/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  ChainSyncEvent,
  ChainSyncRollBackward,
  ChainSyncRollForward,
  Intersection,
  PointOrOrigin
} from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';
import { Observable } from 'rxjs';
import { ObservableType } from '@cardano-sdk/util-rxjs';

export type RollForwardEvent<ExtraProps = {}> = ExtraProps & ChainSyncRollForward;

export type RollBackwardEvent<ExtraProps = {}> = ExtraProps & ChainSyncRollBackward;

export type ProjectorEvent<ExtraRollForwardProps = {}, ExtraRollBackwardProps = {}> =
  | RollForwardEvent<ExtraRollForwardProps>
  | RollBackwardEvent<ExtraRollBackwardProps>;

export type ProjectorObservable<ExtraRollForwardProps = {}, ExtraRollBackwardProps = {}> = Observable<
  ProjectorEvent<ExtraRollForwardProps, ExtraRollBackwardProps>
>;

export type ProjectorOperator<
  ExtraRollForwardPropsIn,
  ExtraRollBackwardPropsIn,
  ExtraRollForwardPropsOut,
  ExtraRollBackwardPropsOut
> = (
  evt$: ProjectorObservable<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>
) => Observable<
  ProjectorEvent<
    ExtraRollForwardPropsIn & ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsIn & ExtraRollBackwardPropsOut
  >
>;

export type WithBlock = Pick<ChainSyncRollForward, 'block'>;
export type UnifiedProjectorOperator<ExtraPropsIn, ExtraPropsOut> = ProjectorOperator<
  ExtraPropsIn,
  ExtraPropsIn & WithBlock,
  ExtraPropsOut,
  ExtraPropsOut
>;
export type UnifiedProjectorEvent<ExtraProps> = ProjectorEvent<ExtraProps, ExtraProps & WithBlock>;
export type UnifiedProjectorObservable<ExtraProps> = ProjectorObservable<ExtraProps, ExtraProps & WithBlock>;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type OperatorEventType<T extends (...args: any[]) => any> = ReturnType<T> extends (...args: any[]) => any
  ? OperatorEventType<ReturnType<T>>
  : ObservableType<ReturnType<T>>;

export interface ChainSyncProps {
  /**
   * Sorted tip to origin
   */
  points: PointOrOrigin[];
}

export class InvalidIntersectionError extends CustomError {}

export interface ObservableChainSync {
  chainSync$: Observable<ChainSyncEvent>;
  intersection: Intersection;
}

/**
 * @throws errors with {@link InvalidIntersectionError} when intersection point is not found by the node (probably due
 * to a rollback). User is expected to handle the rollback and call `chainSync` with another intersection point.
 */
export type ObservableChainSyncClient = (props: ChainSyncProps) => Observable<ObservableChainSync>;
