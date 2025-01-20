/* eslint-disable unicorn/consistent-function-scoping */
import { Cardano, RewardAccountInfoProvider } from '@cardano-sdk/core';
import { DelegationTracker, TransactionsTracker, UtxoTracker } from '../types';
import { GroupedAddress } from '@cardano-sdk/key-management';
import { Logger } from 'ts-log';
import {
  Observable,
  combineLatest,
  concat,
  defaultIfEmpty,
  distinctUntilChanged,
  filter,
  map,
  mergeMap,
  of,
  switchMap,
  take,
  tap
} from 'rxjs';
import {
  ObservableRewardAccountInfoProvider,
  createRewardAccountInfoProvider,
  createRewardAccountsTracker
} from './RewardAccounts';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { Shutdown, contextLogger, deepEquals } from '@cardano-sdk/util';
import { TrackedRewardAccountInfoProvider, TrackedRewardsProvider } from '../ProviderTracker';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { WalletStores } from '../../persistence';
import { createDelegationDistributionTracker } from './DelegationDistributionTracker';
import { pollProvider } from '../util';

const createDelegationPortfolioProvider =
  ({
    rewardAccountInfoProvider,
    retryBackoffConfig,
    logger
  }: {
    rewardAccountInfoProvider: RewardAccountInfoProvider;
    retryBackoffConfig: RetryBackoffConfig;
    logger: Logger;
  }) =>
  (rewardAccount: Cardano.RewardAccount): Observable<Cardano.Cip17DelegationPortfolio | null> =>
    pollProvider({
      logger,
      retryBackoffConfig,
      sample: () => rewardAccountInfoProvider.delegationPortfolio(rewardAccount)
    });

type DelegationPortfolioProvider = ReturnType<typeof createDelegationPortfolioProvider>;

export interface DelegationTrackerProps {
  rewardsTracker: TrackedRewardsProvider;
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  rewardAccountInfoProvider: TrackedRewardAccountInfoProvider;
  epoch$: Observable<Cardano.EpochNo>;
  transactionsTracker: Pick<TransactionsTracker, 'outgoing' | 'new$' | 'history$'>;
  protocolParameters$: Observable<Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit'>>;
  retryBackoffConfig: RetryBackoffConfig;
  utxoTracker: UtxoTracker;
  refetchRewardAccountInfo$: Observable<void>;
  knownAddresses$: Observable<GroupedAddress[]>;
  stores: WalletStores;
  internals?: {
    rewardsHistoryProvider?: RewardsHistoryProvider;
    observableRewardAccountInfoProvider?: ObservableRewardAccountInfoProvider;
    delegationPortfolioProvider?: DelegationPortfolioProvider;
  };
  logger: Logger;
}

const hasDelegationCert = (certificates: Array<Cardano.Certificate> | undefined): boolean =>
  !!certificates &&
  certificates.some((cert) =>
    Cardano.isCertType(cert, [...Cardano.RegAndDeregCertificateTypes, ...Cardano.StakeDelegationCertificateTypes])
  );

/**
 * @returns Observable that emits:
 * - delegation portfolio if multi-delegation metadata is found in transactions
 * - `null` if not multi-delegating
 * - `undefined` if no relevant transactions were found
 */
const findDelegationPortfolioMetadata = () => (recentTransactions: Observable<Cardano.Tx[]>) =>
  recentTransactions.pipe(
    map((hydratedTxs) => {
      const sortedTransactions = [...hydratedTxs].reverse();

      let result;
      for (const sorted of sortedTransactions) {
        const portfolio = sorted.auxiliaryData?.blob?.get(Cardano.DelegationMetadataLabel);
        const altersDelegationState = hasDelegationCert(sorted.body.certificates);

        if (!portfolio && !altersDelegationState) continue;

        if (altersDelegationState && !portfolio) {
          result = null;
          break;
        }

        if (portfolio) {
          result = Cardano.cip17FromMetadatum(portfolio);
          break;
        }
      }

      return result;
    })
  );

const delegationTransactionFound = (
  portfolio: Cardano.Cip17DelegationPortfolio | null | undefined
): portfolio is Cardano.Cip17DelegationPortfolio | null => typeof portfolio !== 'undefined';

