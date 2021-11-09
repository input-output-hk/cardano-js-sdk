import { Cardano } from '@cardano-sdk/core';
import { RewardsHistory, createRewardsHistoryTracker } from '../../../src/services';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';
import { rewardsHistory } from '../../mocks';

// TODO: use this to test retryBackoff
// const stubObservableProvider = <T>(...calls: Observable<T>[]) => {
//   let numCall = 0;
//   return new Observable<T>((subscriber) => {
//     const sub = calls[numCall++].subscribe(subscriber);
//     return () => sub.unsubscribe();
//   });
// };

describe('RewardsHistory', () => {
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
