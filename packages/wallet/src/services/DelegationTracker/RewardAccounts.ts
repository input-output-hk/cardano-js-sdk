/* eslint-disable unicorn/no-nested-ternary */
import { BigIntMath, deepEquals, isNotNil } from '@cardano-sdk/util';
import { Cardano, RewardsProvider } from '@cardano-sdk/core';
import { Delegatee, RewardAccount, StakeKeyStatus } from '../types';
import { KeyValueStore } from '../../persistence';
import { Observable, combineLatest, concat, distinctUntilChanged, filter, map, merge, of, switchMap, tap } from 'rxjs';
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

export const createQueryStakePoolsProvider =
  (
    stakePoolProvider: TrackedStakePoolProvider,
    store: KeyValueStore<Cardano.PoolId, Cardano.StakePool>,
    retryBackoffConfig: RetryBackoffConfig
  ) =>
  (poolIds: Cardano.PoolId[]) => {
    if (poolIds.length === 0) {
      stakePoolProvider.setStatInitialized(stakePoolProvider.stats.queryStakePools$);
      return of([]);
    }
    return merge(
      store.getValues(poolIds),
      coldObservableProvider({
        provider: () =>
          stakePoolProvider
            .queryStakePools({
              filters: { identifier: { values: poolIds.map((poolId) => ({ id: poolId })) } }
            })
            .then(({ pageResults }) => pageResults),
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
  { body: { withdrawals } }: Cardano.NewTxAlonzo,
  rewardAccount?: Cardano.RewardAccount
): Cardano.Lovelace =>
  BigIntMath.sum(
    withdrawals?.map(({ quantity, stakeAddress }) => (stakeAddress === rewardAccount ? quantity : 0n)) || []
  );

export const fetchRewardsTrigger$ = (
  epoch$: Observable<Cardano.EpochNo>,
  txConfirmed$: Observable<Cardano.NewTxAlonzo>,
  rewardAccount: Cardano.RewardAccount
) =>
  merge(
    // Reload every epoch and after every tx that has withdrawals for this reward account
    epoch$,
    txConfirmed$.pipe(
      map((tx) => getWithdrawalQuantity(tx, rewardAccount)),
      filter((withdrawalQty) => withdrawalQty > 0n)
    )
  );

export const createRewardsProvider =
  (
    epoch$: Observable<Cardano.EpochNo>,
    txConfirmed$: Observable<Cardano.NewTxAlonzo>,
    rewardsProvider: RewardsProvider,
    retryBackoffConfig: RetryBackoffConfig
  ) =>
  (rewardAccounts: Cardano.RewardAccount[]): Observable<Cardano.Lovelace[]> =>
    combineLatest(
      rewardAccounts.map((rewardAccount) =>
        coldObservableProvider({
          equals: isEqual,
          provider: () => rewardsProvider.rewardAccountBalance({ rewardAccount }),
          retryBackoffConfig,
          trigger$: fetchRewardsTrigger$(epoch$, txConfirmed$, rewardAccount)
        }).pipe(distinctUntilChanged())
      )
    );
export type ObservableRewardsProvider = ReturnType<typeof createRewardsProvider>;

const isDelegationCertificate = (cert: Cardano.Certificate): cert is Cardano.StakeDelegationCertificate =>
  cert.__typename === Cardano.CertificateType.StakeDelegation;

const getAccountsKeyStatus =
  (addresses: Cardano.RewardAccount[]) =>
  ([transactions, transactionsInFlight]: [TxWithEpoch[], Cardano.NewTxAlonzo[]]) => {
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
  const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount);
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
      const stakePoolIds = [lastEpoch + 1, lastEpoch + 2, lastEpoch + 3].map(getStakePoolIdAtEpoch(transactions));
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
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>
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
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>,
  rewardsProvider: ObservableRewardsProvider,
  balancesStore: KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>
): Observable<Cardano.Lovelace[]> =>
  combineLatest([
    concat(
      balancesStore.getValues(rewardAccounts),
      rewardsProvider(rewardAccounts).pipe(
        tap((balances) => {
          for (const [i, rewardAccount] of rewardAccounts.entries()) {
            balancesStore.setValue(rewardAccount, balances[i]);
          }
        })
      )
    ),
    transactionsInFlight$
  ]).pipe(
    map(([totalRewards, transactionsInFlight]) =>
      totalRewards.map(
        (total, i) =>
          total - transactionsInFlight.reduce((sum, tx) => sum + getWithdrawalQuantity(tx, rewardAccounts[i]), 0n)
      )
    ),
    distinctUntilChanged(deepEquals)
  );

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
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
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
