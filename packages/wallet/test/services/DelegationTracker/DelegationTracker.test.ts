import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Transactions } from '../../../src/services';
import { certificateTransactionsWithEpochs, createBlockEpochProvider } from '../../../src/services/DelegationTracker';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';

jest.mock('../../../src/services/util/coldObservableProvider', () => ({ coldObservableProvider: jest.fn() }));
const coldObservableProviderMock: jest.Mock = jest.requireMock(
  '../../../src/services/util/coldObservableProvider'
).coldObservableProvider;

describe('DelegationTracker', () => {
  test('createBlockEpochProvider', () => {
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      coldObservableProviderMock.mockReturnValue(
        cold('a-b', {
          a: [{ epoch: 100 }],
          b: [{ epoch: 100 }, { epoch: 101 }]
        })
      );
      const walletProvider = null as unknown as WalletProvider; // not used in this test
      const config = null as unknown as RetryBackoffConfig; // not used in this test
      const hashes = ['hash1', 'hash2'];
      expectObservable(createBlockEpochProvider(walletProvider, config)(hashes)).toBe('a-b', {
        a: [100],
        b: [100, 101]
      });
      flush();
      expect(coldObservableProviderMock).toBeCalledTimes(1);
    });
  });

  describe('certificateTransactionsWithEpochs', () => {
    it('emits outgoing transactions containing given certificate types, retries on error', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const transactions = [
          createStubTxWithCertificates([Cardano.CertificateType.StakeRegistration]),
          createStubTxWithCertificates([
            Cardano.CertificateType.PoolRetirement,
            Cardano.CertificateType.StakeDelegation
          ]),
          createStubTxWithCertificates(),
          createStubTxWithCertificates([Cardano.CertificateType.StakeDeregistration])
        ];
        const blockEpochProvider = jest.fn().mockReturnValue(cold('-a', { a: [284, 285] }));
        const target$ = certificateTransactionsWithEpochs(
          {
            history: {
              outgoing$: cold('a--a', {
                a: transactions
              })
            }
          } as unknown as Transactions,
          blockEpochProvider,
          [Cardano.CertificateType.StakeDelegation, Cardano.CertificateType.StakeDeregistration]
        );
        expectObservable(target$).toBe('-a', {
          a: [
            { epoch: 284, tx: transactions[1] },
            { epoch: 285, tx: transactions[3] }
          ]
        });
      });
    });
  });
});
