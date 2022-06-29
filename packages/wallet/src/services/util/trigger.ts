import { Cardano, TimeSettings } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map } from 'rxjs';
import { timeSettingsEquals } from './equals';

export const distinctBlock = (tip$: Observable<Cardano.Tip>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged()
  );

export const distinctTimeSettings = (timeSettings$: Observable<TimeSettings[]>) =>
  timeSettings$.pipe(
    map((timeSettings) => timeSettings),
    distinctUntilChanged(timeSettingsEquals)
  );
