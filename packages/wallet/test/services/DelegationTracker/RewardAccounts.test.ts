/* eslint-disable space-in-parens */
/* eslint-disable no-multi-spaces */
/* eslint-disable prettier/prettier */
/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, DRepInfo, RewardsProvider, StakePoolProvider } from '@cardano-sdk/core';
import { EMPTY, Observable, firstValueFrom, of } from 'rxjs';
import { InMemoryStakePoolsStore, KeyValueStore } from '../../../src/persistence';
import {
  OutgoingOnChainTx,
  PAGE_SIZE,
  TrackedStakePoolProvider,
  TxInFlight,
  addressCredentialStatuses,
  addressDRepDelegatees,
  addressRewards,
  createDelegateeTracker,
  createQueryStakePoolsProvider,
  createRewardsProvider,
  fetchRewardsTrigger$,
  getStakePoolIdAtEpoch
} from '../../../src';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch } from '../../../src/services/DelegationTracker/types';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { createTestScheduler, logger, mockProviders } from '@cardano-sdk/util-dev';
import { dummyCbor } from '../../util';

const { currentEpoch, generateStakePools, mockStakePoolsProvider } = mockProviders;

jest.mock('@cardano-sdk/util-rxjs', () => {
  const actual = jest.requireActual('@cardano-sdk/util-rxjs');
  return {
    ...actual,
    coldObservableProvider: jest.fn().mockImplementation((...args) => actual.coldObservableProvider(...args))
  };
});

