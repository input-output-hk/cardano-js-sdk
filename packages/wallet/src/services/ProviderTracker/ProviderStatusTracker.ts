import {
  EMPTY,
  Observable,
  combineLatest,
  concat,
  debounceTime,
  distinctUntilChanged,
  filter,
  map,
  mergeMap,
  of,
  share,
  skipWhile,
  switchMap,
  take,
  timer
} from 'rxjs';
import { Milliseconds } from '../types';
import { ProviderFnStats } from './ProviderTracker';
import { TrackedAssetProvider } from './TrackedAssetProvider';
import { TrackedNetworkInfoProvider } from './TrackedNetworkInfoProvider';
import { TrackedStakePoolSearchProvider } from './TrackedStakePoolSearchProvider';
import { TrackedTxSubmitProvider } from './TrackedTxSubmitProvider';
import { TrackedUtxoProvider } from './TrackedUtxoProvider';
import { TrackedWalletProvider } from './TrackedWalletProvider';
import { TrackerSubject } from '../util';

export interface ProviderStatusTrackerProps {
  consideredOutOfSyncAfter: Milliseconds;
}

export interface ProviderStatusTrackerDependencies {
  walletProvider: TrackedWalletProvider;
  stakePoolSearchProvider: TrackedStakePoolSearchProvider;
  networkInfoProvider: TrackedNetworkInfoProvider;
  txSubmitProvider: TrackedTxSubmitProvider;
  assetProvider: TrackedAssetProvider;
  utxoProvider: TrackedUtxoProvider;
}

const getDefaultProviderSyncRelevantStats = ({
  walletProvider,
  stakePoolSearchProvider,
  networkInfoProvider,
  txSubmitProvider,
  assetProvider,
  utxoProvider
}: ProviderStatusTrackerDependencies): Observable<ProviderFnStats[]> =>
  combineLatest([
    walletProvider.stats.ledgerTip$,
    walletProvider.stats.currentWalletProtocolParameters$,
    walletProvider.stats.genesisParameters$,
    walletProvider.stats.transactionsByAddresses$,
    walletProvider.stats.rewardsHistory$,
    walletProvider.stats.rewardAccountBalance$,
    assetProvider.stats.getAsset$,
    txSubmitProvider.stats.submitTx$,
    stakePoolSearchProvider.stats.queryStakePools$,
    networkInfoProvider.stats.networkInfo$,
    utxoProvider.stats.utxoByAddresses$
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
) => {
  const relevantStats$ = getProviderSyncRelevantStats(dependencies).pipe(share());
  const isAnyRequestPending$ = new TrackerSubject<boolean>(
    relevantStats$.pipe(
      debounceTime(1), // resolved requests could trigger new requests
      map((allStats) =>
        allStats.some(
          ({ numCalls, numFailures, numResponses, didLastRequestFail }) =>
            didLastRequestFail || numCalls > numResponses + numFailures
        )
      ),
      distinctUntilChanged()
    )
  );
  const statsReady$ = relevantStats$.pipe(
    debounceTime(1),
    skipWhile((allStats) => allStats.some(({ initialized }) => !initialized)),
    take(1),
    mergeMap(() => EMPTY)
  );
  const isSettled$ = new TrackerSubject<boolean>(
    concat(of(false), statsReady$, isAnyRequestPending$.pipe(map((pending) => !pending))).pipe(distinctUntilChanged())
  );
  const isUpToDate$ = new TrackerSubject<boolean>(
    concat(
      of(false),
      isSettled$.pipe(
        filter((isSettled) => isSettled),
        switchMap(() => concat(of(true), timer(consideredOutOfSyncAfter).pipe(map(() => false)))),
        distinctUntilChanged()
      )
    )
  );
  return {
    isAnyRequestPending$,
    isSettled$,
    isUpToDate$
  };
};
