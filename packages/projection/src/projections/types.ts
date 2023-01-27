/* eslint-disable @typescript-eslint/no-explicit-any */
import { OperatorFunction } from 'rxjs';
import { UnifiedProjectorEvent } from '../types';

export type Projection<ExtraProps> = [
  ...OperatorFunction<any, any>[],
  OperatorFunction<any, UnifiedProjectorEvent<ExtraProps>>
];

export type ProjectionExtraProps<P> = P extends Projection<infer RF> ? RF : never;
