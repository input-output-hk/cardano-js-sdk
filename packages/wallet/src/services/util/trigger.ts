import { Cardano, NetworkInfo } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map } from 'rxjs';
import { timeSettingsEquals } from './equals';

export const distinctBlock = (tip$: Observable<Cardano.Tip>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged()
  );

export const distinctTimeSettings = (networkInfo$: Observable<NetworkInfo>) =>
  networkInfo$.pipe(
    map(({ network: { timeSettings } }) => timeSettings),
    distinctUntilChanged(timeSettingsEquals)
  );