export const createDelegationPortfolioTracker = (
  rewardAccounts$: Observable<Cardano.RewardAccount[]>,
  recentTransactionHistory$: Observable<Cardano.HydratedTx[]>,
  newTransaction$: Observable<Cardano.OnChainTx>,
  delegationPortfolioProvider: DelegationPortfolioProvider,
  store: WalletStores['delegationPortfolio']
) => {
  const storageSet = (portfolio: Cardano.Cip17DelegationPortfolio | null) =>
    portfolio ? store.set(portfolio).subscribe() : store.delete().subscribe();
  return combineLatest([store.get().pipe(defaultIfEmpty(null)), rewardAccounts$]).pipe(
    switchMap(([storedPortfolio, rewardAccounts]) => {
      if (rewardAccounts.length <= 1) {
        if (storedPortfolio) {
          storageSet(null);
        }
        return of(null);
      }
      const checkRecentHistory$ = recentTransactionHistory$.pipe(findDelegationPortfolioMetadata(), take(1));
      const observeNewTransactions$ = newTransaction$.pipe(
        map((newTx) => [newTx]),
        findDelegationPortfolioMetadata(),
        filter(delegationTransactionFound),
        tap(storageSet)
      );
      if (storedPortfolio) {
        return concat(
          of(storedPortfolio),
          // history is checked to recover from stale stored porfolio
          checkRecentHistory$.pipe(filter(delegationTransactionFound)),
          observeNewTransactions$
        );
      }
      return concat(
        checkRecentHistory$.pipe(
          mergeMap((historyPorfolio) => {
            if (delegationTransactionFound(historyPorfolio)) {
              return of(historyPorfolio);
            }
            return recentTransactionHistory$.pipe(
              take(1),
              mergeMap((recentHistory) => {
                if (recentHistory.length === 0) {
                  // no transactions => new wallet => not multi-delegating
                  return of(null);
                }
                return delegationPortfolioProvider(rewardAccounts[0]).pipe(take(1));
              })
            );
          }),
          tap(storageSet)
        ),
        observeNewTransactions$
      );
    }),
    distinctUntilChanged(deepEquals)
  );
};

export const createDelegationTracker = ({
  rewardAccountAddresses$,
  epoch$,
  rewardsTracker,
  retryBackoffConfig,
  transactionsTracker,
  rewardAccountInfoProvider,
  knownAddresses$,
  refetchRewardAccountInfo$,
  protocolParameters$,
  utxoTracker,
  stores,
  logger,
  internals: {
    rewardsHistoryProvider = createRewardsHistoryProvider(rewardsTracker, retryBackoffConfig),
    observableRewardAccountInfoProvider = createRewardAccountInfoProvider({
      epoch$,
      externalTrigger$: refetchRewardAccountInfo$,
      logger,
      retryBackoffConfig,
      rewardAccountInfoProvider
    }),
    delegationPortfolioProvider = createDelegationPortfolioProvider({
      logger,
      retryBackoffConfig,
      rewardAccountInfoProvider
    })
  } = {}
}: DelegationTrackerProps): DelegationTracker & Shutdown => {
  const rewardsHistory$ = new TrackerSubject(
    createRewardsHistoryTracker(
      rewardAccountAddresses$,
      epoch$,
      rewardsHistoryProvider,
      stores.rewardsHistory,
      contextLogger(logger, 'rewardsHistory$')
    )
  );

  const portfolio$ = new TrackerSubject(
    createDelegationPortfolioTracker(
      rewardAccountAddresses$,
      transactionsTracker.history$,
      transactionsTracker.new$,
      delegationPortfolioProvider,
      stores.delegationPortfolio
    )
  );

  const rewardAccounts$ = new TrackerSubject(
    createRewardAccountsTracker({
      newTransaction$: transactionsTracker.new$,
      protocolParameters$,
      rewardAccountAddresses$,
      rewardAccountInfoProvider: observableRewardAccountInfoProvider,
      store: stores.rewardAccountInfo,
      transactionsInFlight$: transactionsTracker.outgoing.inFlight$
    })
  );
  const distribution$ = new TrackerSubject(
    createDelegationDistributionTracker({ knownAddresses$, rewardAccounts$, utxoTracker })
  );
  return {
    distribution$,
    portfolio$,
    rewardAccounts$,
    rewardsHistory$,
    shutdown: () => {
      rewardAccounts$.complete();
      rewardsHistory$.complete();
      portfolio$.complete();
      logger.debug('Shutdown');
    }
  };
};
