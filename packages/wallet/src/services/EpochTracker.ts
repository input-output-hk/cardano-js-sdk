import { BehaviorObservable, TrackerSubject } from './util';
import { Cardano, EpochInfo, NetworkInfo, createSlotEpochInfoCalc } from '@cardano-sdk/core';
import { Observable, map, switchMap } from 'rxjs';

export const currentEpochTracker = (
  tip$: Observable<Cardano.Tip>,
  networkInfo$: Observable<NetworkInfo>
): BehaviorObservable<EpochInfo> =>
  new TrackerSubject(
    networkInfo$.pipe(
      switchMap((networkInfo) => {
        const slotEpochInfoCalc = createSlotEpochInfoCalc(networkInfo.network.timeSettings);
        return tip$.pipe(map(({ slot }) => slotEpochInfoCalc(slot)));
      })
    )
  );
