import { Cardano, EpochInfo, TimeSettings, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map, switchMap } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { epochInfoEquals } from './util';

export const currentEpochTracker = (
  tip$: Observable<Cardano.Tip>,
  timeSettings$: Observable<TimeSettings[]>
): TrackerSubject<EpochInfo> =>
  new TrackerSubject(
    timeSettings$.pipe(
      switchMap((timeSettings) => {
        const slotEpochInfoCalc = createSlotEpochInfoCalc(timeSettings);
        return tip$.pipe(map(({ slot }) => slotEpochInfoCalc(slot)));
      }),
      distinctUntilChanged(epochInfoEquals)
    )
  );
