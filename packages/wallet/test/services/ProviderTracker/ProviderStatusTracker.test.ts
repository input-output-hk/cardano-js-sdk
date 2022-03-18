/* eslint-disable prettier/prettier */
/* eslint-disable no-multi-spaces */
import {
  CLEAN_FN_STATS,
  ProviderFnStats,
  SyncStatus,
  TrackedStakePoolSearchProvider,
  TrackedTimeSettingsProvider,
  TrackedWalletProvider,
  createProviderStatusTracker
} from '../../../src';
import { createStubStakePoolSearchProvider, createStubTimeSettingsProvider } from '@cardano-sdk/util-dev';
import { createTestScheduler } from '../../testScheduler';
import { mockWalletProvider } from '../../mocks';
import { testnetTimeSettings } from '@cardano-sdk/core';

describe('createProviderStatusTracker', () => {
  it('is "Syncing" until all requests resolve, then "UpToDate" until timeout', async () => {
    const walletProvider = new TrackedWalletProvider(mockWalletProvider());
    const stakePoolSearchProvider = new TrackedStakePoolSearchProvider(createStubStakePoolSearchProvider());
    const timeSettingsProvider = new TrackedTimeSettingsProvider(createStubTimeSettingsProvider(testnetTimeSettings));
    const timeout = 5000;
    createTestScheduler().run(({ cold, expectObservable }) => {
      const getProviderSyncRelevantStats = jest.fn().mockReturnValueOnce(
        cold<ProviderFnStats[]>(`abcdef ${timeout}ms ghi`, {
          a: [CLEAN_FN_STATS, CLEAN_FN_STATS], // Initial state
          b: [{ numCalls: 1, numFailures: 0, numResponses: 0 }, CLEAN_FN_STATS], // One provider fn called
          c: [
            // One provider fn resolved
            { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 },
            CLEAN_FN_STATS
          ],
          d: [
            // One provider fn called, one resolved
            { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 },
            { numCalls: 1, numFailures: 0, numResponses: 0 }
          ],
          e: [
            { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 }, // Both provider fns resolved
            { initialized: true, numCalls: 1, numFailures: 0, numResponses: 1 }
          ],
          f: [
            // Both provider fns called again
            { initialized: true, numCalls: 2, numFailures: 0, numResponses: 1 },
            { initialized: true, numCalls: 2, numFailures: 0, numResponses: 1 }
          ],
          g: [
            // One provider fn resolved, one failed
            { didLastRequestFail: true, initialized: true, numCalls: 2, numFailures: 1, numResponses: 1 },
            { initialized: true, numCalls: 2, numFailures: 0, numResponses: 2 }
          ],
          h: [
            // Failed request fn called again
            { didLastRequestFail: true, initialized: true, numCalls: 3, numFailures: 1, numResponses: 1 },
            { initialized: true, numCalls: 2, numFailures: 0, numResponses: 2 }
          ],
          i: [
            // Failed request fn resolved
            { didLastRequestFail: false, initialized: true, numCalls: 3, numFailures: 1, numResponses: 2 },
            { initialized: true, numCalls: 2, numFailures: 0, numResponses: 2 }
          ]
        })
      );
      const tracker = createProviderStatusTracker(
        { stakePoolSearchProvider, timeSettingsProvider, walletProvider },
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
