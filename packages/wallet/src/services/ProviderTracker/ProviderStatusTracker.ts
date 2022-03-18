import {
  EMPTY,
  Observable,
  combineLatest,
  concat,
  distinctUntilChanged,
  map,
  merge,
  mergeMap,
  of,
  skipWhile,
  switchMap,
  timer
} from 'rxjs';
import { Milliseconds } from '../types';
import { ProviderFnStats } from './ProviderTracker';
import { SyncStatus } from '../../types';
import { TrackedStakePoolSearchProvider } from './TrackedStakePoolSearchProvider';
import { TrackedTimeSettingsProvider } from './TrackedTimeSettingsProvider';
import { TrackedWalletProvider } from './TrackedWalletProvider';
import { TrackerSubject } from '../util';

export interface ProviderStatusTrackerProps {
  consideredOutOfSyncAfter: Milliseconds;
}

export interface ProviderStatusTrackerDependencies {
  walletProvider: TrackedWalletProvider;
  stakePoolSearchProvider: TrackedStakePoolSearchProvider;
  timeSettingsProvider: TrackedTimeSettingsProvider;
}

const getDefaultProviderSyncRelevantStats = ({
  walletProvider,
  stakePoolSearchProvider,
  timeSettingsProvider
}: ProviderStatusTrackerDependencies): Observable<ProviderFnStats[]> =>
  combineLatest([
    walletProvider.stats.ledgerTip$,
    walletProvider.stats.currentWalletProtocolParameters$,
    walletProvider.stats.genesisParameters$,
    walletProvider.stats.networkInfo$,
    walletProvider.stats.queryTransactionsByAddresses$,
    walletProvider.stats.rewardsHistory$,
    walletProvider.stats.utxoDelegationAndRewards$,
    stakePoolSearchProvider.stats.queryStakePools$,
    timeSettingsProvider.stats.getTimeSettings$
  ]);

export interface ProviderStatusTrackerInternals {
  /**
   * @returns Observable of Provider stats that are considered
   * when determining Wallet sync status
   */
  getProviderSyncRelevantStats?: typeof getDefaultProviderSyncRelevantStats;
}

export const createProviderStatusTracker = (
  dependencies: ProviderStatusTrackerDependencies,
  { consideredOutOfSyncAfter }: ProviderStatusTrackerProps,
  { getProviderSyncRelevantStats = getDefaultProviderSyncRelevantStats }: ProviderStatusTrackerInternals = {}
): TrackerSubject<SyncStatus> => {
  const relevantStats = getProviderSyncRelevantStats(dependencies);
  const upToDate$ = relevantStats.pipe(
    skipWhile((allStats) => allStats.some(({ initialized }) => !initialized)),
    mergeMap((allStats) =>
      allStats.some(
        ({ numCalls, numFailures, numResponses, didLastRequestFail }) =>
          didLastRequestFail || numCalls > numResponses + numFailures
      )
        ? EMPTY
        : of(true)
    )
  );
  return new TrackerSubject<SyncStatus>(
    concat(
      of(SyncStatus.Syncing),
      upToDate$.pipe(
        switchMap(() =>
          merge(of(SyncStatus.UpToDate), timer(consideredOutOfSyncAfter).pipe(map(() => SyncStatus.Syncing)))
        )
      )
    ).pipe(distinctUntilChanged())
  );
};
