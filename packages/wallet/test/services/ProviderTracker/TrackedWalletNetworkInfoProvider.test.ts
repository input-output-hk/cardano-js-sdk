import { CLEAN_FN_STATS, TrackedWalletNetworkInfoProvider } from '../../../src/index.js';
import { mockProviders } from '@cardano-sdk/util-dev';
import type { BehaviorSubject } from 'rxjs';
import type { ProviderFnStats, WalletNetworkInfoProvider, WalletNetworkInfoProviderStats } from '../../../src/index.js';

describe('TrackedNetworkInfoProvider', () => {
  let networkInfoProvider: WalletNetworkInfoProvider;
  let trackedNetworkInfoProvider: TrackedWalletNetworkInfoProvider;
  beforeEach(() => {
    networkInfoProvider = mockProviders.mockNetworkInfoProvider();
    trackedNetworkInfoProvider = new TrackedWalletNetworkInfoProvider(networkInfoProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (networkInfoProvider: WalletNetworkInfoProvider) => Promise<T>,
        selectStats: (stats: WalletNetworkInfoProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedNetworkInfoProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedNetworkInfoProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedNetworkInfoProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedNetworkInfoProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'eraSummaries',
      testFunctionStats(
        (provider) => provider.eraSummaries(),
        (stats) => stats.eraSummaries$
      )
    );

    test(
      'protocolParameters',
      testFunctionStats(
        (wp) => wp.protocolParameters(),
        (stats) => stats.protocolParameters$
      )
    );

    test(
      'genesisParameters',
      testFunctionStats(
        (wp) => wp.genesisParameters(),
        (stats) => stats.genesisParameters$
      )
    );

    test(
      'ledgerTip',
      testFunctionStats(
        (wp) => wp.ledgerTip(),
        (stats) => stats.ledgerTip$
      )
    );
  });
});
