import { Cardano } from '@cardano-sdk/core';
import { RewardsHistory, createRewardsHistoryProvider, createRewardsHistoryTracker } from '../../../src/services';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';
import { firstValueFrom } from 'rxjs';
import { mockWalletProvider, rewardsHistory, testKeyManager } from '../../mocks';

describe('RewardsHistory', () => {
  test('createRewardsHistoryProvider', async () => {
    const provider = createRewardsHistoryProvider(mockWalletProvider(), testKeyManager(), { initialInterval: 1 });
    expect(await firstValueFrom(provider(1))).toBe(rewardsHistory);
  });

  describe('createRewardsHistoryTracker', () => {
    it('queries and maps reward history starting from first delgation epoch+2', () => {
      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const epoch = rewardsHistory[0].epoch;
        const getRewardsHistory = jest.fn().mockReturnValue(cold('-a', { a: rewardsHistory }));
        const target$ = createRewardsHistoryTracker(
          cold('aa', {
            a: [
              {
                epoch: 0,
                tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDeregistration])
              },
              {
                epoch,
                tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation])
              }
            ]
          }),
          getRewardsHistory
        );
        expectObservable(target$).toBe('-a', {
          a: {
            all: rewardsHistory,
            avgReward: 10_500n,
            lastReward: rewardsHistory[1],
            lifetimeRewards: 21_000n
          } as RewardsHistory
        });
        flush();
        expect(getRewardsHistory).toBeCalledTimes(1);
        expect(getRewardsHistory).toBeCalledWith(epoch + 2);
      });
    });
  });
});
