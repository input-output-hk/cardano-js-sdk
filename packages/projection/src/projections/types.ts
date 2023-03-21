/* eslint-disable @typescript-eslint/no-explicit-any */
import { OperatorFunction } from 'rxjs';
import { UnifiedProjectorEvent } from '../types';
import { WithEpochBoundary, WithEpochNo, WithNetworkInfo } from '../operators';

export type DefaultProjectionProps = WithNetworkInfo & WithEpochNo & WithEpochBoundary;

export type Projection<ExtraProps> = [
  ...OperatorFunction<any, any>[],
  OperatorFunction<any, UnifiedProjectorEvent<ExtraProps>>
];

export type ProjectionExtraProps<P> = P extends Projection<infer RF> ? RF : never;
