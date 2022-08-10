import { Cardano, EpochInfo, EraSummary, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map, switchMap } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { epochInfoEquals } from './util';

export const currentEpochTracker = (
  tip$: Observable<Cardano.Tip>,
  eraSummaries$: Observable<EraSummary[]>
): TrackerSubject<EpochInfo> =>
  new TrackerSubject(
    eraSummaries$.pipe(
      switchMap((eraSummaries) => {
        const slotEpochInfoCalc = createSlotEpochInfoCalc(eraSummaries);
        return tip$.pipe(map(({ slot }) => slotEpochInfoCalc(slot)));
      }),
      distinctUntilChanged(epochInfoEquals)
    )
  );
