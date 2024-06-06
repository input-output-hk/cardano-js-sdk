import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { distinctUntilChanged, map, switchMap } from 'rxjs';
import { epochInfoEquals } from './util/index.js';
import type { Cardano, EpochInfo, EraSummary } from '@cardano-sdk/core';
import type { Observable } from 'rxjs';

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
