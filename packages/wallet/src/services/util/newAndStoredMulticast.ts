import { Logger } from 'ts-log';
import { Observable, from, groupBy, map, merge, mergeMap, share, tap } from 'rxjs';

interface NewAndStoredMulticast<T, K> {
  new$: Observable<T>;
  stored$: Observable<T[]>;
  storedFilterfn?: (value: T, index: number, array: T[]) => boolean;
  logger: Logger;
  logStringfn?: (stored: T[]) => string;
  groupByFn: (value: T) => K;
}

export const newAndStoredMulticast = <T, K>({
  new$,
  stored$,
  logger,
  storedFilterfn = () => true,
  logStringfn = () => '',
  groupByFn
}: NewAndStoredMulticast<T, K>) =>
  merge<Array<T>>(
    new$.pipe(map((evt) => evt)),
    stored$.pipe(
      tap((stored) => logger.debug(logStringfn(stored))),
      map((stored) => stored.filter(storedFilterfn)),
      mergeMap((stored) => from(stored))
    )
  ).pipe(
    groupBy(groupByFn),
    map((group$) => group$.pipe(share())),
    share()
  );
