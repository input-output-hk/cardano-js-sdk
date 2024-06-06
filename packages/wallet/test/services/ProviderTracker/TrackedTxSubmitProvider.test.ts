import { CLEAN_TX_SUBMIT_STATS, TrackedTxSubmitProvider } from '../../../src/index.js';
import { TxCBOR } from '@cardano-sdk/core';
import { bufferToHexString } from '@cardano-sdk/util';
import { mockProviders } from '@cardano-sdk/util-dev';
import type { BehaviorSubject } from 'rxjs';
import type { ProviderFnStats, TxSubmitProviderStats } from '../../../src/index.js';
import type { TxSubmitProvider } from '@cardano-sdk/core';

describe('TrackedTxSubmitProvider', () => {
  let txSubmitProvider: TxSubmitProvider;
  let trackedTxSubmitProvider: TrackedTxSubmitProvider;
  beforeEach(() => {
    txSubmitProvider = mockProviders.mockTxSubmitProvider();
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
        const stats$ = selectStats(trackedTxSubmitProvider.stats);
        expect(stats$.value).toEqual(CLEAN_TX_SUBMIT_STATS);
        const result = call(trackedTxSubmitProvider);
        expect(stats$.value).toEqual({ ...CLEAN_TX_SUBMIT_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedTxSubmitProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_TX_SUBMIT_STATS);
        trackedTxSubmitProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual(CLEAN_TX_SUBMIT_STATS);
      };

    test(
      'healthCheck',
      testFunctionStats(
        (provider) => provider.healthCheck(),
        (stats) => stats.healthCheck$
      )
    );

    test(
      'submitTx',
      testFunctionStats(
        (provider) =>
          provider.submitTx({ signedTransaction: TxCBOR(bufferToHexString(Buffer.from(new Uint8Array()))) }),
        (stats) => stats.submitTx$
      )
    );
  });
});
