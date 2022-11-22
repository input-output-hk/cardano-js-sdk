import { ChainSyncRollBackward, ChainSyncRollForward, PointOrOrigin } from '@cardano-sdk/core';
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

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type OperatorEventType<T extends (...args: any[]) => any> = ReturnType<T> extends (...args: any[]) => any
  ? OperatorEventType<ReturnType<T>>
  : ObservableType<ReturnType<T>>;

// To be used for a higher level projector initialization
export interface ChainSyncProps {
  localTip: PointOrOrigin;
}
export interface ProjectorDependencies {
  chainSync$: Observable<ProjectorEvent>;
}
