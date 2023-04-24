/* eslint-disable unicorn/no-nested-ternary */
import { BigIntMath, deepEquals, isNotNil } from '@cardano-sdk/util';
import { Cardano, RewardsProvider, StakePoolProvider } from '@cardano-sdk/core';
import { Delegatee, OutgoingOnChainTx, RewardAccount, StakeKeyStatus, TxInFlight } from '../types';
import {
  EMPTY,
  Observable,
  combineLatest,
  concat,
  distinctUntilChanged,
  filter,
  map,
  merge,
  mergeMap,
  of,
  pairwise,
  startWith,
  switchMap,
  tap
} from 'rxjs';
import { KeyValueStore } from '../../persistence';
import { PAGE_SIZE } from '../TransactionsTracker';
import {
  RegAndDeregCertificateTypes,
  includesAnyCertificate,
  isLastStakeKeyCertOfType
} from './transactionCertificates';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedStakePoolProvider } from '../ProviderTracker';
import { TxWithEpoch } from './types';
import { coldObservableProvider, shallowArrayEquals } from '../util';
import findLast from 'lodash/findLast';
import isEqual from 'lodash/isEqual';
import uniq from 'lodash/uniq';

const allStakePoolsByPoolIds = async (
  stakePoolProvider: StakePoolProvider,
  { poolIds }: { poolIds: Cardano.PoolId[] }
): Promise<Cardano.StakePool[]> => {
  let startAt = 0;
  let response: Cardano.StakePool[] = [];
  let pageResults: Cardano.StakePool[] = [];
  do {
    pageResults = (
      await stakePoolProvider.queryStakePools({
        filters: { identifier: { values: poolIds.map((poolId) => ({ id: poolId })) } },
        pagination: { limit: PAGE_SIZE, startAt }
      })
    ).pageResults;
    startAt += PAGE_SIZE;
    response = [...response, ...pageResults];
  } while (pageResults.length === PAGE_SIZE);
  return response;
};

export const createQueryStakePoolsProvider =
  (
    stakePoolProvider: TrackedStakePoolProvider,
    store: KeyValueStore<Cardano.PoolId, Cardano.StakePool>,
    retryBackoffConfig: RetryBackoffConfig,
    onFatalError?: (value: unknown) => void
  ) =>
  (poolIds: Cardano.PoolId[]) => {
    if (poolIds.length === 0) {
      stakePoolProvider.setStatInitialized(stakePoolProvider.stats.queryStakePools$);
      return of([]);
    }
    return merge(
      store.getValues(poolIds),
      coldObservableProvider({
        onFatalError,
        provider: () => allStakePoolsByPoolIds(stakePoolProvider, { poolIds }),
        retryBackoffConfig
      }).pipe(
        tap((pageResults) => {
          for (const stakePool of pageResults) {
            store.setValue(stakePool.id, stakePool);
          }
        })
      )
    );
  };

export type ObservableStakePoolProvider = ReturnType<typeof createQueryStakePoolsProvider>;

const getWithdrawalQuantity = (
  withdrawals: Cardano.HydratedTxBody['withdrawals'],
  rewardAccount?: Cardano.RewardAccount
): Cardano.Lovelace =>
  BigIntMath.sum(
    withdrawals?.map(({ quantity, stakeAddress }) => (stakeAddress === rewardAccount ? quantity : 0n)) || []
  );

export const fetchRewardsTrigger$ = (
  epoch$: Observable<Cardano.EpochNo>,
  txOnChain$: Observable<OutgoingOnChainTx>,
  rewardAccount: Cardano.RewardAccount
) =>
  merge(
    // Reload every epoch and after every tx that has withdrawals for this reward account
    epoch$,
    txOnChain$.pipe(
      map(({ body: { withdrawals } }) => getWithdrawalQuantity(withdrawals, rewardAccount)),
      filter((withdrawalQty) => withdrawalQty > 0n)
    )
  );

export const createRewardsProvider =
  (
    epoch$: Observable<Cardano.EpochNo>,
    txOnChain$: Observable<OutgoingOnChainTx>,
    rewardsProvider: RewardsProvider,
    retryBackoffConfig: RetryBackoffConfig,
    onFatalError?: (value: unknown) => void
  ) =>
  (rewardAccounts: Cardano.RewardAccount[], equals = isEqual): Observable<Cardano.Lovelace[]> =>
    combineLatest(
      rewardAccounts.map((rewardAccount) =>
        coldObservableProvider({
          equals,
          onFatalError,
          provider: () => rewardsProvider.rewardAccountBalance({ rewardAccount }),
          retryBackoffConfig,
          trigger$: fetchRewardsTrigger$(epoch$, txOnChain$, rewardAccount)
        })
      )
    );
