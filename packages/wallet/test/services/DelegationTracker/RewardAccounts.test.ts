/* eslint-disable space-in-parens */
/* eslint-disable no-multi-spaces */
/* eslint-disable prettier/prettier */
/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, RewardsProvider, StakePoolProvider } from '@cardano-sdk/core';
import {
  ConfirmedTx,
  PAGE_SIZE,
  StakeKeyStatus,
  TrackedStakePoolProvider,
  TxInFlight,
  addressKeyStatuses,
  addressRewards,
  createDelegateeTracker,
  createQueryStakePoolsProvider,
  createRewardsProvider,
  fetchRewardsTrigger$,
  getStakePoolIdAtEpoch
} from '../../../src/services';
import { EMPTY, Observable, firstValueFrom, of } from 'rxjs';
import { InMemoryStakePoolsStore, KeyValueStore } from '../../../src/persistence';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxWithEpoch } from '../../../src/services/DelegationTracker/types';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { currentEpoch, generateStakePools, mockStakePoolsProvider } from '../../mocks';

jest.mock('../../../src/services/util/coldObservableProvider', () => {
  const actual = jest.requireActual('../../../src/services/util/coldObservableProvider');
  return {
    coldObservableProvider: jest.fn().mockImplementation((...args) => actual.coldObservableProvider(...args))
  };
});
const coldObservableProviderMock: jest.Mock =
  jest.requireMock('../../../src/services/util/coldObservableProvider').coldObservableProvider;

