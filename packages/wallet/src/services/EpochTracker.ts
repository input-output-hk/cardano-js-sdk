import { Cardano, EpochInfo, NetworkInfo, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map, switchMap } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { epochInfoEquals } from './util';

export const currentEpochTracker = (
  tip$: Observable<Cardano.Tip>,
  networkInfo$: Observable<NetworkInfo>
): TrackerSubject<EpochInfo> =>
  new TrackerSubject(
    networkInfo$.pipe(
      switchMap((networkInfo) => {
        const slotEpochInfoCalc = createSlotEpochInfoCalc(networkInfo.network.timeSettings);
        return tip$.pipe(map(({ slot }) => slotEpochInfoCalc(slot)));
      }),
      distinctUntilChanged(epochInfoEquals)
    )
  );