export type ObservableRewardsProvider = ReturnType<typeof createRewardsProvider>;

const isDelegationCertificate = (cert: Cardano.Certificate): cert is Cardano.StakeDelegationCertificate =>
  cert.__typename === Cardano.CertificateType.StakeDelegation;

const getAccountsKeyStatus =
  (addresses: Cardano.RewardAccount[]) =>
  ([transactions, transactionsInFlight]: [TxWithEpoch[], TxInFlight[]]) => {
    const certificatesInFlight = transactionsInFlight.map(({ body: { certificates } }) => certificates || []);
    return addresses.map((address) => {
      const isRegistered = isLastStakeKeyCertOfType(
        transactions.map(
          ({
            tx: {
              body: { certificates }
            }
          }) => certificates || []
        ),
        Cardano.CertificateType.StakeKeyRegistration,
        address
      );
      const isRegistering = isLastStakeKeyCertOfType(
        certificatesInFlight,
        Cardano.CertificateType.StakeKeyRegistration,
        address
      );
      const isUnregistering = isLastStakeKeyCertOfType(
        certificatesInFlight,
        Cardano.CertificateType.StakeKeyDeregistration,
        address
      );
      return isRegistering
        ? StakeKeyStatus.Registering
        : isUnregistering
        ? StakeKeyStatus.Unregistering
        : isRegistered
        ? StakeKeyStatus.Registered
        : StakeKeyStatus.Unregistered;
    });
  };

const accountCertificateTransactions = (
  transactions$: Observable<TxWithEpoch[]>,
  rewardAccount: Cardano.RewardAccount
) => {
  const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
  return transactions$.pipe(
    map((transactions) =>
      transactions
        .map(({ tx, epoch }) => ({
          certificates: (tx.body.certificates || [])
            .filter((cert): cert is Cardano.StakeDelegationCertificate | Cardano.StakeAddressCertificate =>
              [...RegAndDeregCertificateTypes, Cardano.CertificateType.StakeDelegation].includes(cert.__typename)
            )
            .filter((cert) => cert.stakeKeyHash === stakeKeyHash),
          epoch
        }))
        .filter(({ certificates }) => certificates.length > 0)
    ),
    distinctUntilChanged((a, b) => isEqual(a, b))
  );
};

type ObservableType<O> = O extends Observable<infer T> ? T : unknown;
type TransactionsCertificates = ObservableType<ReturnType<typeof accountCertificateTransactions>>;

export const getStakePoolIdAtEpoch = (transactions: TransactionsCertificates) => (atEpoch: Cardano.EpochNo) => {
  const certificatesUpToEpoch = transactions
    .filter(({ epoch }) => epoch < atEpoch - 2)
    .map(({ certificates }) => certificates);
  if (!isLastStakeKeyCertOfType(certificatesUpToEpoch, Cardano.CertificateType.StakeKeyRegistration)) return;
  const delegationTxCertificates = findLast(certificatesUpToEpoch, (certs) =>
    includesAnyCertificate(certs, [Cardano.CertificateType.StakeDelegation])
  );
  if (!delegationTxCertificates) return;
  return findLast(delegationTxCertificates.filter(isDelegationCertificate))?.poolId;
};

export const createDelegateeTracker = (
  stakePoolProvider: ObservableStakePoolProvider,
  epoch$: Observable<Cardano.EpochNo>,
  certificates$: Observable<TransactionsCertificates>
): Observable<Delegatee | undefined> =>
  combineLatest([certificates$, epoch$]).pipe(
    switchMap(([transactions, lastEpoch]) => {
      const stakePoolIds = [
        Cardano.EpochNo(lastEpoch + 1),
        Cardano.EpochNo(lastEpoch + 2),
        Cardano.EpochNo(lastEpoch + 3)
      ].map(getStakePoolIdAtEpoch(transactions));
      const uniqStakePoolIds = uniq(stakePoolIds.filter(isNotNil));
      return stakePoolProvider(uniqStakePoolIds).pipe(
        map((stakePools) => stakePoolIds.map((poolId) => stakePools.find((pool) => pool.id === poolId) || undefined)),
        map(([currentEpoch, nextEpoch, nextNextEpoch]) => ({ currentEpoch, nextEpoch, nextNextEpoch }))
      );
    }),
    distinctUntilChanged((a, b) => isEqual(a, b))
  );

