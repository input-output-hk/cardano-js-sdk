/* eslint-disable unicorn/no-nested-ternary */
import { BigIntMath, Cardano, StakePoolSearchProvider, WalletProvider, util } from '@cardano-sdk/core';
import { Delegatee, RewardAccount, StakeKeyStatus } from '../types';
import { Observable, combineLatest, distinctUntilChanged, filter, map, merge, switchMap } from 'rxjs';
import { RegAndDeregCertificateTypes } from '.';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardBalance, includesAnyCertificate } from '..';
import { TxWithEpoch } from './types';
import { coldObservableProvider, deepEquals, shallowArrayEquals } from '../util';
import { findLast, isEqual, uniq } from 'lodash-es';
import { isLastStakeKeyCertOfType } from './transactionCertificates';

export const createQueryStakePoolsProvider =
  (stakePoolSearchProvider: StakePoolSearchProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (fragments: Cardano.PoolId[]) =>
    coldObservableProvider(() => stakePoolSearchProvider.queryStakePools(fragments), retryBackoffConfig);
export type ObservableStakePoolSearchProvider = ReturnType<typeof createQueryStakePoolsProvider>;

const getWithdrawalQuantity = (
  { body: { withdrawals } }: Cardano.NewTxAlonzo,
  rewardAccount?: Cardano.RewardAccount
): Cardano.Lovelace =>
  BigIntMath.sum(
    withdrawals?.map(({ quantity, stakeAddress }) => (stakeAddress === rewardAccount ? quantity : 0n)) || []
  );

export const fetchRewardsTrigger$ = (
  epoch$: Observable<Cardano.Epoch>,
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
    epoch$: Observable<Cardano.Epoch>,
    txConfirmed$: Observable<Cardano.NewTxAlonzo>,
    walletProvider: WalletProvider,
    retryBackoffConfig: RetryBackoffConfig
  ) =>
  (rewardAccounts: Cardano.RewardAccount[]) =>
    combineLatest(
      rewardAccounts.map((rewardAccount) =>
        coldObservableProvider(
          () => walletProvider.utxoDelegationAndRewards([], rewardAccount),
          retryBackoffConfig,
          fetchRewardsTrigger$(epoch$, txConfirmed$, rewardAccount)
        ).pipe(
          map(({ delegationAndRewards }) => delegationAndRewards?.rewards || 0n),
          distinctUntilChanged()
        )
      )
    );
export type ObservableRewardsProvider = ReturnType<typeof createRewardsProvider>;

const isDelegationCertificate = (cert: Cardano.Certificate): cert is Cardano.StakeDelegationCertificate =>
  cert.__typename === Cardano.CertificateType.StakeDelegation;

const getAccountsKeyStatus =
  (addresses: string[]) =>
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
) =>
  transactions$.pipe(
    map((transactions) =>
      transactions
        .map(({ tx, epoch }) => ({
          certificates: (tx.body.certificates || [])
            .filter((cert): cert is Cardano.StakeDelegationCertificate | Cardano.StakeAddressCertificate =>
              [...RegAndDeregCertificateTypes, Cardano.CertificateType.StakeDelegation].includes(cert.__typename)
            )
            .filter((cert) => cert.address === rewardAccount),
          epoch
        }))
        .filter(({ certificates }) => certificates.length > 0)
    ),
    distinctUntilChanged((a, b) => isEqual(a, b))
  );

type ObservableType<O> = O extends Observable<infer T> ? T : unknown;
type TransactionsCertificates = ObservableType<ReturnType<typeof accountCertificateTransactions>>;

export const getStakePoolIdAtEpoch = (transactions: TransactionsCertificates) => (atEpoch: Cardano.Epoch) => {
  const certificatesUpToEpoch = transactions
    .filter(({ epoch }) => epoch <= atEpoch - 2)
    .map(({ certificates }) => certificates);
  if (!isLastStakeKeyCertOfType(certificatesUpToEpoch, Cardano.CertificateType.StakeKeyRegistration)) return;
  const delegationTxCertificates = findLast(certificatesUpToEpoch, (certs) =>
    includesAnyCertificate(certs, [Cardano.CertificateType.StakeDelegation])
  );
  if (!delegationTxCertificates) return;
  return findLast(delegationTxCertificates.filter(isDelegationCertificate))?.poolId;
};

export const createDelegateeTracker = (
  stakePoolSearchProvider: ObservableStakePoolSearchProvider,
  epoch$: Observable<Cardano.Epoch>,
  certificates$: Observable<TransactionsCertificates>
): Observable<Delegatee | undefined> =>
  combineLatest([certificates$, epoch$]).pipe(
    switchMap(([transactions, lastEpoch]) => {
      const stakePoolIds = [lastEpoch, lastEpoch + 1, lastEpoch + 2].map(getStakePoolIdAtEpoch(transactions));
      return stakePoolSearchProvider(uniq(stakePoolIds.filter(util.isNotNil))).pipe(
        map((stakePools) => stakePoolIds.map((poolId) => stakePools.find((pool) => pool.id === poolId) || undefined)),
        map(([currentEpoch, nextEpoch, nextNextEpoch]) => {
          if (!nextNextEpoch) return;
          return { currentEpoch, nextEpoch, nextNextEpoch };
        })
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
  stakePoolSearchProvider: ObservableStakePoolSearchProvider,
  epoch$: Observable<Cardano.Epoch>
) =>
  combineLatest(
    addresses.map((address) =>
      createDelegateeTracker(stakePoolSearchProvider, epoch$, accountCertificateTransactions(transactions$, address))
    )
  );

export const addressRewards = (
  rewardAccounts: Cardano.RewardAccount[],
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>,
  rewardsProvider: ObservableRewardsProvider
): Observable<RewardBalance[]> =>
  combineLatest([rewardsProvider(rewardAccounts), transactionsInFlight$]).pipe(
    map(([totalRewards, transactionsInFlight]) =>
      totalRewards.map((total, i) => ({
        available:
          total - transactionsInFlight.reduce((sum, tx) => sum + getWithdrawalQuantity(tx, rewardAccounts[i]), 0n),
        total
      }))
    ),
    distinctUntilChanged(deepEquals)
  );

export const toRewardAccounts =
  (addresses: Cardano.RewardAccount[]) =>
  ([statuses, delegatees, rewards]: [StakeKeyStatus[], (Delegatee | undefined)[], RewardBalance[]]) =>
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
  stakePoolSearchProvider,
  rewardsProvider,
  epoch$,
  transactions$,
  transactionsInFlight$
}: {
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  stakePoolSearchProvider: ObservableStakePoolSearchProvider;
  rewardsProvider: ObservableRewardsProvider;
  epoch$: Observable<Cardano.Epoch>;
  transactions$: Observable<TxWithEpoch[]>;
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>;
}) =>
  rewardAccountAddresses$.pipe(
    switchMap((rewardAccounts) =>
      combineLatest([
        addressKeyStatuses(rewardAccounts, transactions$, transactionsInFlight$),
        addressDelegatees(rewardAccounts, transactions$, stakePoolSearchProvider, epoch$),
        addressRewards(rewardAccounts, transactionsInFlight$, rewardsProvider)
      ]).pipe(map(toRewardAccounts(rewardAccounts)))
    )
  );
