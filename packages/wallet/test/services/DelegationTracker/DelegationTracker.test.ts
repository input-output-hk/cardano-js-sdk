import { Cardano, ChainHistoryProvider, metadatum } from '@cardano-sdk/core';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TransactionsTracker, createDelegationPortfolioTracker } from '../../../src/services';
import { certificateTransactionsWithEpochs, createBlockEpochProvider } from '../../../src/services/DelegationTracker';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { createStubTxWithCertificates, createStubTxWithEpoch } from './stub-tx';
import { createTestScheduler } from '@cardano-sdk/util-dev';

jest.mock('@cardano-sdk/util-rxjs', () => {
  const originalModule = jest.requireActual('@cardano-sdk/util-rxjs');
  return { ...originalModule, coldObservableProvider: jest.fn() };
});

describe('DelegationTracker', () => {
  const coldObservableProviderMock = coldObservableProvider as jest.MockedFunction<typeof coldObservableProvider>;

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

  describe('delegationPortfolio', () => {
    const cip17DelegationPortfolio: Cardano.Cip17DelegationPortfolio = {
      author: 'me',
      name: 'My portfolio',
      pools: [
        {
          id: '10000000000000000000000000000000000000000000000000000000' as Cardano.PoolIdHex,
          weight: 1
        },
        {
          id: '20000000000000000000000000000000000000000000000000000000' as Cardano.PoolIdHex,
          weight: 1
        }
      ]
    };

    const cip17DelegationPortfolio2: Cardano.Cip17DelegationPortfolio = {
      author: 'me',
      name: 'My portfolio 2',
      pools: [
        {
          id: '11000000000000000000000000000000000000000000000000000011' as Cardano.PoolIdHex,
          weight: 1
        }
      ]
    };

    it('always returns the latest portfolio', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const rewardAccount = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');

        const transactions$ = cold('a-b-c-d', {
          a: [
            createStubTxWithEpoch(284, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ])
          ],
          b: [
            createStubTxWithEpoch(284, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ]),
            createStubTxWithEpoch(
              285,
              [
                {
                  __typename: Cardano.CertificateType.StakeKeyRegistration,
                  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
                }
              ],
              {
                blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio)]])
              }
            )
          ],
          c: [
            createStubTxWithEpoch(284, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ]),
            createStubTxWithEpoch(
              285,
              [
                {
                  __typename: Cardano.CertificateType.StakeKeyRegistration,
                  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
                }
              ],
              {
                blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio)]])
              }
            ),
            createStubTxWithEpoch(286, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ])
          ],
          d: [
            createStubTxWithEpoch(284, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ]),
            createStubTxWithEpoch(
              285,
              [
                {
                  __typename: Cardano.CertificateType.StakeKeyRegistration,
                  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
                }
              ],
              {
                blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio)]])
              }
            ),
            createStubTxWithEpoch(286, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ]),
            createStubTxWithEpoch(
              287,
              [
                {
                  __typename: Cardano.CertificateType.StakeKeyRegistration,
                  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
                }
              ],
              {
                blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio2)]])
              }
            )
          ]
        });

        const portfolio$ = createDelegationPortfolioTracker(transactions$);

        expectObservable(portfolio$).toBe('a-b-c-d', {
          a: null,
          b: cip17DelegationPortfolio,
          c: null,
          d: cip17DelegationPortfolio2
        });
      });
    });

    it('returns null if the most recent transaction does not have the metadata', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const rewardAccount = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');

        const transactions$ = cold('a-b', {
          a: [
            createStubTxWithEpoch(
              284,
              [
                {
                  __typename: Cardano.CertificateType.StakeKeyRegistration,
                  stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
                }
              ],
              {
                blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio)]])
              }
            )
          ],
          b: [
            createStubTxWithEpoch(286, [
              {
                __typename: Cardano.CertificateType.StakeKeyRegistration,
                stakeKeyHash: Cardano.RewardAccount.toHash(rewardAccount)
              }
            ])
          ]
        });

        const portfolio$ = createDelegationPortfolioTracker(transactions$);

        expectObservable(portfolio$).toBe('a-b', {
          a: cip17DelegationPortfolio,
          b: null
        });
      });
    });
  });
});
