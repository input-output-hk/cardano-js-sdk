/* eslint-disable unicorn/no-nested-ternary */
import { Cardano, StakePoolSearchProvider, util } from '@cardano-sdk/core';
import { Delegatee, RewardAccount, StakeKeyStatus } from '../types';
import { Observable, combineLatest, distinctUntilChanged, map, switchMap } from 'rxjs';
import { RegAndDeregCertificateTypes } from '.';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch } from './types';
import { coldObservableProvider, shallowArrayEquals } from '../util';
import { findLast, isEqual, uniq } from 'lodash-es';
import { includesAnyCertificate } from '..';
import { isLastStakeKeyCertOfType } from './transactionCertificates';

export const createQueryStakePoolsProvider =
  (stakePoolSearchProvider: StakePoolSearchProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (fragments: Cardano.PoolId[]) =>
    coldObservableProvider(() => stakePoolSearchProvider.queryStakePools(fragments), retryBackoffConfig);

export type ObservableStakePoolSearchProvider = ReturnType<typeof createQueryStakePoolsProvider>;

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

const accountCertificateTransactions = (transactions$: Observable<TxWithEpoch[]>, rewardAccount: Cardano.Address) =>
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
  addresses: Cardano.Address[],
  transactions$: Observable<TxWithEpoch[]>,
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>
) =>
  combineLatest([transactions$, transactionsInFlight$]).pipe(
    map(getAccountsKeyStatus(addresses)),
    distinctUntilChanged(shallowArrayEquals)
  );

export const addressDelegatees = (
  addresses: Cardano.Address[],
  transactions$: Observable<TxWithEpoch[]>,
  stakePoolSearchProvider: ObservableStakePoolSearchProvider,
  epoch$: Observable<Cardano.Epoch>
) =>
  combineLatest(
    addresses.map((address) =>
      createDelegateeTracker(stakePoolSearchProvider, epoch$, accountCertificateTransactions(transactions$, address))
    )
  );

export const toRewardAccounts =
  (addresses: Cardano.Address[]) =>
  ([statuses, delegatees]: [StakeKeyStatus[], (Delegatee | undefined)[]]) =>
    addresses.map(
      (address, i): RewardAccount => ({
        address,
        delegatee: delegatees[i],
        keyStatus: statuses[i]
      })
    );

export const createRewardAccountsTracker = (
  rewardAccounts$: Observable<Cardano.Address[]>,
  stakePoolSearchProvider: ObservableStakePoolSearchProvider,
  epoch$: Observable<Cardano.Epoch>,
  transactions$: Observable<TxWithEpoch[]>,
  transactionsInFlight$: Observable<Cardano.NewTxAlonzo[]>
) =>
  rewardAccounts$.pipe(
    switchMap((addresses) =>
      combineLatest([
        addressKeyStatuses(addresses, transactions$, transactionsInFlight$),
        addressDelegatees(addresses, transactions$, stakePoolSearchProvider, epoch$)
      ]).pipe(map(toRewardAccounts(addresses)))
    )
  );
