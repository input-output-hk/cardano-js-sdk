import {
  EMPTY,
  Observable,
  combineLatest,
  concat,
  debounce,
  debounceTime,
  distinctUntilChanged,
  filter,
  interval,
  map,
  mergeMap,
  of,
  share,
  skipWhile,
  switchMap,
  take,
  tap,
  timer
} from 'rxjs';
import { Logger } from 'ts-log';
import { Milliseconds } from '../types';
import { ProviderFnStats } from './ProviderTracker';
import { TrackedAssetProvider } from './TrackedAssetProvider';
import { TrackedChainHistoryProvider } from './TrackedChainHistoryProvider';
import { TrackedDrepProvider } from './TrackedDrepProvider';
import { TrackedRewardsProvider } from './TrackedRewardsProvider';
import { TrackedStakePoolProvider } from './TrackedStakePoolProvider';
import { TrackedUtxoProvider } from './TrackedUtxoProvider';
import { TrackedWalletNetworkInfoProvider } from './TrackedWalletNetworkInfoProvider';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';

export interface ProviderStatusTrackerProps {
  consideredOutOfSyncAfter: Milliseconds;
}

export interface ProviderStatusTrackerDependencies {
  stakePoolProvider: TrackedStakePoolProvider;
  networkInfoProvider: TrackedWalletNetworkInfoProvider;
  assetProvider: TrackedAssetProvider;
  utxoProvider: TrackedUtxoProvider;
  chainHistoryProvider: TrackedChainHistoryProvider;
  drepProvider: TrackedDrepProvider;
  rewardsProvider: TrackedRewardsProvider;
  logger: Logger;
}

const getDefaultProviderSyncRelevantStats = ({
  stakePoolProvider,
  networkInfoProvider,
  assetProvider,
  utxoProvider,
  chainHistoryProvider,
  rewardsProvider,
  drepProvider
}: ProviderStatusTrackerDependencies): Observable<ProviderFnStats[]> =>
  combineLatest([
    networkInfoProvider.stats.ledgerTip$,
    networkInfoProvider.stats.protocolParameters$,
    networkInfoProvider.stats.genesisParameters$,
    networkInfoProvider.stats.eraSummaries$,
    assetProvider.stats.getAsset$,
    stakePoolProvider.stats.queryStakePools$,
    utxoProvider.stats.utxoByAddresses$,
    chainHistoryProvider.stats.transactionsByAddresses$,
    drepProvider.stats.getDRepInfo$,
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
  const logger = dependencies.logger;
  const relevantStats$ = getProviderSyncRelevantStats(dependencies).pipe(share());
  const isAnyRequestPending$ = new TrackerSubject<boolean>(
    relevantStats$.pipe(
      map((allStats) =>
        allStats.some(
          ({ numCalls, numFailures, numResponses, didLastRequestFail }) =>
            didLastRequestFail || numCalls > numResponses + numFailures
        )
      ),
      // do not debounce if there are pending requests; in case of many requests, it will be debounced
      // for a long time, leaving the previous status unchanged
      debounce((isReqPending) => (isReqPending ? of(true) : interval(1))),
      distinctUntilChanged(),
      tap((isReqPending) => logger.debug(`${isReqPending ? 'Some' : 'No'} requests are pending`))
    )
  );
  const statsReady$ = relevantStats$.pipe(
    debounceTime(1),
    skipWhile((allStats) => allStats.some(({ initialized }) => !initialized)),
    take(1),
    tap(() => logger.debug('All stats are initialized')),
    mergeMap(() => EMPTY)
  );
  const isSettled$ = new TrackerSubject<boolean>(
    concat(of(false), statsReady$, isAnyRequestPending$.pipe(map((pending) => !pending))).pipe(
      distinctUntilChanged(),
      tap((isSettled) => logger.debug('isSettled', isSettled))
    )
  );
  const isUpToDate$ = new TrackerSubject<boolean>(
    concat(
      of(false),
      isSettled$.pipe(
        filter((isSettled) => isSettled),
        switchMap(() => concat(of(true), timer(consideredOutOfSyncAfter).pipe(map(() => false)))),
        distinctUntilChanged()
      )
    ).pipe(tap((isUpToDate) => logger.debug('isUpToDate', isUpToDate)))
  );
  return {
    isAnyRequestPending$,
    isSettled$,
    isUpToDate$,
    shutdown() {
      isAnyRequestPending$.complete();
      isSettled$.complete();
      isUpToDate$.complete();
      logger.debug('Shutdown');
    }
  };
};
