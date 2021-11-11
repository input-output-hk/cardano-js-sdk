import { Cardano, StakePoolSearchProvider, util } from '@cardano-sdk/core';
import { Delegatee } from '../types';
import { Observable, combineLatest, map, switchMap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch, transactionHasAnyCertificate } from './util';
import { coldObservableProvider } from '../util';
import { findLast, uniq } from 'lodash-es';

export const createQueryStakePoolsProvider =
  (stakePoolSearchProvider: StakePoolSearchProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (fragments: Cardano.PoolId[]) =>
    coldObservableProvider(() => stakePoolSearchProvider.queryStakePools(fragments), retryBackoffConfig);

export type ObservableStakePoolSearchProvider = ReturnType<typeof createQueryStakePoolsProvider>;

const isDelegationCertificate = (cert: Cardano.Certificate): cert is Cardano.StakeDelegationCertificate =>
  cert.__typename === Cardano.CertificateType.StakeDelegation;

const RegAndDeregCertificateTypes = [
  Cardano.CertificateType.StakeRegistration,
  Cardano.CertificateType.StakeDeregistration
];

export const getStakePoolIdAtEpoch = (transactions: TxWithEpoch[]) => (atEpoch: Cardano.Epoch) => {
  const transactionsUpToEpoch = transactions.filter(({ epoch }) => epoch <= atEpoch - 2);
  const lastRegOrDereg = findLast(transactionsUpToEpoch, ({ tx }) =>
    transactionHasAnyCertificate(tx, RegAndDeregCertificateTypes)
  );
  if (!lastRegOrDereg) return;
  const isStakeKeyRegistered =
    findLast(
      lastRegOrDereg.tx.body.certificates!.filter(({ __typename }) => RegAndDeregCertificateTypes.includes(__typename))
    )?.__typename === Cardano.CertificateType.StakeRegistration;
  if (!isStakeKeyRegistered) return;
  const delegationTx = findLast(transactionsUpToEpoch, ({ tx }) =>
    transactionHasAnyCertificate(tx, [Cardano.CertificateType.StakeDelegation])
  );
  if (!delegationTx) return;
  return findLast(delegationTx?.tx.body.certificates?.filter(isDelegationCertificate))?.poolId;
};

export const createDelegateeTracker = (
  stakePoolSearchProvider: ObservableStakePoolSearchProvider,
  epoch$: Observable<Cardano.Epoch>,
  transactions$: Observable<TxWithEpoch[]>
): Observable<Delegatee> =>
  combineLatest([transactions$, epoch$]).pipe(
    switchMap(([transactions, lastEpoch]) => {
      const stakePoolIds = [lastEpoch, lastEpoch + 1, lastEpoch + 2].map(getStakePoolIdAtEpoch(transactions));
      return stakePoolSearchProvider(uniq(stakePoolIds.filter(util.isNotNil))).pipe(
        map((stakePools) => stakePoolIds.map((poolId) => stakePools.find((pool) => pool.id === poolId) || null)),
        map(([currentEpoch, nextEpoch, nextNextEpoch]) => ({ currentEpoch, nextEpoch, nextNextEpoch }))
      );
    })
  );
