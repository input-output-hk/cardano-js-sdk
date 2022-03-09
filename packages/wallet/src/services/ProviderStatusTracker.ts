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
import { Milliseconds } from './types';
import { ProviderFnStats } from './ProviderTracker';
import { SyncStatus } from '../types';
import { TrackedWalletProvider } from './TrackedWalletProvider';
import { TrackerSubject } from './util';

const getDefaultProviderSyncRelevantStats = (walletProvider: TrackedWalletProvider): Observable<ProviderFnStats[]> =>
  combineLatest([
    walletProvider.stats.ledgerTip$,
    walletProvider.stats.currentWalletProtocolParameters$,
    walletProvider.stats.genesisParameters$,
    walletProvider.stats.networkInfo$,
    walletProvider.stats.queryBlocksByHashes$,
    walletProvider.stats.queryTransactionsByAddresses$,
    walletProvider.stats.rewardsHistory$,
    walletProvider.stats.utxoDelegationAndRewards$
  ]);

export interface ProviderStatusTrackerProps {
  consideredOutOfSyncAfter: Milliseconds;
}

export interface ProviderStatusTrackerDependencies {
  walletProvider: TrackedWalletProvider;
}

export interface ProviderStatusTrackerInternals {
  /**
   * @returns Observable of Provider stats that are considered
   * when determining Wallet sync status
   */
  getProviderSyncRelevantStats?: typeof getDefaultProviderSyncRelevantStats;
}

export const createProviderStatusTracker = (
  { walletProvider }: ProviderStatusTrackerDependencies,
  { consideredOutOfSyncAfter }: ProviderStatusTrackerProps,
  { getProviderSyncRelevantStats = getDefaultProviderSyncRelevantStats }: ProviderStatusTrackerInternals = {}
): TrackerSubject<SyncStatus> => {
  const relevantStats = getProviderSyncRelevantStats(walletProvider);
  const upToDate$ = relevantStats.pipe(
    skipWhile((allStats) => allStats.every(({ numCalls, numResponses }) => numCalls === 0 && numResponses === 0)),
    mergeMap((allStats) => (allStats.some(({ numCalls, numResponses }) => numCalls > numResponses) ? EMPTY : of(true)))
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
