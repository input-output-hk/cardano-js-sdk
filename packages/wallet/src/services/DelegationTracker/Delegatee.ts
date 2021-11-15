import { Cardano, StakePoolSearchProvider, util } from '@cardano-sdk/core';
import { Delegatee } from '../types';
import { Observable, combineLatest, map, switchMap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch } from './types';
import { coldObservableProvider, isLastStakeKeyCertOfType, transactionHasAnyCertificate } from '../util';
import { findLast, uniq } from 'lodash-es';

export const createQueryStakePoolsProvider =
  (stakePoolSearchProvider: StakePoolSearchProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (fragments: Cardano.PoolId[]) =>
    coldObservableProvider(() => stakePoolSearchProvider.queryStakePools(fragments), retryBackoffConfig);

export type ObservableStakePoolSearchProvider = ReturnType<typeof createQueryStakePoolsProvider>;

const isDelegationCertificate = (cert: Cardano.Certificate): cert is Cardano.StakeDelegationCertificate =>
  cert.__typename === Cardano.CertificateType.StakeDelegation;

export const getStakePoolIdAtEpoch = (transactions: TxWithEpoch[]) => (atEpoch: Cardano.Epoch) => {
  const transactionsUpToEpoch = transactions.filter(({ epoch }) => epoch <= atEpoch - 2).map(({ tx }) => tx);
  if (!isLastStakeKeyCertOfType(transactionsUpToEpoch, Cardano.CertificateType.StakeRegistration)) return;
  const delegationTx = findLast(transactionsUpToEpoch, (tx) =>
    transactionHasAnyCertificate(tx, [Cardano.CertificateType.StakeDelegation])
  );
  if (!delegationTx) return;
  return findLast(delegationTx?.body.certificates?.filter(isDelegationCertificate))?.poolId;
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
