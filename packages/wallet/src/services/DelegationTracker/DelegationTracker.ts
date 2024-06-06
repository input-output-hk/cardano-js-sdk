import { Cardano, createSlotEpochCalc } from '@cardano-sdk/core';
import { TrackerSubject, coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { combineLatest, map, tap } from 'rxjs';
import { contextLogger } from '@cardano-sdk/util';
import { createDelegationDistributionTracker } from './DelegationDistributionTracker.js';
import { createQueryStakePoolsProvider, createRewardAccountsTracker, createRewardsProvider } from './RewardAccounts.js';
import { createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory.js';
import { transactionsWithCertificates } from './transactionCertificates.js';
import type { ChainHistoryProvider, EraSummary, SlotEpochCalc } from '@cardano-sdk/core';
import type { DelegationTracker, TransactionsTracker, UtxoTracker } from '../types.js';
import type { GroupedAddress } from '@cardano-sdk/key-management';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';
import type { ObservableRewardsProvider, ObservableStakePoolProvider } from './RewardAccounts.js';
import type { RetryBackoffConfig } from 'backoff-rxjs';
import type { RewardsHistoryProvider } from './RewardsHistory.js';
import type { Shutdown } from '@cardano-sdk/util';
import type { TrackedRewardsProvider, TrackedStakePoolProvider } from '../ProviderTracker/index.js';
import type { TxWithEpoch } from './types.js';
import type { WalletStores } from '../../persistence/index.js';

export const createBlockEpochProvider =
  (
    chainHistoryProvider: ChainHistoryProvider,
    retryBackoffConfig: RetryBackoffConfig,
    onFatalError?: (value: unknown) => void
  ) =>
  (ids: Cardano.BlockId[]) =>
    coldObservableProvider({
      onFatalError,
      provider: () => chainHistoryProvider.blocksByHashes({ ids }),
      retryBackoffConfig
    }).pipe(map((blocks) => blocks.map(({ epoch }) => epoch)));

export type BlockEpochProvider = ReturnType<typeof createBlockEpochProvider>;

export interface DelegationTrackerProps {
  rewardsTracker: TrackedRewardsProvider;
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  stakePoolProvider: TrackedStakePoolProvider;
  eraSummaries$: Observable<EraSummary[]>;
  epoch$: Observable<Cardano.EpochNo>;
  transactionsTracker: TransactionsTracker;
  retryBackoffConfig: RetryBackoffConfig;
  utxoTracker: UtxoTracker;
  knownAddresses$: Observable<GroupedAddress[]>;
  stores: WalletStores;
  internals?: {
    queryStakePoolsProvider?: ObservableStakePoolProvider;
    rewardsProvider?: ObservableRewardsProvider;
    rewardsHistoryProvider?: RewardsHistoryProvider;
    slotEpochCalc$?: Observable<SlotEpochCalc>;
  };
  logger: Logger;
  onFatalError?: (value: unknown) => void;
}

export const certificateTransactionsWithEpochs = (
  transactionsTracker: TransactionsTracker,
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>,
  slotEpochCalc$: Observable<SlotEpochCalc>,
  certificateTypes: Cardano.CertificateType[]
): Observable<TxWithEpoch[]> =>
  combineLatest([
    transactionsWithCertificates(transactionsTracker.history$, rewardAccountAddresses$, certificateTypes),
    slotEpochCalc$
  ]).pipe(
    map(([transactions, slotEpochCalc]) =>
      transactions.map((tx) => ({ epoch: slotEpochCalc(tx.blockHeader.slot), tx }))
    )
  );

const hasDelegationCert = (certificates: Array<Cardano.Certificate> | undefined): boolean =>
  !!certificates &&
  certificates.some((cert) =>
    Cardano.isCertType(cert, [...Cardano.RegAndDeregCertificateTypes, ...Cardano.StakeDelegationCertificateTypes])
  );

export const createDelegationPortfolioTracker = (transactions: Observable<Cardano.HydratedTx[]>) =>
  transactions.pipe(
    map((hydratedTxs) => {
      const sortedTransactions = [...hydratedTxs].reverse();

      let result = null;
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

export const createDelegationTracker = ({
  rewardAccountAddresses$,
  epoch$,
  rewardsTracker,
  retryBackoffConfig,
  transactionsTracker,
  eraSummaries$,
  stakePoolProvider,
  knownAddresses$,
  utxoTracker,
  stores,
  logger,
  onFatalError,
  internals: {
    queryStakePoolsProvider = createQueryStakePoolsProvider(
      stakePoolProvider,
      stores.stakePools,
      retryBackoffConfig,
      onFatalError
    ),
    rewardsHistoryProvider = createRewardsHistoryProvider(rewardsTracker, retryBackoffConfig),
    rewardsProvider = createRewardsProvider(
      epoch$,
      transactionsTracker.outgoing.onChain$,
      rewardsTracker,
      retryBackoffConfig,
      onFatalError
    ),
    slotEpochCalc$ = eraSummaries$.pipe(map((eraSummaries) => createSlotEpochCalc(eraSummaries)))
  } = {}
}: DelegationTrackerProps): DelegationTracker & Shutdown => {
  const transactions$ = certificateTransactionsWithEpochs(
    transactionsTracker,
    rewardAccountAddresses$,
    slotEpochCalc$,
    [...Cardano.RegAndDeregCertificateTypes, ...Cardano.StakeDelegationCertificateTypes]
  ).pipe(tap((transactionsWithEpochs) => logger.debug(`Found ${transactionsWithEpochs.length} staking transactions`)));

  const rewardsHistory$ = new TrackerSubject(
    createRewardsHistoryTracker(
      transactions$,
      rewardAccountAddresses$,
      rewardsHistoryProvider,
      stores.rewardsHistory,
      contextLogger(logger, 'rewardsHistory$'),
      onFatalError
    )
  );

  const portfolio$ = new TrackerSubject(createDelegationPortfolioTracker(transactionsTracker.history$));

  const rewardAccounts$ = new TrackerSubject(
    createRewardAccountsTracker({
      balancesStore: stores.rewardsBalances,
      epoch$,
      rewardAccountAddresses$,
      rewardsProvider,
      stakePoolProvider: queryStakePoolsProvider,
      transactions$,
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
