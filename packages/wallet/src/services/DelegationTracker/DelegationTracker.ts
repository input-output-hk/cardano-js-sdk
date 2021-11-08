import { Cardano, NetworkInfo, StakePoolSearchProvider } from '@cardano-sdk/core';
import { Delegation, RewardsHistory } from '../types';
import { EMPTY, Observable, from, merge } from 'rxjs';
import { ProviderTrackerSubject, SourceTrackerConfig, epoch$ } from '../util';
import { SimpleProvider } from '../..';
import { Transactions } from '..';
import { certificateTransactions } from './util';
import { isEqual } from 'lodash-es';

export type ObservableStakePoolSearchProvider = (fragments: string[]) => Observable<Cardano.StakePool[]>;

export interface DelegationTrackerProps {
  // TODO
  // stakePoolSearchProvider: ObservableStakePoolSearchProvider;
  rewardsHistoryProvider: SimpleProvider<RewardsHistory>;
  transactionsTracker: Transactions;
  config: SourceTrackerConfig;
  networkInfo$: Observable<NetworkInfo>;
}

export const createStakePoolSearchProvider =
  (stakePoolSearchProvider: StakePoolSearchProvider): ObservableStakePoolSearchProvider =>
  (fragments) =>
    from(stakePoolSearchProvider.queryStakePools(fragments));

export const createDelegationTracker = ({
  config,
  rewardsHistoryProvider,
  transactionsTracker,
  networkInfo$
}: DelegationTrackerProps): Delegation => {
  const rewardsHistory$ = new ProviderTrackerSubject(
    {
      config,
      // TODO: add new util to compare only .all
      equals: isEqual,
      provider: rewardsHistoryProvider
    },
    {
      trigger$: epoch$(networkInfo$)
    }
  );
  const delegatee$ = new ProviderTrackerSubject(
    {
      config,
      equals: isEqual,
      // TODO: add new util to compare only ID, metadata hash and ext metadata hash
      provider: () => EMPTY
    },
    {
      trigger$: merge(
        epoch$(networkInfo$),
        certificateTransactions(transactionsTracker, [Cardano.CertificateType.StakeDelegation])
      )
    }
  );
  return {
    delegatee$,
    rewardsHistory$,
    shutdown: () => {
      rewardsHistory$.complete();
      delegatee$.complete();
    },
    sync: () => {
      rewardsHistory$.sync();
      delegatee$.sync();
    }
  };
};
