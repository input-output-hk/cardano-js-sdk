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

type ProjectionTypes<Projections> = {
  [k in keyof Projections]: Projections[k] extends Projection<infer Props> ? Props : never;
};
// https://stackoverflow.com/a/50375286
type UnionToIntersection<U> = (U extends any ? (k: U) => void : never) extends (k: infer I) => void ? I : never;
export type ProjectionsExtraProps<P extends object> = DefaultProjectionProps &
  UnionToIntersection<ProjectionTypes<P>[keyof P]>;
export type ProjectionsEvent<P extends object> = UnifiedProjectorEvent<ProjectionsExtraProps<P>>;
