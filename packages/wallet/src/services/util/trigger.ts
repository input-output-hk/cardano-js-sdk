import { Cardano, NetworkInfo } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map, share } from 'rxjs';

export const sharedDistinctBlock = (tip$: Observable<Cardano.Tip>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged(),
    share()
  );

export const sharedDistinctEpoch = (networkInfo$: Observable<NetworkInfo>) =>
  networkInfo$.pipe(
    map(({ currentEpoch: { number } }) => number),
    distinctUntilChanged(),
    share()
  );