describe('RewardAccounts', () => {
  const poolId1 = Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh');
  const poolId2 = Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc');
  const twoRewardAccounts = [
    'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
    'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d'
  ].map(Cardano.RewardAccount);

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
    provider = createQueryStakePoolsProvider(stakePoolProviderTracked, store, retryBackoffConfig);
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

  test('getStakePoolIdAtEpoch ', () => {
    const transactions = [
      {
        certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.StakeAddressCertificate],
        epoch: 100
      },
      {
        certificates: [{
          __typename: Cardano.CertificateType.StakeDelegation, poolId: poolId1
        } as Cardano.StakeDelegationCertificate],
        epoch: 101
      },
      {
        certificates: [
          { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.StakeAddressCertificate
        ],
        epoch: 102
      },
      {
        certificates: [
          { __typename: Cardano.CertificateType.StakeDelegation, poolId: poolId2 } as Cardano.StakeDelegationCertificate
        ],
        epoch: 103
      }
    ];
    expect(getStakePoolIdAtEpoch(transactions)(102)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(103)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(104)).toBe(poolId1);
    expect(getStakePoolIdAtEpoch(transactions)(105)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(106)).toBeUndefined();
  });

  test('addressKeyStatuses ', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount);
      const transactions$ = cold('a-b-c', {
        a: [],
        b: [
          {
            tx: {
              body: {
                certificates: [{
                  __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash
                }]
              }
            }
          } as TxWithEpoch
        ],
        c: [
          {
            tx: {
              body: {
                certificates: [{
                  __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash
                }]
              }
            }
          } as TxWithEpoch,
          {
            tx: {
              body: {
                certificates: [{
                  __typename: Cardano.CertificateType.StakeKeyDeregistration, stakeKeyHash
                }]
              }
            }
          } as TxWithEpoch
        ]
      });
      const transactionsInFlight$ = cold('abaca', {
        a: [],
        b: [
          { tx: {
            body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash }] }
          } as Cardano.Tx }
        ],
        c: [
          { tx: {
            body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, stakeKeyHash }] }
          } as Cardano.Tx }
        ]
      });
      const tracker$ = addressKeyStatuses([rewardAccount], transactions$, transactionsInFlight$);
      expectObservable(tracker$).toBe('abcda', {
        a: [StakeKeyStatus.Unregistered],
        b: [StakeKeyStatus.Registering],
        c: [StakeKeyStatus.Registered],
        d: [StakeKeyStatus.Unregistering]
      });
    });
  });

  describe('addressRewards', () => {
    it(`emits reward account balance for every reward account,
    starting with stored values and following up with provider, subtracting withdrawals in-flight
    and awaiting for rewards update after transaction is confirmed`, () => {
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const acc1Balance1 = 10_000_000n;
        const acc1Balance2 = 9_000_000n;
        const acc2Balance = 8_000_000n;
        const storedBalances = [7_000_000n, 6_000_000n];
        const acc1PendingWithdrawalQty = 1_000_000n;
        // 'aaa' in the end is to ensure that it's awaiting for rewards update
        // even if more (unrelated) transactions get confirmed
        const transactionsInFlight$ = hot('a-b--a--b-aaa', {
          a: [],
          b: [{ tx: { body: { withdrawals: [{
            quantity: acc1PendingWithdrawalQty, stakeAddress: twoRewardAccounts[0] } as Cardano.Withdrawal
          ] } as Cardano.TxBody } as Cardano.Tx }]
        });
        const rewardsProvider = () => hot('-a--b-a--b---a', {
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
          twoRewardAccounts, transactionsInFlight$, rewardsProvider, balancesStore
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
        const transactionsInFlightEmits = {
          x: [] as TxInFlight[],
          y: [{ tx: { body: { withdrawals: [{
            quantity: acc1PendingWithdrawalQty, stakeAddress: twoRewardAccounts[0] } as Cardano.Withdrawal
          ] } as Cardano.TxBody } } as TxInFlight]
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
          twoRewardAccounts, transactionsInFlight$, rewardsProvider, balancesStore
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
        const tx2 = { body: { withdrawals: [{ quantity: 5n, stakeAddress: rewardAccount }] } } as Cardano.HydratedTx;
        const epoch$ = cold(      'a-b--', { a: 100, b: 101 });
        const txConfirmed$ = cold('-a--b', {
          a: { confirmedAt: 1, tx: { body: {
            withdrawals: [{
              quantity: 3n,
              stakeAddress: Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
            }] } } as Cardano.HydratedTx },
          b: { confirmedAt: 2, tx: tx2 }
        });
        const target$ = fetchRewardsTrigger$(epoch$, txConfirmed$, rewardAccount);
        expectObservable(target$).toBe('a-b-c', {
          a: 100, b: 101, c: 5n
        });
      });
    });
  });

  test('createRewardsProvider', () => {
    const rewardsProvider = null as unknown as RewardsProvider; // not used in this test
    const config = null as unknown as RetryBackoffConfig; // not used in this test
    const epoch$ = null as unknown as Observable<Cardano.EpochNo>; // not used in this test
    const txConfirmed$ = EMPTY as Observable<ConfirmedTx>;
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
      const target$ = createRewardsProvider(
        epoch$,
        txConfirmed$,
        rewardsProvider,
        config
      )(twoRewardAccounts);
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
        const epoch = currentEpoch.number;
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
                  { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.StakeAddressCertificate,
                  {
                    __typename: Cardano.CertificateType.StakeDelegation,
                    poolId: poolId1
                  } as Cardano.StakeDelegationCertificate
                ],
                epoch: epoch - 2
              },
              {
                certificates: [
                  {
                    __typename: Cardano.CertificateType.StakeDelegation,
                    poolId: poolId2
                  } as Cardano.StakeDelegationCertificate
                ],
                epoch: epoch - 1
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
        const epoch$ = cold('-a', { a: currentEpoch.number });
        const trackedStakePoolProvider = {
          queryStakePools: jest.fn(),
          setStatInitialized: jest.fn(),
          stats: { queryStakePools$: {} }
        };
        const observableStakePoolProvider = createQueryStakePoolsProvider(
          trackedStakePoolProvider as unknown as TrackedStakePoolProvider,
          new InMemoryStakePoolsStore(),
          { initialInterval: 10 }
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
});
