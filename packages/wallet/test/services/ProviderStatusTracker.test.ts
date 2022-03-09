/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
import { CLEAN_FN_STATS, ProviderFnStats, SyncStatus, TrackedWalletProvider } from '../../src';
import { createProviderStatusTracker } from '../../src/services/ProviderStatusTracker';
import { createTestScheduler } from '../testScheduler';
import { mockWalletProvider } from '../mocks';

describe('syncStatus', () => {
  it('is "Syncing" until all requests resolve, then "UpToDate" until timeout', async () => {
    const walletProvider = new TrackedWalletProvider(mockWalletProvider());
    const timeout = 5000;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const getProviderSyncRelevantStats = jest.fn().mockReturnValueOnce(
        cold<ProviderFnStats[]>(`abcdef ${timeout}ms g`, {
          a: [CLEAN_FN_STATS, CLEAN_FN_STATS],                    // Initial state
          b: [{ numCalls: 1, numResponses: 0 }, CLEAN_FN_STATS],  // One provider fn called
          c: [
            { numCalls: 1, numResponses: 0 },                     // Both provider fns called
            { numCalls: 1, numResponses: 0 }
          ],
          d: [                                                    // One provider fn resolved
            { numCalls: 1, numResponses: 1 },
            { numCalls: 1, numResponses: 0 }
          ],
          e: [
            { numCalls: 1, numResponses: 1 },                     // Both provider fns resolved
            { numCalls: 1, numResponses: 1 }
          ],
          f: [                                                    // Both provider fns called again
            { numCalls: 2, numResponses: 1 },
            { numCalls: 2, numResponses: 1 }
          ],
          g: [                                                    // Both provider fns resolved
            { numCalls: 2, numResponses: 2 },
            { numCalls: 2, numResponses: 2 }
          ]
        })
      );
      const tracker = createProviderStatusTracker(
        { walletProvider },
        { consideredOutOfSyncAfter: timeout },
        { getProviderSyncRelevantStats }
      );
      expectObservable(tracker, `^ ${timeout * 2}ms !`).toBe(`a---e ${timeout - 1}ms f-g`, {
        a: SyncStatus.Syncing,
        e: SyncStatus.UpToDate,
        f: SyncStatus.Syncing,
        g: SyncStatus.UpToDate
      });
    });
  });
});
