import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { Cardano, ChainHistoryProvider, EraSummary, SlotEpochCalc, createSlotEpochCalc } from '@cardano-sdk/core';
import { DelegationTracker, TransactionsTracker, UtxoTracker } from '../types';
import { Logger } from 'ts-log';
import { Observable, combineLatest, map, tap } from 'rxjs';
import {
  ObservableRewardsProvider,
  ObservableStakePoolProvider,
  createQueryStakePoolsProvider,
  createRewardAccountsTracker,
  createRewardsProvider
} from './RewardAccounts';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistoryProvider, createRewardsHistoryProvider, createRewardsHistoryTracker } from './RewardsHistory';
import { Shutdown, contextLogger } from '@cardano-sdk/util';
import { TrackedRewardsProvider, TrackedStakePoolProvider } from '../ProviderTracker';
import { TrackerSubject, coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { TxWithEpoch } from './types';
import { WalletStores } from '../../persistence';
import { createDelegationDistributionTracker } from './DelegationDistributionTracker';
import { transactionsWithCertificates } from './transactionCertificates';

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
  knownAddresses$: AsyncKeyAgent['knownAddresses$'];
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

export const createDelegationPortfolioTracker = (delegationTransactions: Observable<TxWithEpoch[]>) =>
  delegationTransactions.pipe(
    map((transactionsWithEpochs) => {
      const txSorted = transactionsWithEpochs.sort((lhs, rhs) => lhs.epoch - rhs.epoch);
      const latestDelegation = txSorted.pop();
      if (!latestDelegation || !latestDelegation.tx.auxiliaryData || !latestDelegation.tx.auxiliaryData.blob)
        return null;

      const portfolio = latestDelegation.tx.auxiliaryData.blob.get(Cardano.DelegationMetadataLabel);

      if (!portfolio) return null;

      return Cardano.cip17FromMetadatum(portfolio);
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
    [
      Cardano.CertificateType.StakeDelegation,
      Cardano.CertificateType.StakeKeyRegistration,
      Cardano.CertificateType.StakeKeyDeregistration
    ]
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

  const portfolio$ = new TrackerSubject(createDelegationPortfolioTracker(transactions$));

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
