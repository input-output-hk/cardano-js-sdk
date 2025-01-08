import { BigIntMath } from '@cardano-sdk/util';
import { Cardano, Reward } from '@cardano-sdk/core';
import { KeyValueStore } from '../../persistence';
import { Logger } from 'ts-log';
import { Observable, concat, map, of, switchMap, tap } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { RewardsHistory } from '../types';
import { TrackedRewardsProvider } from '../ProviderTracker';
import { pollProvider } from '../util';
import flatten from 'lodash/flatten.js';
import sortBy from 'lodash/sortBy.js';

const sumRewards = (arrayOfRewards: Reward[]) => BigIntMath.sum(arrayOfRewards.map(({ rewards }) => rewards));
const avgReward = (arrayOfRewards: Reward[]) => sumRewards(arrayOfRewards) / BigInt(arrayOfRewards.length);

export const createRewardsHistoryProvider =
  (rewardsProvider: TrackedRewardsProvider, retryBackoffConfig: RetryBackoffConfig) =>
  (
    rewardAccounts: Cardano.RewardAccount[],
    lowerBound: Cardano.EpochNo | null,
    epoch$: Observable<Cardano.EpochNo>,
    logger: Logger
  ): Observable<Map<Cardano.RewardAccount, Reward[]>> => {
    if (lowerBound) {
      return pollProvider({
        logger,
        retryBackoffConfig,
        sample: () =>
          rewardsProvider.rewardsHistory({
            epochs: { lowerBound },
            rewardAccounts
          }),
        trigger$: epoch$
      });
    }
    rewardsProvider.setStatInitialized(rewardsProvider.stats.rewardsHistory$);
    return of(new Map());
  };

export type RewardsHistoryProvider = ReturnType<typeof createRewardsHistoryProvider>;

export const createRewardsHistoryTracker = (
  rewardAccounts$: Observable<Cardano.RewardAccount[]>,
  epoch$: Observable<Cardano.EpochNo>,
  rewardsHistoryProvider: RewardsHistoryProvider,
  rewardsHistoryStore: KeyValueStore<Cardano.RewardAccount, Reward[]>,
  logger: Logger
): Observable<RewardsHistory> =>
  rewardAccounts$
    .pipe(
      tap((rewardsAccounts) => logger.debug(`Fetching rewards for ${rewardsAccounts.length} accounts`)),
      switchMap((rewardAccounts) =>
        concat(
          rewardsHistoryStore
            .getValues(rewardAccounts)
            .pipe(map((rewards) => new Map(rewardAccounts.map((rewardAccount, i) => [rewardAccount, rewards[i]])))),
          // this could be optimized to fetch rewards > last local reward within stability window
          rewardsHistoryProvider(rewardAccounts, Cardano.EpochNo(1), epoch$, logger).pipe(
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
