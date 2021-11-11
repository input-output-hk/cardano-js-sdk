import { BigIntMath, Cardano, WalletProvider, util } from '@cardano-sdk/core';
import { KeyManager } from '../../KeyManagement';
import { Observable, distinctUntilChanged, filter, map, switchMap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch, transactionHasAnyCertificate } from './util';
import { coldObservableProvider } from '../util';
import { first } from 'lodash-es';

export const createRewardsHistoryProvider =
  (walletProvider: WalletProvider, keyManager: KeyManager, retryBackoffConfig: RetryBackoffConfig) =>
  (lowerBound: Cardano.Epoch) =>
    coldObservableProvider(
      () => walletProvider.rewardsHistory({ epochs: { lowerBound }, stakeAddresses: [keyManager.rewardAccount] }),
      retryBackoffConfig
    );

export type RewardsHistoryProvider = ReturnType<typeof createRewardsHistoryProvider>;

const firstDelegationEpoch$ = (transactions$: Observable<TxWithEpoch[]>) =>
  transactions$.pipe(
    map((transactions) =>
      first(
        transactions.filter(({ tx }) => transactionHasAnyCertificate(tx, [Cardano.CertificateType.StakeDelegation]))
      )
    ),
    filter(util.isNotNil),
    map(({ epoch }) => epoch + 2),
    distinctUntilChanged()
  );

export const createRewardsHistoryTracker = (
  transactions$: Observable<TxWithEpoch[]>,
  rewardsHistoryProvider: RewardsHistoryProvider
) =>
  firstDelegationEpoch$(transactions$).pipe(
    switchMap((firstEpoch) => rewardsHistoryProvider(firstEpoch)),
    filter((rewards) => rewards.length > 0),
    map((all) => {
      const lifetimeRewards = BigIntMath.sum(all.map(({ rewards }) => rewards));
      return {
        all,
        avgReward: lifetimeRewards / BigInt(all.length),
        lastReward: all[all.length - 1],
        lifetimeRewards
      };
    })
  );
