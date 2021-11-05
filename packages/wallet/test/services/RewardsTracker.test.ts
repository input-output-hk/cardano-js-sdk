import { Cardano } from '@cardano-sdk/core';
import { ProviderTrackerSubject, createRewardsProvider, createRewardsTracker } from '../../src/services';
import { createTestScheduler } from '../testScheduler';
import { providerStub, testKeyManager } from '../mocks';

describe('createRewardsTracker', () => {
  it('fetches rewards from WalletProvider and locks when spent in a transaction in flight', () => {
    const keyManager = testKeyManager();
    const stakeAddress = keyManager.stakeKey.to_bech32();
    const provider = providerStub();
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
          // not relevant for this test, overwriting rewardsSource$
          config: { maxInterval: 100, pollInterval: 100 },
          rewardsProvider: createRewardsProvider(provider, keyManager),
          transactionsInFlight$
        },
        { rewardsSource$: cold('a---|', { a: 10_000n }) as unknown as ProviderTrackerSubject<Cardano.Lovelace> }
      );
      expectObservable(rewardsTracker.total$).toBe('a---|', { a: 10_000n });
      expectObservable(rewardsTracker.available$).toBe('-a-b-', { a: 10_000n, b: 10_000n - 100n });
    });
  });
});
