import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, TrackedWalletProvider, WalletProviderStats } from '../../src';
import { WalletProvider } from '@cardano-sdk/core';
import { mockWalletProvider } from '../mocks';

describe('TrackedWalletProvider', () => {
  let walletProvider: WalletProvider;
  let trackedWalletProvider: TrackedWalletProvider;
  beforeEach(() => {
    walletProvider = mockWalletProvider();
    trackedWalletProvider = new TrackedWalletProvider(walletProvider);
  });

  test('CLEAN_FN_STATS numResponses is 0', () => {
    expect(CLEAN_FN_STATS).toEqual({ numCalls: 0, numResponses: 0 });
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (walletProvider: WalletProvider) => Promise<T>,
        selectStats: (stats: WalletProviderStats) => BehaviorSubject<ProviderFnStats>
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        expect(selectStats(trackedWalletProvider.stats).value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedWalletProvider);
        expect(selectStats(trackedWalletProvider.stats).value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        expect(selectStats(trackedWalletProvider.stats).value).toEqual({ numCalls: 1, numResponses: 1 });
        trackedWalletProvider.stats.reset();
        expect(selectStats(trackedWalletProvider.stats).value).toEqual(CLEAN_FN_STATS);
      };

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

    test(
      'networkInfo',
      testFunctionStats(
        (wp) => wp.networkInfo(),
        (stats) => stats.networkInfo$
      )
    );

    test(
      'queryBlocksByHashes',
      testFunctionStats(
        (wp) => wp.queryBlocksByHashes([]),
        (stats) => stats.queryBlocksByHashes$
      )
    );

    test(
      'queryTransactionsByAddresses',
      testFunctionStats(
        (wp) => wp.queryTransactionsByAddresses([]),
        (stats) => stats.queryTransactionsByAddresses$
      )
    );

    test(
      'queryTransactionsByHashes',
      testFunctionStats(
        (wp) => wp.queryTransactionsByHashes([]),
        (stats) => stats.queryTransactionsByHashes$
      )
    );

    test(
      'rewardsHistory',
      testFunctionStats(
        (wp) => wp.rewardsHistory({ stakeAddresses: [] }),
        (stats) => stats.rewardsHistory$
      )
    );

    test(
      'utxoDelegationAndRewards',
      testFunctionStats(
        (wp) => wp.utxoDelegationAndRewards([]),
        (stats) => stats.utxoDelegationAndRewards$
      )
    );

    test(
      'stakePoolStats',
      testFunctionStats(
        (wp) => wp.stakePoolStats!(),
        (stats) => stats.stakePoolStats$
      )
    );
  });
});
