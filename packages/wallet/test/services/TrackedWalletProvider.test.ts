import { BehaviorSubject } from 'rxjs';
import { CLEAN_FN_STATS, ProviderFnStats, TrackedWalletProvider, WalletProviderStats } from '../../src';
import { WalletProvider } from '@cardano-sdk/core';
import { WalletProviderStub, mockWalletProvider } from '../mocks';

describe('TrackedWalletProvider', () => {
  let walletProvider: WalletProviderStub;
  let trackedWalletProvider: TrackedWalletProvider;
  beforeEach(() => {
    walletProvider = mockWalletProvider();
    trackedWalletProvider = new TrackedWalletProvider(walletProvider);
  });

  test('CLEAN_FN_STATS all stats are 0', () => {
    expect(CLEAN_FN_STATS).toEqual({ numCalls: 0, numFailures: 0, numResponses: 0 });
  });

  describe('wraps underlying provider functions, tracks # of calls/responses and resets on stats.reset()', () => {
    const testFunctionStats =
      <T>(
        call: (walletProvider: WalletProvider) => Promise<T>,
        selectStats: (stats: WalletProviderStats) => BehaviorSubject<ProviderFnStats>,
        selectFn: (mockWalletProvider: WalletProviderStub) => jest.Mock
        // eslint-disable-next-line unicorn/consistent-function-scoping
      ) =>
      async () => {
        expect(selectStats(trackedWalletProvider.stats).value).toEqual(CLEAN_FN_STATS);
        const result = call(trackedWalletProvider);
        expect(selectStats(trackedWalletProvider.stats).value).toEqual({ ...CLEAN_FN_STATS, numCalls: 1 });
        await result;
        const statsAfterResponse = {
          didLastRequestFail: false,
          numCalls: 1,
          numFailures: 0,
          numResponses: 1
        };
        expect(selectStats(trackedWalletProvider.stats).value).toEqual(statsAfterResponse);
        selectFn(walletProvider).mockRejectedValueOnce(new Error('any error'));
        const failure = call(trackedWalletProvider).catch(() => void 0);
        const statsAfterFailureCall = {
          ...statsAfterResponse,
          numCalls: statsAfterResponse.numCalls + 1
        };
        expect(selectStats(trackedWalletProvider.stats).value).toEqual(statsAfterFailureCall);
        await failure;
        expect(selectStats(trackedWalletProvider.stats).value).toEqual({
          ...statsAfterFailureCall,
          didLastRequestFail: true,
          numFailures: 1
        });
        trackedWalletProvider.stats.reset();
        expect(selectStats(trackedWalletProvider.stats).value).toEqual(CLEAN_FN_STATS);
      };

    test(
      'currentWalletProtocolParameters',
      testFunctionStats(
        (wp) => wp.currentWalletProtocolParameters(),
        (stats) => stats.currentWalletProtocolParameters$,
        (mockWP) => mockWP.currentWalletProtocolParameters
      )
    );

    test(
      'genesisParameters',
      testFunctionStats(
        (wp) => wp.genesisParameters(),
        (stats) => stats.genesisParameters$,
        (mockWP) => mockWP.genesisParameters
      )
    );

    test(
      'ledgerTip',
      testFunctionStats(
        (wp) => wp.ledgerTip(),
        (stats) => stats.ledgerTip$,
        (mockWP) => mockWP.ledgerTip
      )
    );

    test(
      'networkInfo',
      testFunctionStats(
        (wp) => wp.networkInfo(),
        (stats) => stats.networkInfo$,
        (mockWP) => mockWP.networkInfo
      )
    );

    test(
      'queryBlocksByHashes',
      testFunctionStats(
        (wp) => wp.queryBlocksByHashes([]),
        (stats) => stats.queryBlocksByHashes$,
        (mockWP) => mockWP.queryBlocksByHashes
      )
    );

    test(
      'queryTransactionsByAddresses',
      testFunctionStats(
        (wp) => wp.queryTransactionsByAddresses([]),
        (stats) => stats.queryTransactionsByAddresses$,
        (mockWP) => mockWP.queryTransactionsByAddresses
      )
    );

    test(
      'queryTransactionsByHashes',
      testFunctionStats(
        (wp) => wp.queryTransactionsByHashes([]),
        (stats) => stats.queryTransactionsByHashes$,
        (mockWP) => mockWP.queryTransactionsByHashes
      )
    );

    test(
      'rewardsHistory',
      testFunctionStats(
        (wp) => wp.rewardsHistory({ rewardAccounts: [] }),
        (stats) => stats.rewardsHistory$,
        (mockWP) => mockWP.rewardsHistory
      )
    );

    test(
      'utxoDelegationAndRewards',
      testFunctionStats(
        (wp) => wp.utxoDelegationAndRewards([]),
        (stats) => stats.utxoDelegationAndRewards$,
        (mockWP) => mockWP.utxoDelegationAndRewards
      )
    );

    test(
      'stakePoolStats',
      testFunctionStats(
        (wp) => wp.stakePoolStats!(),
        (stats) => stats.stakePoolStats$,
        (mockWP) => mockWP.stakePoolStats
      )
    );
  });
});
