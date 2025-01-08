import { Cardano, metadatum } from '@cardano-sdk/core';
import { InMemoryDelegationPortfolioStore } from '../../../src/persistence';
import { NEVER, concat, of } from 'rxjs';
import { createDelegationPortfolioTracker } from '../../../src/services';
import { createStubTxWithSlot } from './stub-tx';
import { createTestScheduler } from '@cardano-sdk/util-dev';

jest.mock('../../../src/services/util/pollProvider', () => {
  const originalModule = jest.requireActual('../../../src/services/util/pollProvider');
  return { ...originalModule, pollProvider: jest.fn() };
});

describe('DelegationTracker', () => {
  describe('delegationPortfolio', () => {
    const rewardAccount = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');
    const rewardAccounts$ = of([
      rewardAccount,
      Cardano.RewardAccount('stake_test1uqrw9tjymlm8wrwq7jk68n6v7fs9qz8z0tkdkve26dylmfc2ux2hj')
    ]);

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

    const cip17DelegationPortfolioChangeWeights: Cardano.Cip17DelegationPortfolio = {
      author: 'me',
      name: 'My portfolio with different weights',
      pools: [
        {
          id: '10000000000000000000000000000000000000000000000000000000' as Cardano.PoolIdHex,
          weight: 2
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
      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const transactions$ = cold('a', {
          a: [
            createStubTxWithSlot(284, [
              {
                __typename: Cardano.CertificateType.StakeRegistration,
                stakeCredential: {
                  hash: Cardano.RewardAccount.toHash(rewardAccount),
                  type: Cardano.CredentialType.KeyHash
                }
              }
            ])
          ]
        });

        const newTransaction$ = cold('--b-c-d', {
          b: createStubTxWithSlot(
            285,
            [
              {
                __typename: Cardano.CertificateType.Registration,
                deposit: 2_000_000n,
                stakeCredential: {
                  hash: Cardano.RewardAccount.toHash(rewardAccount),
                  type: Cardano.CredentialType.KeyHash
                }
              }
            ],
            {
              blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio)]])
            }
          ),
          c: createStubTxWithSlot(286, [
            {
              __typename: Cardano.CertificateType.StakeRegistration,
              stakeCredential: {
                hash: Cardano.RewardAccount.toHash(rewardAccount),
                type: Cardano.CredentialType.KeyHash
              }
            }
          ]),
          d: createStubTxWithSlot(
            287,
            [
              {
                __typename: Cardano.CertificateType.VoteRegistrationDelegation,
                dRep: {
                  __typename: 'AlwaysAbstain'
                },
                deposit: 2_000_000n,
                stakeCredential: {
                  hash: Cardano.RewardAccount.toHash(rewardAccount),
                  type: Cardano.CredentialType.KeyHash
                }
              }
            ],
            {
              blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio2)]])
            }
          )
        });

        const provider = jest.fn();

        const portfolio$ = createDelegationPortfolioTracker(
          rewardAccounts$,
          transactions$,
          newTransaction$,
          provider,
          new InMemoryDelegationPortfolioStore()
        );

        expectObservable(portfolio$).toBe('a-b-c-d', {
          a: null,
          b: cip17DelegationPortfolio,
          c: null,
          d: cip17DelegationPortfolio2
        });

        flush();
        expect(provider).not.toBeCalled();
      });
    });

    it('emits null when there is only 1 reward account', () => {
      createTestScheduler().run(({ expectObservable, cold, flush }) => {
        const newTransaction$ = cold<Cardano.OnChainTx>('');

        const storage = new InMemoryDelegationPortfolioStore();
        storage.set = jest.fn().mockImplementation(storage.set);
        const provider = jest.fn();

        const portfolio$ = createDelegationPortfolioTracker(
          of([rewardAccount]),
          of([]),
          newTransaction$,
          provider,
          storage
        );

        expectObservable(portfolio$).toBe('(a|)', {
          a: null
        });

        flush();
        expect(provider).not.toBeCalled();
        expect(storage.set).not.toBeCalled();
      });
    });

    it('emits delegation portfolio from storage and on new transaction with cip17 metadata; stores latest portfolio', () => {
      createTestScheduler().run(({ expectObservable, cold, flush }) => {
        const newTransaction$ = cold('--bc', {
          b: createStubTxWithSlot(284, []),
          c: createStubTxWithSlot(
            285,
            [
              {
                __typename: Cardano.CertificateType.StakeDelegation,
                poolId: 'abcd' as Cardano.PoolId,
                stakeCredential: {
                  hash: Cardano.RewardAccount.toHash(rewardAccount),
                  type: Cardano.CredentialType.KeyHash
                }
              }
            ],
            {
              blob: new Map([
                [Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolioChangeWeights)]
              ])
            }
          )
        });

        const storage = new InMemoryDelegationPortfolioStore();
        storage.set(cip17DelegationPortfolio);
        storage.set = jest.fn().mockImplementation(storage.set);

        const provider = jest.fn();

        const portfolio$ = createDelegationPortfolioTracker(
          rewardAccounts$,
          of([]),
          newTransaction$,
          provider,
          storage
        );

        expectObservable(portfolio$).toBe('a--c', {
          a: cip17DelegationPortfolio,
          c: cip17DelegationPortfolioChangeWeights
        });

        flush();
        expect(provider).not.toBeCalled();
        expect(storage.set).toBeCalledTimes(1);
        expect(storage.set).toBeCalledWith(cip17DelegationPortfolioChangeWeights);
      });
    });

    it('fetches portfolio from provider when not found in recent history', () => {
      createTestScheduler().run(({ expectObservable, cold, flush }) => {
        const newTransaction$ = cold('---c', {
          c: createStubTxWithSlot(
            285,
            [
              {
                __typename: Cardano.CertificateType.StakeDelegation,
                poolId: 'abcd' as Cardano.PoolId,
                stakeCredential: {
                  hash: Cardano.RewardAccount.toHash(rewardAccount),
                  type: Cardano.CredentialType.KeyHash
                }
              }
            ],
            {
              blob: new Map([
                [Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolioChangeWeights)]
              ])
            }
          )
        });

        const storage = new InMemoryDelegationPortfolioStore();
        storage.set = jest.fn().mockImplementation(storage.set);

        const provider = jest.fn().mockReturnValue(concat(of(cip17DelegationPortfolio), NEVER));

        const portfolio$ = createDelegationPortfolioTracker(
          rewardAccounts$,
          of([createStubTxWithSlot(284, [])]), // has history but no relevant tx
          newTransaction$,
          provider,
          storage
        );

        expectObservable(portfolio$).toBe('a--c', {
          a: cip17DelegationPortfolio,
          c: cip17DelegationPortfolioChangeWeights
        });

        flush();
        expect(provider).toBeCalledTimes(1);
        expect(provider).toBeCalledWith(rewardAccount);
        expect(storage.set).toBeCalledTimes(2);
        expect(storage.set).toBeCalledWith(cip17DelegationPortfolio);
        expect(storage.set).toBeCalledWith(cip17DelegationPortfolioChangeWeights);
      });
    });

    it('returns the updated portfolio if the most recent transaction only updates percentages', () => {
      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const transactions$ = cold('a', {
          a: [
            createStubTxWithSlot(
              284,
              [
                {
                  __typename: Cardano.CertificateType.StakeVoteDelegation,
                  dRep: {
                    __typename: 'AlwaysAbstain'
                  },
                  poolId: 'abc' as Cardano.PoolId,

                  stakeCredential: {
                    hash: Cardano.RewardAccount.toHash(rewardAccount),
                    type: Cardano.CredentialType.KeyHash
                  }
                }
              ],
              {
                blob: new Map([[Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolio)]])
              }
            )
          ]
        });

        const newTransaction$ = cold('--b', {
          b: createStubTxWithSlot(289, undefined, {
            blob: new Map([
              [Cardano.DelegationMetadataLabel, metadatum.jsonToMetadatum(cip17DelegationPortfolioChangeWeights)]
            ])
          })
        });

        const provider = jest.fn();

        const portfolio$ = createDelegationPortfolioTracker(
          rewardAccounts$,
          transactions$,
          newTransaction$,
          provider,
          new InMemoryDelegationPortfolioStore()
        );

        expectObservable(portfolio$).toBe('a-b', {
          a: cip17DelegationPortfolio,
          b: cip17DelegationPortfolioChangeWeights
        });

        flush();
        expect(provider).not.toBeCalled();
      });
    });
  });
});
