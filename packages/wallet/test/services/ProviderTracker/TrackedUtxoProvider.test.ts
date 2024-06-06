import { CLEAN_FN_STATS, TrackedUtxoProvider } from '../../../src/index.js';
import { Cardano } from '@cardano-sdk/core';
import { createStubUtxoProvider } from '@cardano-sdk/util-dev';
import type { BehaviorSubject } from 'rxjs';
import type { ProviderFnStats, UtxoProviderStats } from '../../../src/index.js';
import type { UtxoProvider } from '@cardano-sdk/core';

describe('TrackedStakePoolProvider', () => {
  let utxoProvider: UtxoProvider;
  let trackedUtxoProvider: TrackedUtxoProvider;
  beforeEach(() => {
    utxoProvider = createStubUtxoProvider();
    trackedUtxoProvider = new TrackedUtxoProvider(utxoProvider);
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (utxoProvider: UtxoProvider) => Promise<T>,
        selectStats: (stats: UtxoProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        const stats$ = selectStats(trackedUtxoProvider.stats);
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedUtxoProvider);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(stats$.value).toEqual({
          didLastRequestFail: false,
          initialized: true,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        });
        trackedUtxoProvider.stats.reset();
        expect(stats$.value).toEqual(CLEAN_FN_STATS);
        trackedUtxoProvider.setStatInitialized(stats$);
        expect(stats$.value).toEqual({ ...CLEAN_FN_STATS, initialized: true });
      };

    test(
      'healthCheck',
      testFunctionStats(
        (provider) => provider.healthCheck(),
        (stats) => stats.healthCheck$
      )
    );

    test(
      'utxoByAddresses',
      testFunctionStats(
        (provider) =>
          provider.utxoByAddresses({
            addresses: [
              Cardano.PaymentAddress(
                // eslint-disable-next-line max-len
                'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
              )
            ]
          }),
        (stats) => stats.utxoByAddresses$
      )
    );
  });
});
