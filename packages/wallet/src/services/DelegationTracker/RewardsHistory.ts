import { BigIntMath, isNotNil } from '@cardano-sdk/util';
import { Cardano, Reward, getCertificatesByType } from '@cardano-sdk/core';
import { KeyValueStore } from '../../persistence';
import { Logger } from 'ts-log';
import { Observable, concat, distinctUntilChanged, map, of, switchMap, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistory } from '../types';
import { TrackedRewardsProvider } from '../ProviderTracker';
import { TxWithEpoch } from './types';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import first from 'lodash/first.js';
import flatten from 'lodash/flatten.js';
import sortBy from 'lodash/sortBy.js';

const DELEGATION_EPOCHS_AHEAD_COUNT = 2;

export const calcFirstDelegationEpoch = (epoch: Cardano.EpochNo): number => epoch + DELEGATION_EPOCHS_AHEAD_COUNT;

const sumRewards = (arrayOfRewards: Reward[]) => BigIntMath.sum(arrayOfRewards.map(({ rewards }) => rewards));
const avgReward = (arrayOfRewards: Reward[]) => sumRewards(arrayOfRewards) / BigInt(arrayOfRewards.length);

export const createRewardsHistoryProvider =
  (rewardsProvider: TrackedRewardsProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (
    rewardAccounts: Cardano.RewardAccount[],
    lowerBound: Cardano.EpochNo | null,
    onFatalError?: (value: unknown) => void
  ): Observable<Map<Cardano.RewardAccount, Reward[]>> => {
    if (lowerBound) {
      return coldObservableProvider({
        onFatalError,
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
        transactions.filter(
          ({ tx }) => getCertificatesByType(tx, rewardAccounts, Cardano.StakeDelegationCertificateTypes).length > 0
        )
      )
    ),
    map((tx) => (isNotNil(tx) ? calcFirstDelegationEpoch(tx.epoch) : null)),
    distinctUntilChanged()
  );

export const createRewardsHistoryTracker = (
  transactions$: Observable<TxWithEpoch[]>,
  rewardAccounts$: Observable<Cardano.RewardAccount[]>,
  rewardsHistoryProvider: RewardsHistoryProvider,
  rewardsHistoryStore: KeyValueStore<Cardano.RewardAccount, Reward[]>,
  logger: Logger,
  onFatalError?: (value: unknown) => void
  // eslint-disable-next-line max-params
): Observable<RewardsHistory> =>
  rewardAccounts$
    .pipe(
      tap((rewardsAccounts) => logger.debug(`Fetching rewards for ${rewardsAccounts.length} accounts`)),
      switchMap((rewardAccounts) =>
        concat(
          rewardsHistoryStore
            .getValues(rewardAccounts)
            .pipe(map((rewards) => new Map(rewardAccounts.map((rewardAccount, i) => [rewardAccount, rewards[i]])))),
          firstDelegationEpoch$(transactions$, rewardAccounts).pipe(
            tap((firstEpoch) => logger.debug(`Fetching history rewards since epoch ${firstEpoch}`)),
            switchMap((firstEpoch) =>
              rewardsHistoryProvider(rewardAccounts, Cardano.EpochNo(firstEpoch!), onFatalError)
            ),
            tap((allRewards) =>
              rewardsHistoryStore.setAll([...allRewards.entries()].map(([key, value]) => ({ key, value })))
            )
          )
        )
      )
    )
    .pipe(
      map((rewardsByAccount) => {
        const all = sortBy(flatten([...rewardsByAccount.values()]), 'epoch');
        if (all.length === 0) {
          logger.debug('No rewards found');
          return {
            all: [],
            avgReward: null,
            lastReward: null,
            lifetimeRewards: 0n
          } as RewardsHistory;
        }

        const rewardsHistory: RewardsHistory = {
          all,
          avgReward: avgReward(all),
          lastReward: all[all.length - 1],
          lifetimeRewards: sumRewards(all)
        };
        logger.debug(
          `Rewards between epochs ${rewardsHistory.all[0].epoch} and ${
            rewardsHistory.all[rewardsHistory.all.length - 1].epoch
          }`,
          `average:${rewardsHistory.avgReward}`,
          `lastRewards:${rewardsHistory.lastReward}`,
          `lifetimeRewards:${rewardsHistory.lifetimeRewards}`
        );
        return rewardsHistory;
      })
    );
