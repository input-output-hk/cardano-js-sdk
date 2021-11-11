import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { Observable } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { SyncableIntervalTrackerSubject, createRewardsTracker } from '../../src/services';
import { createTestScheduler } from '../testScheduler';
import { testKeyManager } from '../mocks';

describe('createRewardsTracker', () => {
  // these variables are not relevant for this test, overwriting rewardsSource$
  let walletProvider: WalletProvider;
  let retryBackoffConfig: RetryBackoffConfig;
  let epoch$: Observable<Cardano.Epoch>;

  it('fetches rewards from WalletProvider and locks when spent in a transaction in flight', () => {
    const keyManager = testKeyManager();
    const stakeAddress = keyManager.rewardAccount;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a-b-', {
        a: [],
        b: [
          {
            body: {
              withdrawals: [
                {
                  quantity: 100n,
                  stakeAddress
                }
              ]
            }
          } as Cardano.NewTxAlonzo
        ]
      });
      const rewardsTracker = createRewardsTracker(
        {
          epoch$,
          keyManager,
          retryBackoffConfig,
          transactionsInFlight$,
          walletProvider
        },
        { rewardsSource$: cold('a--a|', { a: 10_000n }) as unknown as SyncableIntervalTrackerSubject<Cardano.Lovelace> }
      );
      expectObservable(rewardsTracker.total$).toBe('a--a|', { a: 10_000n });
      expectObservable(rewardsTracker.available$).toBe('-a-b-', { a: 10_000n, b: 10_000n - 100n });
    });
  });
});
