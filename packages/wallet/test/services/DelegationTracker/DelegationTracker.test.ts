import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TransactionsTracker } from '../../../src/services';
import { certificateTransactionsWithEpochs, createBlockEpochProvider } from '../../../src/services/DelegationTracker';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '@cardano-sdk/util-dev';

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
      const chainHistoryProvider = null as unknown as ChainHistoryProvider; // not used in this test
      const config = null as unknown as RetryBackoffConfig; // not used in this test
      const hashes = [
        '0dbe461fb5f981c0d01615332b8666340eb1a692b3034f46bcb5f5ea4172b2ed',
        'a0805ae8e52318f0e499be7f85d3f1d5c7dddeacdca0dab9e9d9a8ae6c49a22c'
      ].map(Cardano.BlockId);
      expectObservable(createBlockEpochProvider(chainHistoryProvider, config)(hashes)).toBe('a-b', {
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
        const rewardAccount = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');
        const transactions = [
          createStubTxWithCertificates([
            {
              __typename: Cardano.CertificateType.StakeKeyRegistration,
              stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
            }
          ]),
          createStubTxWithCertificates([
            {
              __typename: Cardano.CertificateType.PoolRetirement
            } as Cardano.Certificate,
            {
              __typename: Cardano.CertificateType.StakeDelegation,
              stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
            } as Cardano.Certificate
          ]),
          createStubTxWithCertificates(),
          createStubTxWithCertificates([
            {
              __typename: Cardano.CertificateType.StakeKeyDeregistration,
              stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
            }
          ])
        ];

        const slotEpochCalc = jest.fn().mockReturnValueOnce(284).mockReturnValueOnce(285);
        const slotEpochCalc$ = cold('-a', { a: slotEpochCalc });

        const rewardAccounts$ = cold('a', {
          a: [rewardAccount]
        });
        const target$ = certificateTransactionsWithEpochs(
          {
            history$: cold('a--a', {
              a: transactions
            })
          } as unknown as TransactionsTracker,
          rewardAccounts$,
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
    it('does not emit outgoing transactions with certificates not signed by the reward accounts', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const rewardAccount = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');
        const transactions = [
          createStubTxWithCertificates([
            { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.Certificate
          ]),
          createStubTxWithCertificates([
            { __typename: Cardano.CertificateType.PoolRetirement } as Cardano.Certificate,
            { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate
          ]),
          createStubTxWithCertificates(),
          createStubTxWithCertificates([
            { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.Certificate
          ])
        ];
        const slotEpochCalc = jest.fn().mockReturnValueOnce(284).mockReturnValueOnce(285);
        const slotEpochCalc$ = cold('-a', { a: slotEpochCalc });

        const rewardAccounts$ = cold('a', {
          a: [rewardAccount]
        });
        const target$ = certificateTransactionsWithEpochs(
          {
            history$: cold('a--a', {
              a: transactions
            })
          } as unknown as TransactionsTracker,
          rewardAccounts$,
          slotEpochCalc$,
          [Cardano.CertificateType.StakeDelegation, Cardano.CertificateType.StakeKeyDeregistration]
        );
        expectObservable(target$).toBe('-a', {
          a: []
        });
      });
    });
  });
});
