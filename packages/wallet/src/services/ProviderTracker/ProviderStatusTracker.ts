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
import { TrackedChainHistoryProvider } from './TrackedChainHistoryProvider';
import { TrackedNetworkInfoProvider } from './TrackedNetworkInfoProvider';
import { TrackedRewardsProvider } from './TrackedRewardsProvider';
import { TrackedStakePoolProvider } from './TrackedStakePoolProvider';
import { TrackedTxSubmitProvider } from './TrackedTxSubmitProvider';
import { TrackedUtxoProvider } from './TrackedUtxoProvider';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';

export interface ProviderStatusTrackerProps {
  consideredOutOfSyncAfter: Milliseconds;
}

export interface ProviderStatusTrackerDependencies {
  stakePoolProvider: TrackedStakePoolProvider;
  networkInfoProvider: TrackedNetworkInfoProvider;
  txSubmitProvider: TrackedTxSubmitProvider;
  assetProvider: TrackedAssetProvider;
  utxoProvider: TrackedUtxoProvider;
  chainHistoryProvider: TrackedChainHistoryProvider;
  rewardsProvider: TrackedRewardsProvider;
}

const getDefaultProviderSyncRelevantStats = ({
  stakePoolProvider,
  networkInfoProvider,
  txSubmitProvider,
  assetProvider,
  utxoProvider,
  chainHistoryProvider,
  rewardsProvider
}: ProviderStatusTrackerDependencies): Observable<ProviderFnStats[]> =>
  combineLatest([
    networkInfoProvider.stats.ledgerTip$,
    networkInfoProvider.stats.currentWalletProtocolParameters$,
    networkInfoProvider.stats.genesisParameters$,
    networkInfoProvider.stats.stake$,
    networkInfoProvider.stats.lovelaceSupply$,
    networkInfoProvider.stats.timeSettings$,
    assetProvider.stats.getAsset$,
    txSubmitProvider.stats.submitTx$,
    stakePoolProvider.stats.queryStakePools$,
    utxoProvider.stats.utxoByAddresses$,
    chainHistoryProvider.stats.transactionsByAddresses$,
    rewardsProvider.stats.rewardsHistory$,
    rewardsProvider.stats.rewardAccountBalance$
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
    isUpToDate$,
    shutdown() {
      isAnyRequestPending$.complete();
      isSettled$.complete();
      isUpToDate$.complete();
    }
  };
};
