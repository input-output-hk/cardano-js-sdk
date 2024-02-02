/* eslint-disable unicorn/no-nested-ternary */
import * as Crypto from '@cardano-sdk/crypto';
import { BigIntMath, deepEquals, isNotNil } from '@cardano-sdk/util';
import { Cardano, RewardsProvider, StakePoolProvider } from '@cardano-sdk/core';
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
import { OutgoingOnChainTx, TxInFlight } from '../types';
import { PAGE_SIZE } from '../TransactionsTracker';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedStakePoolProvider } from '../ProviderTracker';
import { TxWithEpoch } from './types';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { lastStakeKeyCertOfType } from './transactionCertificates';
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

const getAccountsKeyStatus =
  (addresses: Cardano.RewardAccount[]) =>
  ([transactions, transactionsInFlight]: [TxWithEpoch[], TxInFlight[]]) => {
    const certificatesInFlight = transactionsInFlight.map(({ body: { certificates } }) => certificates || []);
    return addresses.map((address) => {
      const regCert = lastStakeKeyCertOfType(
        transactions.map(
          ({
            tx: {
              body: { certificates }
            }
          }) => certificates || []
        ),
        Cardano.StakeRegistrationCertificateTypes,
        address
      );

      let deposit: Cardano.Lovelace | undefined;
      if (regCert && Cardano.isCertType(regCert, Cardano.PostConwayStakeRegistrationCertificateTypes)) {
        deposit = regCert.deposit;
      }

      const isRegistering = !!lastStakeKeyCertOfType(
        certificatesInFlight,
        Cardano.StakeRegistrationCertificateTypes,
        address
      );
      const isUnregistering = !!lastStakeKeyCertOfType(
        certificatesInFlight,
        [Cardano.CertificateType.StakeDeregistration, Cardano.CertificateType.Unregistration],
        address
      );
      const keyStatus = isRegistering
        ? Cardano.StakeKeyStatus.Registering
        : isUnregistering
        ? Cardano.StakeKeyStatus.Unregistering
        : regCert
        ? Cardano.StakeKeyStatus.Registered
        : Cardano.StakeKeyStatus.Unregistered;

      return { ...(keyStatus === Cardano.StakeKeyStatus.Registered && { deposit }), keyStatus };
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
            .map((cert) =>
              Cardano.isCertType(cert, [
                ...Cardano.RegAndDeregCertificateTypes,
                ...Cardano.StakeDelegationCertificateTypes
              ])
                ? cert
                : null
            )
            .filter(isNotNil)
            .filter((cert) => (cert.stakeCredential.hash as unknown as Crypto.Ed25519KeyHashHex) === stakeKeyHash),
          epoch
        }))
        .filter(({ certificates }) => certificates.length > 0)
    ),
    distinctUntilChanged((a, b) => isEqual(a, b))
  );
};

type ObservableType<O> = O extends Observable<infer T> ? T : unknown;
type TransactionsCertificates = ObservableType<ReturnType<typeof accountCertificateTransactions>>;

/**
 * Check if the stake key was registered and is delegated, and return the pool ID.
 * A stake key is considered delegated 3 epochs after the certificate was sent.
 *
 * @returns
 *  - the stake pool ID that is delegated to at the given epoch.
 *  - undefined if the stake key was not registered.
 * Returns the stake pool ID that is delegated to at the given epoch.
 * If the stake key was not registered, it returns undefined.
 */
export const getStakePoolIdAtEpoch = (transactions: TransactionsCertificates) => (atEpoch: Cardano.EpochNo) => {
  const certificatesUpToEpoch = transactions
    .filter(({ epoch }) => epoch < atEpoch - 2)
    .map(({ certificates }) => certificates);
  if (!lastStakeKeyCertOfType(certificatesUpToEpoch, Cardano.StakeRegistrationCertificateTypes)) {
    return;
  }

  const delegationTxCertificates = findLast(certificatesUpToEpoch, (certs) =>
    Cardano.includesAnyCertificate(certs, Cardano.StakeDelegationCertificateTypes)
  );
  if (!delegationTxCertificates) return;
  return findLast(
    delegationTxCertificates
      .map((cert) => (Cardano.isCertType(cert, Cardano.StakeDelegationCertificateTypes) ? cert : null))
      .filter(isNotNil)
  )?.poolId;
};

export const createDelegateeTracker = (
  stakePoolProvider: ObservableStakePoolProvider,
  epoch$: Observable<Cardano.EpochNo>,
  certificates$: Observable<TransactionsCertificates>
): Observable<Cardano.Delegatee | undefined> =>
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
    distinctUntilChanged(deepEquals)
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
  ([statuses, delegatees, rewards]: [
    { keyStatus: Cardano.StakeKeyStatus; deposit?: Cardano.Lovelace }[],
    (Cardano.Delegatee | undefined)[],
    Cardano.Lovelace[]
  ]) =>
    addresses.map(
      (address, i): Cardano.RewardAccountInfo => ({
        address,
        delegatee: delegatees[i],
        deposit: statuses[i].deposit,
        keyStatus: statuses[i].keyStatus,
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
