import { Cardano } from '@cardano-sdk/core';
import { InMemoryRewardsHistoryStore } from '../../../src/persistence';
import {
  RewardsHistory,
  RewardsHistoryProvider,
  TrackedRewardsProvider,
  createRewardsHistoryProvider,
  createRewardsHistoryTracker
} from '../../../src/services';
import { createTestScheduler, mockProviders } from '@cardano-sdk/util-dev';
import { dummyLogger } from 'ts-log';
import { firstValueFrom, of } from 'rxjs';

const { mockRewardsProvider, rewardAccount, rewardsHistory } = mockProviders;

describe('RewardsHistory', () => {
  const rewardAccounts = [rewardAccount];
  const logger = dummyLogger;

  describe('createRewardsHistoryProvider', () => {
    let rewardsProvider: TrackedRewardsProvider;
    let provider: RewardsHistoryProvider;

    beforeEach(() => {
      rewardsProvider = new TrackedRewardsProvider(mockRewardsProvider());
      provider = createRewardsHistoryProvider(rewardsProvider, {
        initialInterval: 1
      });
    });

    it('when lower bound is specified: queries underlying provider', async () => {
      const epoch = Cardano.EpochNo(1); // TODO review
      expect(await firstValueFrom(provider(rewardAccounts, Cardano.EpochNo(1), of(epoch), logger))).toBe(
        rewardsHistory
      );
    });

    it('when lower bound is not specified: sets rewardsHistory as initialized and returns empty array', async () => {
      const epoch = Cardano.EpochNo(1); // TODO review
      expect(await firstValueFrom(provider(rewardAccounts, null, of(epoch), logger))).toEqual(new Map());
      expect(rewardsProvider.stats.rewardsHistory$.value.initialized).toBe(true);
    });
  });

  describe('createRewardsHistoryTracker', () => {
    it('emits rewards from storage, then from provider; stores rewards from provider', async () => {
      const accountRewardsHistory = rewardsHistory.get(rewardAccount)!;
      const epoch = accountRewardsHistory[0].epoch;
      const store = new InMemoryRewardsHistoryStore();
      const storedReward = accountRewardsHistory[0];
      await firstValueFrom(store.setAll([{ key: rewardAccount, value: [storedReward] }]));
      store.setAll = jest.fn().mockImplementation(store.setAll);

      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const getRewardsHistory = jest.fn().mockReturnValue(cold('-a', { a: rewardsHistory }));
        const epoch$ = of(epoch);
        const target$ = createRewardsHistoryTracker(of(rewardAccounts), epoch$, getRewardsHistory, store, logger);
        expectObservable(target$).toBe('ab', {
          a: {
            all: [storedReward],
            avgReward: storedReward.rewards,
            lastReward: storedReward,
            lifetimeRewards: storedReward.rewards
          },
          b: {
            all: accountRewardsHistory,
            avgReward: 10_500n,
            lastReward: accountRewardsHistory[1],
            lifetimeRewards: 21_000n
          } as RewardsHistory
        });
        flush();
        expect(getRewardsHistory).toBeCalledTimes(1);
        expect(getRewardsHistory).toBeCalledWith(rewardAccounts, Cardano.EpochNo(1), epoch$, logger);
        expect(store.setAll).toBeCalledTimes(1);
        expect(store.setAll).toBeCalledWith([{ key: rewardAccount, value: accountRewardsHistory }]);
      });
    });
  });
});
