import { Milliseconds } from '@cardano-sdk/core';
import { Observable, map, tap } from 'rxjs';
import { ProjectionEvent } from '../types';

type OperatorStats = {
  totalTime: Milliseconds;
  numCalls: number;
};
export type WithOperatorDuration = {
  operatorDuration: Record<string, OperatorStats>;
};

const operatorDuration = {} as Record<string, OperatorStats>;

export const withOperatorDuration =
  <S, T extends ProjectionEvent>(name: string, operator: (source: Observable<S>) => Observable<T>) =>
  (source: Observable<S>): Observable<T & WithOperatorDuration> => {
    let start: number;
    let totalTime = 0;
    let numCalls = 0;

    return source.pipe(
      tap(() => (start = Date.now())),
      operator,
      tap(() => {
        totalTime += Date.now() - start;
        numCalls++;
      }),
      map((evt) => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        operatorDuration[name] = { numCalls, totalTime: totalTime as Milliseconds };
        return {
          ...evt,
          operatorDuration
        };
      })
    );
  };
