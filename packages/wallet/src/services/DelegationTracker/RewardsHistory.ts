import { BigIntMath, Cardano, WalletProvider, util } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map, of, switchMap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch } from './types';
import { coldObservableProvider } from '../util';
import { first } from 'lodash-es';
import { transactionHasAnyCertificate } from './transactionCertificates';

export const createRewardsHistoryProvider =
  (
    walletProvider: WalletProvider,
    rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>,
    retryBackoffConfig: RetryBackoffConfig
  ) =>
  (lowerBound: Cardano.Epoch | null) =>
    lowerBound
      ? rewardAccountAddresses$.pipe(
          switchMap((stakeAddresses) =>
            coldObservableProvider(
              () =>
                walletProvider.rewardsHistory({
                  epochs: { lowerBound },
                  stakeAddresses
                }),
              retryBackoffConfig
            )
          )
        )
      : of([]);

export type RewardsHistoryProvider = ReturnType<typeof createRewardsHistoryProvider>;

const firstDelegationEpoch$ = (transactions$: Observable<TxWithEpoch[]>) =>
  transactions$.pipe(
    map((transactions) =>
      first(
        transactions.filter(({ tx }) => transactionHasAnyCertificate(tx, [Cardano.CertificateType.StakeDelegation]))
      )
    ),
    map((tx) => (util.isNotNil(tx) ? tx.epoch + 3 : null)),
    distinctUntilChanged()
  );

export const createRewardsHistoryTracker = (
  transactions$: Observable<TxWithEpoch[]>,
  rewardsHistoryProvider: RewardsHistoryProvider
) =>
  firstDelegationEpoch$(transactions$).pipe(
    switchMap((firstEpoch) => rewardsHistoryProvider(firstEpoch)),
    map((all) => {
      const lifetimeRewards = BigIntMath.sum(all.map(({ rewards }) => rewards));
      return {
        all,
        avgReward: all.length > 0 ? lifetimeRewards / BigInt(all.length) : null,
        lastReward: all.length > 0 ? all[all.length - 1] : null,
        lifetimeRewards
      };
    })
  );
