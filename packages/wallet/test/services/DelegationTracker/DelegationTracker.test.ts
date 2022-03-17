import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TransactionsTracker } from '../../../src/services';
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
      const hashes = [
        '0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed',
        'a0805ae8e52318f0e499be7f85d3f1d5c7dddeacdca0dab9e9d9a8ae6c49a22c'
      ].map(Cardano.BlockId);
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
          createStubTxWithCertificates([Cardano.CertificateType.StakeKeyRegistration]),
          createStubTxWithCertificates([
            Cardano.CertificateType.PoolRetirement,
            Cardano.CertificateType.StakeDelegation
          ]),
          createStubTxWithCertificates(),
          createStubTxWithCertificates([Cardano.CertificateType.StakeKeyDeregistration])
        ];
        const slotEpochCalc = jest.fn().mockReturnValueOnce(284).mockReturnValueOnce(285);
        const slotEpochCalc$ = cold('-a', { a: slotEpochCalc });
        const target$ = certificateTransactionsWithEpochs(
          {
            history: {
              outgoing$: cold('a--a', {
                a: transactions
              })
            }
          } as unknown as TransactionsTracker,
          slotEpochCalc$,
          [Cardano.CertificateType.StakeDelegation, Cardano.CertificateType.StakeKeyDeregistration]
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
