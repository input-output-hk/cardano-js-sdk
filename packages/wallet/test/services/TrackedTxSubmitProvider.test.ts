import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, TrackedTxSubmitProvider, TxSubmitProviderStats } from '../../src';
import { TxSubmitProvider } from '@cardano-sdk/core';
import { mockTxSubmitProvider } from '../mocks';

describe('TrackedTxSubmitProvider', () => {
  let txSubmitProvider: TxSubmitProvider;
  let trackedTxSubmitProvider: TrackedTxSubmitProvider;
  beforeEach(() => {
    txSubmitProvider = mockTxSubmitProvider();
    trackedTxSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (txSubmitProvider: TxSubmitProvider) => Promise<T>,
        selectStats: (stats: TxSubmitProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        expect(selectStats(trackedTxSubmitProvider.stats).value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedTxSubmitProvider);
        expect(selectStats(trackedTxSubmitProvider.stats).value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(selectStats(trackedTxSubmitProvider.stats).value).toEqual({ numCalls: 1, numResponses: 1 });
        trackedTxSubmitProvider.stats.reset();
        expect(selectStats(trackedTxSubmitProvider.stats).value).toEqual(CLEAN_FN_STATS);
      };

    test(
      'submitTx',
      testFunctionStats(
        (provider) => provider.submitTx(new Uint8Array()),
        (stats) => stats.submitTx$
      )
    );
  });
});
