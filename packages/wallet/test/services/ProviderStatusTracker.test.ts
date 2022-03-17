/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
import { CLEAN_FN_STATS, ProviderFnStats, SyncStatus, TrackedWalletProvider } from '../../src';
import { createProviderStatusTracker } from '../../src/services/ProviderStatusTracker';
import { createTestScheduler } from '../testScheduler';
import { mockWalletProvider } from '../mocks';

describe('createProviderStatusTracker', () => {
  it('is "Syncing" until all requests resolve, then "UpToDate" until timeout', async () => {
    const walletProvider = new TrackedWalletProvider(mockWalletProvider());
    const timeout = 5000;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const getProviderSyncRelevantStats = jest.fn().mockReturnValueOnce(
        cold<ProviderFnStats[]>(`abcdef ${timeout}ms ghi`, {
          a: [CLEAN_FN_STATS, CLEAN_FN_STATS],                    // Initial state
          b: [{ numCalls: 1, numFailures: 0, numResponses: 0 }, CLEAN_FN_STATS],  // One provider fn called
          c: [
            { numCalls: 1, numFailures: 0, numResponses: 0 },     // Both provider fns c alled
            { numCalls: 1, numFailures: 0, numResponses: 0 }
          ],
          d: [                                                    // One provider fn res olved
            { numCalls: 1, numFailures: 0, numResponses: 1 },
            { numCalls: 1, numFailures: 0, numResponses: 0 }
          ],
          e: [
            { numCalls: 1, numFailures: 0, numResponses: 1 },     // Both provider fns r esolved
            { numCalls: 1, numFailures: 0, numResponses: 1 }
          ],
          f: [                                                    // Both provider fns c alled again
            { numCalls: 2, numFailures: 0, numResponses: 1 },
            { numCalls: 2, numFailures: 0, numResponses: 1 }
          ],
          g: [                                                    // One provider fn res olved, one failed
            { didLastRequestFail: true, numCalls: 2, numFailures: 1, numResponses: 1 },
            { numCalls: 2, numFailures: 0, numResponses: 2 }
          ],
          h: [                                                    // Failed request fn c alled again
            { didLastRequestFail: true, numCalls: 3, numFailures: 1, numResponses: 1 },
            { numCalls: 2, numFailures: 0, numResponses: 2 }
          ],
          i: [                                                    // Failed request fn r esolved
            { didLastRequestFail: false, numCalls: 3, numFailures: 1, numResponses: 2 },
            { numCalls: 2, numFailures: 0, numResponses: 2 }
          ]
        })
      );
      const tracker = createProviderStatusTracker(
        { walletProvider },
        { consideredOutOfSyncAfter: timeout },
        { getProviderSyncRelevantStats }
      );
      expectObservable(tracker, `^ ${timeout * 2}ms !`).toBe(`a---e ${timeout - 1}ms f---g`, {
        a: SyncStatus.Syncing,
        e: SyncStatus.UpToDate,
        f: SyncStatus.Syncing,
        g: SyncStatus.UpToDate
      });
    });
  });
});
