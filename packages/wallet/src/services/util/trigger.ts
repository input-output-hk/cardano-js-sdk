import { Observable, distinctUntilChanged, map } from 'rxjs';
import { TimeSettings } from '@cardano-sdk/core';
import { WC } from '../../types';
import { timeSettingsEquals } from './equals';

export const distinctBlock = (tip$: Observable<WC.Tip>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged()
  );

export const distinctTimeSettings = (timeSettings$: Observable<TimeSettings[]>) =>
  timeSettings$.pipe(
    map((timeSettings) => timeSettings),
    distinctUntilChanged(timeSettingsEquals)
  );
