import { BigIntMath, isNotNil } from '@cardano-sdk/util';
import { Cardano, EpochRewards, createTxInspector, signedCertificatesInspector } from '@cardano-sdk/core';
import { KeyValueStore } from '../../persistence';
import { Observable, concat, distinctUntilChanged, map, of, switchMap, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistory } from '../types';
import { TrackedRewardsProvider } from '../ProviderTracker';
import { TxWithEpoch } from './types';
import { coldObservableProvider } from '../util';
import first from 'lodash/first';
import flatten from 'lodash/flatten';
import groupBy from 'lodash/groupBy';

const sumRewards = (arrayOfRewards: EpochRewards[]) => BigIntMath.sum(arrayOfRewards.map(({ rewards }) => rewards));
const avgReward = (arrayOfRewards: EpochRewards[]) => sumRewards(arrayOfRewards) / BigInt(arrayOfRewards.length);

export const createRewardsHistoryProvider =
  (rewardsProvider: TrackedRewardsProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (
    rewardAccounts: Cardano.RewardAccount[],
    lowerBound: Cardano.Epoch | null
  ): Observable<Map<Cardano.RewardAccount, EpochRewards[]>> => {
    if (lowerBound) {
      return coldObservableProvider({
        provider: () =>
          rewardsProvider.rewardsHistory({
            epochs: { lowerBound },
            rewardAccounts
          }),
        retryBackoffConfig
      });
    }
    rewardsProvider.setStatInitialized(rewardsProvider.stats.rewardsHistory$);
    return of(new Map());
  };

export type RewardsHistoryProvider = ReturnType<typeof createRewardsHistoryProvider>;

const firstDelegationEpoch$ = (transactions$: Observable<TxWithEpoch[]>, rewardAccounts: Cardano.RewardAccount[]) =>
  transactions$.pipe(
    map((transactions) =>
      first(
        transactions.filter(({ tx }) => {
          const inspectTx = createTxInspector({
            signedCertificates: signedCertificatesInspector(rewardAccounts, [Cardano.CertificateType.StakeDelegation])
          });
          return inspectTx(tx).signedCertificates.length > 0;
        })
      )
    ),
    map((tx) => (isNotNil(tx) ? tx.epoch + 3 : null)),
    distinctUntilChanged()
  );

export const createRewardsHistoryTracker = (
  transactions$: Observable<TxWithEpoch[]>,
  rewardAccounts$: Observable<Cardano.RewardAccount[]>,
  rewardsHistoryProvider: RewardsHistoryProvider,
  rewardsHistoryStore: KeyValueStore<Cardano.RewardAccount, EpochRewards[]>
): Observable<RewardsHistory> =>
  rewardAccounts$
    .pipe(
      switchMap((rewardAccounts) =>
        concat(
          rewardsHistoryStore
            .getValues(rewardAccounts)
            .pipe(map((rewards) => new Map(rewardAccounts.map((rewardAccount, i) => [rewardAccount, rewards[i]])))),
          firstDelegationEpoch$(transactions$, rewardAccounts).pipe(
            switchMap((firstEpoch) => rewardsHistoryProvider(rewardAccounts, firstEpoch)),
            tap((allRewards) =>
              rewardsHistoryStore.setAll([...allRewards.entries()].map(([key, value]) => ({ key, value })))
            )
          )
        )
      )
    )
    .pipe(
      map((rewardsByAccount) => {
        const allRewards = flatten([...rewardsByAccount.values()]);
        if (allRewards.length === 0) {
          return {
            all: [],
            avgReward: null,
            lastReward: null,
            lifetimeRewards: 0n
          } as RewardsHistory;
        }
        const rewardsByEpoch = groupBy(allRewards, ({ epoch }) => epoch);
        const epochs = Object.keys(rewardsByEpoch)
          .map((epoch) => Number(epoch))
          .sort();
        const all = epochs.map((epoch) => ({ epoch, rewards: sumRewards(rewardsByEpoch[epoch]) }));

        return {
          all,
          avgReward: avgReward(allRewards),
          lastReward: all[all.length - 1],
          lifetimeRewards: sumRewards(allRewards)
        };
      })
    );