describe('RewardAccounts', () => {
  const coldObservableProviderMock = coldObservableProvider as jest.MockedFunction<typeof coldObservableProvider>;
  const txId1 = Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000');
  const txId2 = Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7');
  const poolId1 = Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh');
  const poolId2 = Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc');
  const twoRewardAccounts = [
    'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
    'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d'
  ].map(Cardano.RewardAccount);

  let drepInfo$: jest.Mock<Observable<DRepInfo[]>, [drepIds: Cardano.DRepID[]]>;
  let store: InMemoryStakePoolsStore;
  let stakePoolProviderMock: StakePoolProvider;
  let stakePoolProviderTracked: TrackedStakePoolProvider;
  let provider: (poolIds: Cardano.PoolId[]) => Observable<Cardano.StakePool[]>;
  const retryBackoffConfig = { initialInterval: 1 };

  beforeEach(() => {
    store = new InMemoryStakePoolsStore();
    store.getValues = jest.fn().mockImplementation(store.getValues.bind(store));
    stakePoolProviderMock = mockStakePoolsProvider();
    stakePoolProviderTracked = new TrackedStakePoolProvider(stakePoolProviderMock);
    provider = createQueryStakePoolsProvider(stakePoolProviderTracked, store, retryBackoffConfig, logger);
    drepInfo$ = jest.fn(
      (drepIds: Cardano.DRepID[]): Observable<DRepInfo[]> => of(drepIds.map((id) => ({ active: true, id } as DRepInfo)))
    );
    coldObservableProviderMock.mockClear();
  });

  test.todo('createQueryStakePoolsProvider emits stored values if they exist, updates storage when provider resolves');

  test('emits entire stake pool list resolved by StakePoolsProvider', async () => {
    const pageSize = PAGE_SIZE;
    const secondPageSize = 5;
    const totalTxsCount = pageSize + secondPageSize;

    const firstPageTxs = {
      pageResults: generateStakePools(pageSize),
      totalResultCount: totalTxsCount
    };
    const secondPageTxs = {
      pageResults: generateStakePools(secondPageSize),
      totalResultCount: totalTxsCount
    };

    stakePoolProviderMock.queryStakePools = jest
      .fn()
      .mockResolvedValueOnce(firstPageTxs)
      .mockResolvedValueOnce(secondPageTxs);

    const allStakePools = await firstValueFrom(provider([poolId1, poolId2]));
    expect(allStakePools.length).toEqual(totalTxsCount);
    expect(allStakePools).toEqual([...firstPageTxs.pageResults, ...secondPageTxs.pageResults]);
    expect(store.getValues).toHaveBeenCalledWith([poolId1, poolId2]);
  });

  test('getStakePoolIdAtEpoch', () => {
    const transactions = [
      {
        certificates: [{ __typename: Cardano.CertificateType.StakeRegistration } as Cardano.StakeAddressCertificate],
        epoch: Cardano.EpochNo(100)
      },
      {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: poolId1
          } as Cardano.StakeDelegationCertificate
        ],
        epoch: Cardano.EpochNo(101)
      },
      {
        certificates: [{ __typename: Cardano.CertificateType.StakeDeregistration } as Cardano.StakeAddressCertificate],
        epoch: Cardano.EpochNo(102)
      },
      {
        certificates: [
          { __typename: Cardano.CertificateType.StakeDelegation, poolId: poolId2 } as Cardano.StakeDelegationCertificate
        ],
        epoch: Cardano.EpochNo(103)
      }
    ];
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(102))).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(103))).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(104))).toBe(poolId1);
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(105))).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(106))).toBeUndefined();
  });

  test('getStakePoolIdAtEpoch Conway era', () => {
    const transactions = [
      {
        certificates: [{ __typename: Cardano.CertificateType.Registration } as Cardano.NewStakeAddressCertificate],
        epoch: Cardano.EpochNo(100)
      },
      {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: poolId1
          } as Cardano.StakeDelegationCertificate
        ],
        epoch: Cardano.EpochNo(101)
      },
      // Unregister stake key
      // Register stake key with vote_reg_deleg_cert
      // Delegate to pool with stake_vote_deleg_cert
      {
        certificates: [{ __typename: Cardano.CertificateType.Unregistration } as Cardano.NewStakeAddressCertificate],
        epoch: Cardano.EpochNo(102)
      },
      {
        certificates: [
          {
            __typename: Cardano.CertificateType.VoteRegistrationDelegation
          } as Cardano.VoteRegistrationDelegationCertificate
        ],
        epoch: Cardano.EpochNo(103)
      },
      {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            poolId: poolId2
          } as Cardano.StakeVoteDelegationCertificate
        ],
        epoch: Cardano.EpochNo(104)
      },
      // Unregister stake key
      // Register stake key and delegate with stake_reg_deleg_cert
      {
        certificates: [{ __typename: Cardano.CertificateType.Unregistration } as Cardano.NewStakeAddressCertificate],
        epoch: Cardano.EpochNo(105)
      },
      {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeRegistrationDelegation,
            poolId: poolId1
          } as Cardano.StakeRegistrationDelegationCertificate
        ],
        epoch: Cardano.EpochNo(106)
      },
      // Unregister stake key
      // Register stake key and delegate with stake_vote_reg_deleg_cert
      {
        certificates: [{ __typename: Cardano.CertificateType.Unregistration } as Cardano.NewStakeAddressCertificate],
        epoch: Cardano.EpochNo(107)
      },
      {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
            poolId: poolId2
          } as Cardano.StakeVoteRegistrationDelegationCertificate
        ],
        epoch: Cardano.EpochNo(108)
      },
      // Delegation ignored after stake key is unregistered
      {
        certificates: [{ __typename: Cardano.CertificateType.Unregistration } as Cardano.NewStakeAddressCertificate],
        epoch: Cardano.EpochNo(109)
      },
      {
        certificates: [
          { __typename: Cardano.CertificateType.StakeDelegation, poolId: poolId1 } as Cardano.StakeDelegationCertificate
        ],
        epoch: Cardano.EpochNo(110)
      }
    ];
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(102))).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(103))).toBeUndefined();
    // PoolId is available 3 epochs after delegation
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(104))).toBe(poolId1);
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(105))).toBeUndefined();
    // Stake key is registered and delegated using VoteRegistrationDelegationCertificate and StakeVoteDelegation
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(107))).toBe(poolId2);
    // Stake key is registered and delegated using StakeRegistrationDelegationCertificate
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(109))).toBe(poolId1);
    // Stake key is registered and delegated using StakeVoteRegistrationDelegationCertificate
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(111))).toBe(poolId2);
    // New delegation has no effect due to stake key being unregistered
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(112))).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(Cardano.EpochNo(113))).toBeUndefined();
  });

  test.each([
    Cardano.CertificateType.Registration,
    Cardano.CertificateType.StakeRegistrationDelegation,
    Cardano.CertificateType.StakeVoteRegistrationDelegation,
    Cardano.CertificateType.VoteRegistrationDelegation
  ])('addresscredentialStatuses %p', (registrationCertType) => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
      const transactions$ = cold('a-b-c', {
        a: [],
        b: [
          {
            tx: {
              body: {
                certificates: [
                  {
                    __typename: registrationCertType,
                    deposit: 0n,
                    stakeCredential: {
                      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
                      type: Cardano.CredentialType.KeyHash
                    }
                  }
                ]
              }
            }
          } as TxWithEpoch
        ],
        c: [
          {
            tx: {
              body: {
                certificates: [
                  {
                    __typename: registrationCertType,
                    deposit: 0n,
                    stakeCredential: {
                      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
                      type: Cardano.CredentialType.KeyHash
                    }
                  }
                ]
              }
            }
          } as TxWithEpoch,
          {
            tx: {
              body: {
                certificates: [
                  {
                    __typename: Cardano.CertificateType.Unregistration,
                    deposit: 0n,
                    stakeCredential: {
                      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
                      type: Cardano.CredentialType.KeyHash
                    }
                  }
                ]
              }
            }
          } as TxWithEpoch
        ]
      });
      const transactionsInFlight$ = cold<TxInFlight[]>('abaca', {
        a: [],
        b: [
          {
            body: {
              certificates: [
                {
                  __typename: registrationCertType,
                  deposit: 0n,
                  stakeCredential: {
                    hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
                    type: Cardano.CredentialType.KeyHash
                  }
                }
              ]
            } as Cardano.TxBody,
            cbor: dummyCbor,
            id: txId1
          }
        ],
        c: [
          {
            body: {
              certificates: [
                {
                  __typename: Cardano.CertificateType.Unregistration,
                  deposit: 0n,
                  stakeCredential: {
                    hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
                    type: Cardano.CredentialType.KeyHash
                  }
                }
              ]
            } as Cardano.TxBody,
            cbor: dummyCbor,
            id: txId2
          }
        ]
      });
      const tracker$ = addressCredentialStatuses([rewardAccount], transactions$, transactionsInFlight$);
      expectObservable(tracker$).toBe('abcda', {
        a: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistered }],
        b: [{ credentialStatus: Cardano.StakeCredentialStatus.Registering }],
        c: [{ credentialStatus: Cardano.StakeCredentialStatus.Registered, deposit: 0n }],
        d: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistering }]
      });
    });
  });

  describe('addressRewards', () => {
    it(`emits reward account balance for every reward account,
    starting with stored values and following up with provider, subtracting withdrawals in-flight
    and awaiting for rewards update after transaction is discovered on-chain`, () => {
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const acc1Balance1 = 10_000_000n;
        const acc1Balance2 = 9_000_000n;
        const acc2Balance = 8_000_000n;
        const storedBalances = [7_000_000n, 6_000_000n];
        const acc1PendingWithdrawalQty = 1_000_000n;
        // 'aaa' in the end is to ensure that it's awaiting for rewards update
        // even if more (unrelated) transactions get discovered on-chain
        const transactionsInFlight$ = hot<TxInFlight[]>('a-b--a--b-aaa', {
          a: [],
          b: [
            {
              body: {
                withdrawals: [
                  {
                    quantity: acc1PendingWithdrawalQty,
                    stakeAddress: twoRewardAccounts[0]
                  } as Cardano.Withdrawal
                ]
              } as Cardano.TxBody,
              cbor: dummyCbor,
              id: txId1
            }
          ]
        });
        const rewardsProvider = () =>
          hot('-a--b-a--b---a', {
            a: [acc1Balance1, acc2Balance],
            b: [acc1Balance2, acc2Balance]
          });
        const balancesStore = {
          getValues(_: Cardano.RewardAccount[]) {
            return cold('(a|)', { a: storedBalances }) as Observable<bigint[]>;
          },
          setValue(_, __) {
            return of(void 0);
          }
        } as KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>;
        const addressRewards$ = addressRewards(
          twoRewardAccounts,
          transactionsInFlight$,
          rewardsProvider,
          balancesStore
        );
        expectObservable(addressRewards$).toBe('abc-d-b-cd---b', {
          a: storedBalances,
          b: [acc1Balance1, acc2Balance],
          c: [acc1Balance1 - acc1PendingWithdrawalQty, acc2Balance],
          d: [acc1Balance2 - acc1PendingWithdrawalQty, acc2Balance]
        });
      });
    });

    it('emits reward accounts when rewards update before in flight', () => {
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const accBalance1 = 10_000_000n;
        const accBalance2 = 9_000_000n;

        const acc1PendingWithdrawalQty = 1_000_000n;
        const transactionsInFlightEmits: Record<string, TxInFlight[]> = {
          x: [],
          y: [
            {
              body: {
                withdrawals: [
                  {
                    quantity: acc1PendingWithdrawalQty,
                    stakeAddress: twoRewardAccounts[0]
                  } as Cardano.Withdrawal
                ]
              } as Cardano.TxBody,
              cbor: dummyCbor,
              id: txId1
            }
          ]
        };
        const rewardsProviderEmits = {
          a: [accBalance1],
          b: [accBalance2]
        };
        const transactionsInFlight$ = hot('y----x--', transactionsInFlightEmits);
        const rewardsFrames = hot('        -a-b---b', rewardsProviderEmits);
        const expectedFrames = '           -m-n---p';
        const rewardsProvider = jest.fn().mockReturnValue(rewardsFrames);

        const balancesStore = {
          getValues(_: Cardano.RewardAccount[]) {
            return cold('|') as Observable<bigint[]>;
          },
          setValue(_, __) {
            return of(void 0);
          }
        } as KeyValueStore<Cardano.RewardAccount, Cardano.Lovelace>;
        const addressRewards$ = addressRewards(
          twoRewardAccounts,
          transactionsInFlight$,
          rewardsProvider,
          balancesStore
        );
        expectObservable(addressRewards$).toBe(expectedFrames, {
          m: [accBalance1 - acc1PendingWithdrawalQty],
          n: [accBalance2 - acc1PendingWithdrawalQty],
          p: [accBalance2]
        });
      });
    });
  });

  describe('fetchRewardsTrigger$', () => {
    it('emits every epoch and after making a transaction with withdrawals', () => {
      const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      createTestScheduler().run(({ cold, expectObservable }) => {
        const onChainTx1: OutgoingOnChainTx = {
          body: {
            withdrawals: [
              {
                quantity: 3n,
                stakeAddress: Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
              }
            ]
          } as Cardano.TxBody,
          cbor: dummyCbor,
          id: txId1,
          slot: Cardano.Slot(1)
        };
        const onChainTx2: OutgoingOnChainTx = {
          body: { withdrawals: [{ quantity: 5n, stakeAddress: rewardAccount }] } as Cardano.TxBody,
          cbor: dummyCbor,
          id: txId2,
          slot: Cardano.Slot(2)
        };
        const epoch$ = cold('a-b--', { a: Cardano.EpochNo(100), b: Cardano.EpochNo(101) });
        const txConfirmed$ = cold('-a--b', {
          a: onChainTx1,
          b: onChainTx2
        });
        const target$ = fetchRewardsTrigger$(epoch$, txConfirmed$, rewardAccount);
        expectObservable(target$).toBe('a-b-c', {
          a: 100,
          b: 101,
          c: 5n
        });
      });
    });
  });

  test('createRewardsProvider', () => {
    const rewardsProvider = null as unknown as RewardsProvider; // not used in this test
    const config = null as unknown as RetryBackoffConfig; // not used in this test
    const epoch$ = null as unknown as Observable<Cardano.EpochNo>; // not used in this test
    const onChainTx$ = EMPTY as Observable<OutgoingOnChainTx>;
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      coldObservableProviderMock
        .mockReturnValueOnce(
          cold('a-b-c', {
            a: 0n,
            b: 5n,
            c: 5n
          })
        )
        .mockReturnValueOnce(
          cold('-a', {
            a: 3n
          })
        );
      const target$ = createRewardsProvider(epoch$, onChainTx$, rewardsProvider, config, logger)(twoRewardAccounts);
      expectObservable(target$).toBe('-ab-c', {
        a: [0n, 3n],
        b: [5n, 3n],
        c: [5n, 3n] // duplicates are filtered in the coldObservable and this one is fake and emits duplicates
      });
      flush();
      expect(coldObservableProviderMock).toBeCalledTimes(2);
    });
  });

  describe('createDelegateeTracker', () => {
    it('queries and maps stake pools for epoch, epoch+1 and epoch+2', () => {
      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const epoch = Cardano.EpochNo(currentEpoch.number);
        const epoch$ = cold('-a', { a: epoch });
        const stakePoolQueryResult = [{ id: poolId1 }, { id: poolId2 }];
        const stakePoolProvider = jest.fn().mockReturnValue(cold('-a', { a: stakePoolQueryResult }));
        const target$ = createDelegateeTracker(
          stakePoolProvider,
          epoch$,
          cold('a', {
            a: [
              {
                certificates: [
                  { __typename: Cardano.CertificateType.StakeRegistration } as Cardano.StakeAddressCertificate,
                  {
                    __typename: Cardano.CertificateType.StakeDelegation,
                    poolId: poolId1
                  } as Cardano.StakeDelegationCertificate
                ],
                epoch: Cardano.EpochNo(epoch - 2)
              },
              {
                certificates: [
                  {
                    __typename: Cardano.CertificateType.StakeDelegation,
                    poolId: poolId2
                  } as Cardano.StakeDelegationCertificate
                ],
                epoch: Cardano.EpochNo(epoch - 1)
              }
            ]
          })
        );
        expectObservable(target$).toBe('--a', {
          a: {
            currentEpoch: stakePoolQueryResult[0],
            nextEpoch: stakePoolQueryResult[1],
            nextNextEpoch: stakePoolQueryResult[1]
          }
        });
        flush();
        expect(stakePoolProvider).toBeCalledTimes(1);
        expect(stakePoolProvider).toBeCalledWith([poolId1, poolId2]);
      });
    });

    test('does not query the StakePoolProvider when there are no delegations certs provided', () => {
      createTestScheduler().run(({ cold, expectObservable, flush }) => {
        const epoch$ = cold('-a', { a: Cardano.EpochNo(currentEpoch.number) });
        const trackedStakePoolProvider = {
          queryStakePools: jest.fn(),
          setStatInitialized: jest.fn(),
          stats: { queryStakePools$: {} }
        };
        const observableStakePoolProvider = createQueryStakePoolsProvider(
          trackedStakePoolProvider as unknown as TrackedStakePoolProvider,
          new InMemoryStakePoolsStore(),
          { initialInterval: 10 },
          logger
        );
        const target$ = createDelegateeTracker(
          observableStakePoolProvider,
          epoch$,
          cold('a', {
            a: []
          })
        );
        expectObservable(target$).toBe('-a', {
          a: {
            currentEpoch: undefined,
            nextEpoch: undefined,
            nextNextEpoch: undefined
          }
        });
        flush();
        expect(trackedStakePoolProvider.queryStakePools).toBeCalledTimes(0);
        expect(trackedStakePoolProvider.setStatInitialized).toBeCalledTimes(1);
        expect(trackedStakePoolProvider.setStatInitialized).toBeCalledWith(
          trackedStakePoolProvider.stats.queryStakePools$
        );
      });
    });
  });

  describe('addressDRepDelegatees', () => {
    it('emits a dRep delegatee for every reward account', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const rewardAccount1 = Cardano.RewardAccount(
          'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
        );
        const rewardAccount2 = Cardano.RewardAccount(
          'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d'
        );
        const stakeKeyHash1 = Cardano.RewardAccount.toHash(rewardAccount1);
        const stakeKeyHash2 = Cardano.RewardAccount.toHash(rewardAccount2);

        const transactions$ = cold('a-b-c', {
          a: [],
          b: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysAbstain'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          c: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysAbstain'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash2),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ]
        });
        const tracker$ = addressDRepDelegatees([rewardAccount1, rewardAccount2], transactions$, drepInfo$);
        expectObservable(tracker$).toBe('a-b-c', {
          a: [undefined, undefined],
          b: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysAbstain'
              }
            },
            undefined
          ],
          c: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysAbstain'
              }
            },
            {
              delegateRepresentative: {
                __typename: 'AlwaysNoConfidence'
              }
            }
          ]
        });
      });
    });

    it('emits the most recent dRep delegatee', () => {
      const rewardAccount1 = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      const rewardAccount2 = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
      const stakeKeyHash1 = Cardano.RewardAccount.toHash(rewardAccount1);
      const stakeKeyHash2 = Cardano.RewardAccount.toHash(rewardAccount2);
      const delegateRepresentative: Cardano.Credential = {
        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash2),
        type: Cardano.CredentialType.KeyHash
      };
      const drepId = Cardano.DRepID.cip129FromCredential(delegateRepresentative);
      createTestScheduler().run(({ cold, expectObservable }) => {
        const transactions$ = cold('a-b-c', {
          a: [],
          b: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          c: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeVoteDelegation,
                      dRep: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash2),
                        type: Cardano.CredentialType.KeyHash
                      },
                      poolId: poolId1,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ]
        });
        const tracker$ = addressDRepDelegatees([rewardAccount1], transactions$, drepInfo$);
        expectObservable(tracker$).toBe('a-b-c', {
          a: [undefined],
          b: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysNoConfidence'
              }
            }
          ],
          c: [{ delegateRepresentative: { active: true, id: drepId } as DRepInfo }]
        });
      });
      expect(drepInfo$).toHaveBeenLastCalledWith([Cardano.DRepID.cip129FromCredential(delegateRepresentative)]);
    });

    it('unsets dRep if a StakeDeregistration happens', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const rewardAccount1 = Cardano.RewardAccount(
          'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
        );
        const stakeKeyHash1 = Cardano.RewardAccount.toHash(rewardAccount1);

        const transactions$ = cold('a-b-c-d-e', {
          a: [],
          b: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          c: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeDeregistration,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          d: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeDeregistration,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(102),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeRegistration,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          e: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeDeregistration,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(102),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeRegistration,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(103),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ]
        });
        const tracker$ = addressDRepDelegatees([rewardAccount1], transactions$, drepInfo$);
        expectObservable(tracker$).toBe('a-b-c---d', {
          a: [undefined],
          b: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysNoConfidence'
              }
            }
          ],
          c: [undefined], // Un-register sets dRep to undefined, re-register still doesnt defined dRep but observable doesnt re-emit undefined
          d: [
            {
              delegateRepresentative: {
                // delegate
                __typename: 'AlwaysNoConfidence'
              }
            }
          ]
        });
      });
    });

    it('unsets dRep if a Unregistration happens', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const rewardAccount1 = Cardano.RewardAccount(
          'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
        );
        const stakeKeyHash1 = Cardano.RewardAccount.toHash(rewardAccount1);

        const transactions$ = cold('a-b-c-d', {
          a: [],
          b: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          c: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.Unregistration,
                      deposit: 0n,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          d: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.Unregistration,
                      deposit: 0n,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(102),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteRegistrationDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      deposit: 0n,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ]
        });
        const tracker$ = addressDRepDelegatees([rewardAccount1], transactions$, drepInfo$);
        expectObservable(tracker$).toBe('a-b-c-d', {
          a: [undefined],
          b: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysNoConfidence'
              }
            }
          ],
          c: [undefined], // Un-register sets dRep to undefined
          d: [
            {
              delegateRepresentative: {
                // re-register + vote delegate
                __typename: 'AlwaysNoConfidence'
              }
            }
          ]
        });
      });
    });

    it('detects all vote delegation certificates', () => {
      const rewardAccount1 = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      const rewardAccount2 = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
      const stakeKeyHash1 = Cardano.RewardAccount.toHash(rewardAccount1);
      const stakeKeyHash2 = Cardano.RewardAccount.toHash(rewardAccount2);

      const delegateRepresentative1: Cardano.Credential = {
        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
        type: Cardano.CredentialType.ScriptHash
      };
      const drepId1 = Cardano.DRepID.cip129FromCredential(delegateRepresentative1);

      const delegateRepresentative2: Cardano.Credential = {
        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash2),
        type: Cardano.CredentialType.KeyHash
      };
      const drepId2 = Cardano.DRepID.cip129FromCredential(delegateRepresentative2);


      createTestScheduler().run(({ cold, expectObservable }) => {
        const transactions$ = cold('a-b-c-d-e', {
          a: [],
          b: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysAbstain'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          c: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeVoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      poolId: poolId1,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          d: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysAbstain'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeVoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      poolId: poolId1,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(102),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
                      dRep: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash2),
                        type: Cardano.CredentialType.KeyHash
                      },
                      deposit: 2_000_000n,
                      poolId: poolId1,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ],
          e: [
            {
              epoch: Cardano.EpochNo(100),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteDelegation,
                      dRep: {
                        __typename: 'AlwaysAbstain'
                      },
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(101),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeVoteDelegation,
                      dRep: {
                        __typename: 'AlwaysNoConfidence'
                      },
                      poolId: poolId1,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(102),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
                      dRep: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash2),
                        type: Cardano.CredentialType.KeyHash
                      },
                      deposit: 2_000_000n,
                      poolId: poolId1,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch,
            {
              epoch: Cardano.EpochNo(103),
              tx: {
                body: {
                  certificates: [
                    {
                      __typename: Cardano.CertificateType.VoteRegistrationDelegation,
                      dRep: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.ScriptHash
                      },
                      deposit: 2_000_000n,
                      stakeCredential: {
                        hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash1),
                        type: Cardano.CredentialType.KeyHash
                      }
                    }
                  ]
                }
              }
            } as TxWithEpoch
          ]
        });
        const tracker$ = addressDRepDelegatees([rewardAccount1], transactions$, drepInfo$);
        expectObservable(tracker$).toBe('a-b-c-d-e', {
          a: [undefined],
          b: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysAbstain'
              }
            }
          ],
          c: [
            {
              delegateRepresentative: {
                __typename: 'AlwaysNoConfidence'
              }
            }
          ],
          d: [{ delegateRepresentative: { active: true, id: drepId2 } as DRepInfo }],
          e: [{ delegateRepresentative: { active: true, id: drepId1 } as DRepInfo }]
        });
      });
      expect(drepInfo$).toHaveBeenCalledTimes(5);
      // Initial empty drepDelegatees
      expect(drepInfo$).toHaveBeenNthCalledWith(1, []);
      // AlwaysAbstain does not fetch from drepInfo$
      expect(drepInfo$).toHaveBeenNthCalledWith(2, []);
      // AlwaysNoConfidence does not fetch from drepInfo$
      expect(drepInfo$).toHaveBeenNthCalledWith(3, []);
      expect(drepInfo$).toHaveBeenNthCalledWith(4, [Cardano.DRepID.cip129FromCredential(delegateRepresentative2)]);
      expect(drepInfo$).toHaveBeenNthCalledWith(5, [Cardano.DRepID.cip129FromCredential(delegateRepresentative1)]);
    });
  });
});
