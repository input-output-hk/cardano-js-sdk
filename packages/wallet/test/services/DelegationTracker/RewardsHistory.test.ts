import { Cardano } from '@cardano-sdk/core';
import { InMemoryRewardsHistoryStore } from '../../../src/persistence';
import {
  RewardsHistory,
  RewardsHistoryProvider,
  TrackedWalletProvider,
  createRewardsHistoryProvider,
  createRewardsHistoryTracker
} from '../../../src/services';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';
import { firstValueFrom, of } from 'rxjs';
import { mockWalletProvider, rewardAccount, rewardsHistory } from '../../mocks';

describe('RewardsHistory', () => {
  const rewardAccounts = [rewardAccount];

  describe('createRewardsHistoryProvider', () => {
    let walletProvider: TrackedWalletProvider;
    let provider: RewardsHistoryProvider;

    beforeEach(() => {
      walletProvider = new TrackedWalletProvider(mockWalletProvider());
      provider = createRewardsHistoryProvider(walletProvider, {
        initialInterval: 1
      });
    });

    it('when lower bound is specified: queries underlying provider', async () => {
      expect(await firstValueFrom(provider(rewardAccounts, 1))).toBe(rewardsHistory);
    });

    it('when lower bound is not specified: sets rewardsHistory as initialized and returns empty array', async () => {
      expect(await firstValueFrom(provider(rewardAccounts, null))).toEqual(new Map());
      expect(walletProvider.stats.rewardsHistory$.value.initialized).toBe(true);
    });
  });

  describe('createRewardsHistoryTracker', () => {
    it('queries and maps reward history starting from first delgation epoch+3', () => {
      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const accountRewardsHistory = rewardsHistory.get(rewardAccount)!;
        const epoch = accountRewardsHistory[0].epoch;
        const getRewardsHistory = jest.fn().mockReturnValue(cold('-a', { a: rewardsHistory }));
        const target$ = createRewardsHistoryTracker(
          cold('aa', {
            a: [
              {
                epoch: 0,
                tx: createStubTxWithCertificates([Cardano.CertificateType.StakeKeyDeregistration])
              },
              {
                epoch,
                tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation])
              }
            ]
          }),
          of(rewardAccounts),
          getRewardsHistory,
          new InMemoryRewardsHistoryStore()
        );
        expectObservable(target$).toBe('-a', {
          a: {
            all: accountRewardsHistory,
            avgReward: 10_500n,
            lastReward: accountRewardsHistory[1],
            lifetimeRewards: 21_000n
          } as RewardsHistory
        });
        flush();
        expect(getRewardsHistory).toBeCalledTimes(1);
        expect(getRewardsHistory).toBeCalledWith(rewardAccounts, epoch + 3);
      });
    });

    it.todo('emits value from store if it exists and updates store after provider response');
  });
});
