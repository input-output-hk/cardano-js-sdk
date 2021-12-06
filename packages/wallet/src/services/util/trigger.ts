import { Cardano, NetworkInfo } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map } from 'rxjs';

export const distinctBlock = (tip$: Observable<Cardano.Tip>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged()
  );

export const distinctEpoch = (networkInfo$: Observable<NetworkInfo>) =>
  networkInfo$.pipe(
    map(({ currentEpoch: { number } }) => number),
    distinctUntilChanged()
  );
