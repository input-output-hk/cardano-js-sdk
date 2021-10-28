import { Cardano } from '@cardano-sdk/core';
import { NewTx } from '../../src/prototype';
import { ProviderTrackerSubject, createRewardsProvider$, createRewardsTracker } from '../../src/services';
import { createTestScheduler } from '../testScheduler';
import { providerStub, testKeyManager } from '../mocks';

jest.mock('@cardano-sdk/core', () => ({
  ...jest.requireActual('@cardano-sdk/core'),
  cslUtil: {
    bytewiseEquals: jest.fn().mockReturnValue(true)
  }
}));

describe('createRewardsTracker', () => {
  it('fetches rewards from WalletProvider and locks when spent in a transaction in flight', () => {
    const keyManager = testKeyManager();
    const address = keyManager.deriveAddress(0, 0);
    const provider = providerStub();
    createTestScheduler().run(({ cold, expectObservable }) => {
      const transactionsInFlight$ = cold('-a-b-', {
        a: [],
        b: [
          {
            body: () => ({
              withdrawals: () => ({
                get: () => ({ to_str: () => '100' }),
                keys: () => ({ get: () => ({ payment_cred: () => 'stake credential obj' }), len: () => 1 })
              })
            })
          } as unknown as NewTx
        ]
      });
      const rewardsTracker = createRewardsTracker(
        {
          config: { maxInterval: 100, pollInterval: 100 }, // not relevant for this test, overwriting rewardsSource$
          keyManager,
          rewardsProvider: createRewardsProvider$(provider, [address], keyManager),
          transactionsInFlight$
        },
        { rewardsSource$: cold('a---|', { a: 10_000n }) as unknown as ProviderTrackerSubject<Cardano.Lovelace> }
      );
      expectObservable(rewardsTracker.total$).toBe('a---|', { a: 10_000n });
      expectObservable(rewardsTracker.available$).toBe('-a-b-', { a: 10_000n, b: 10_000n - 100n });
    });
  });
});
