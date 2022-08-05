import { BehaviorSubject } from 'rxjs';
import {
  CLEAN_FN_STATS,
  ProviderFnStats,
  TrackedWalletNetworkInfoProvider,
  WalletNetworkInfoProvider,
  WalletNetworkInfoProviderStats
} from '../../../src';
import { mockNetworkInfoProvider } from '../../mocks';

describe('TrackedNetworkInfoProvider', () => {
  let networkInfoProvider: WalletNetworkInfoProvider;
  let trackedNetworkInfoProvider: TrackedWalletNetworkInfoProvider;
  beforeEach(() => {
    networkInfoProvider = mockNetworkInfoProvider();
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
      'timeSettings',
      testFunctionStats(
        (provider) => provider.timeSettings(),
        (stats) => stats.timeSettings$
      )
    );

    test(
      'currentWalletProtocolParameters',
      testFunctionStats(
        (wp) => wp.currentWalletProtocolParameters(),
        (stats) => stats.currentWalletProtocolParameters$
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