export const addressKeyStatuses = (
  addresses: Cardano.RewardAccount[],
  transactions$: Observable<TxWithEpoch[]>,
  transactionsInFlight$: Observable<TxInFlight[]>
) =>
  combineLatest([transactions$, transactionsInFlight$]).pipe(
    map(getAccountsKeyStatus(addresses)),
    distinctUntilChanged(shallowArrayEquals)
  );

export const addressDelegatees = (
  addresses: Cardano.RewardAccount[],
  transactions$: Observable<TxWithEpoch[]>,
  stakePoolProvider: ObservableStakePoolProvider,
  epoch$: Observable<Cardano.EpochNo>
) =>
  combineLatest(
    addresses.map((address) =>
      createDelegateeTracker(stakePoolProvider, epoch$, accountCertificateTransactions(transactions$, address))
    )
  );

export const addressRewards = (
  rewardAccounts: Cardano.RewardAccount[],
  transactionsInFlight$: Observable<TxInFlight[]>,
  rewardsProvider: ObservableRewardsProvider,
  balancesStore: KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>
): Observable<Cardano.Lovelace[]> => {
  // Allow identical rewards$ emits to fix corner case.
  // Epoch change can trigger rewards fetch before tx is detected as confirmed:
  // rewards$:             'a-b---b' b:{a-tx.rewards} <-- allow 'b' to emitted twice
  // withdrawalsInFlight$: 'x---y--' x:[tx], y:[]
  // combineLatest:        'm-n---p' m:{a-tx.rewards}, n:{b-tx.rewards}, p:{b}
  const rewards$ = concat(
    balancesStore.getValues(rewardAccounts),
    rewardsProvider(rewardAccounts, () => false /* allow identical emits */).pipe(
      tap((balances) => {
        for (const [i, rewardAccount] of rewardAccounts.entries()) {
          balancesStore.setValue(rewardAccount, balances[i]);
        }
      })
    )
  );
  const withdrawalsInFlight$ = transactionsInFlight$.pipe(
    map((txs) => txs.flatMap(({ body: { withdrawals } }) => withdrawals).filter(isNotNil)),
    distinctUntilChanged(deepEquals)
  );
  return combineLatest([rewards$, withdrawalsInFlight$]).pipe(
    startWith([[] as bigint[], [] as Cardano.Withdrawal[]] as const),
    pairwise(),
    mergeMap(([[_, prevWithdrawalsInFlight], [totalRewards, withdrawalsInFlight]]) => {
      // Either rewards$ or withdrawalsInFlight$ can change.
      // If the change was on withdrawalsInFlight$ AND it's size is smaller (which means a withdrawal tx was confirmed),
      // then we expect rewards$ to also emit, as it's balance must change after such transaction.
      // This is coupled with implementation of `rewardsProvider` observable, as it assumes that
      // rewards re-fetch is triggered by transaction confirmation, therefore must happen AFTER it.
      if (prevWithdrawalsInFlight.length > withdrawalsInFlight.length) {
        return EMPTY;
      }
      return of(totalRewards.map((total, i) => total - getWithdrawalQuantity(withdrawalsInFlight, rewardAccounts[i])));
    }),
    distinctUntilChanged(deepEquals)
  );
};

export const toRewardAccounts =
  (addresses: Cardano.RewardAccount[]) =>
  ([statuses, delegatees, rewards]: [StakeKeyStatus[], (Delegatee | undefined)[], Cardano.Lovelace[]]) =>
    addresses.map(
      (address, i): RewardAccount => ({
        address,
        delegatee: delegatees[i],
        keyStatus: statuses[i],
        rewardBalance: rewards[i]
      })
    );

export const createRewardAccountsTracker = ({
  rewardAccountAddresses$,
  stakePoolProvider,
  rewardsProvider,
  epoch$,
  balancesStore,
  transactions$,
  transactionsInFlight$
}: {
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  stakePoolProvider: ObservableStakePoolProvider;
  rewardsProvider: ObservableRewardsProvider;
  balancesStore: KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>;
  epoch$: Observable<Cardano.EpochNo>;
  transactions$: Observable<TxWithEpoch[]>;
  transactionsInFlight$: Observable<TxInFlight[]>;
}) =>
  rewardAccountAddresses$.pipe(
    switchMap((rewardAccounts) =>
      combineLatest([
        addressKeyStatuses(rewardAccounts, transactions$, transactionsInFlight$),
        addressDelegatees(rewardAccounts, transactions$, stakePoolProvider, epoch$),
        addressRewards(rewardAccounts, transactionsInFlight$, rewardsProvider, balancesStore)
      ]).pipe(map(toRewardAccounts(rewardAccounts)))
    )
  );
