import { Cardano } from '@cardano-sdk/core';
import { RewardsHistory, createRewardsHistoryProvider, getEpoch } from '../../../src/services';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';
import { of } from 'rxjs';
import { providerStub, rewardsHistory, testKeyManager } from '../../mocks';

describe('RewardsHistory', () => {
  describe('getEpoch', () => {
    it('computes byron epoch correctly', () => {
      expect(getEpoch(4_492_799)).toBe(207); // last byron slot
      expect(getEpoch(86_400)).toBe(4);
      expect(getEpoch(107_999)).toBe(4);
    });
    it('computes shelley epoch correctly', () => {
      expect(getEpoch(4_492_800)).toBe(208); // first shelley slot
      expect(getEpoch(44_237_054)).toBe(300);
      expect(getEpoch(44_668_784)).toBe(300);
    });
  });

  describe('createRewardsHistoryProvider', () => {
    it('queries reward history using WalletProvider', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const target$ = createRewardsHistoryProvider(
          providerStub(), // not used, override with last arg
          testKeyManager(),
          {
            history: {
              outgoing$: cold('a', {
                a: [
                  createStubTxWithCertificates([Cardano.CertificateType.StakeDeregistration]),
                  createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation])
                ]
              })
            }
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
          } as any,
          {
            getRewardsHistory: () => of(rewardsHistory)
          }
        )();
        expectObservable(target$).toBe('(a|)', {
          a: {
            all: rewardsHistory,
            avgReward: 10_500n,
            lastReward: rewardsHistory[1],
            lifetimeRewards: 21_000n
          } as RewardsHistory
        });
      });
    });
  });
});
