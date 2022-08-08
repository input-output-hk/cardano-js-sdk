/* eslint-disable space-in-parens */
/* eslint-disable no-multi-spaces */
/* eslint-disable prettier/prettier */
import { Cardano, RewardsProvider } from '@cardano-sdk/core';
import { EMPTY, Observable, of } from 'rxjs';
import { InMemoryStakePoolsStore, KeyValueStore } from '../../../src/persistence';
import { RetryBackoffConfig } from 'backoff-rxjs';
import {
  StakeKeyStatus,
  TrackedStakePoolProvider,
  addressKeyStatuses,
  addressRewards,
  createDelegateeTracker,
  createQueryStakePoolsProvider,
  createRewardsProvider,
  fetchRewardsTrigger$,
  getStakePoolIdAtEpoch
} from '../../../src/services';
import { TxWithEpoch } from '../../../src/services/DelegationTracker/types';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { currentEpoch } from '../../mocks';

jest.mock('../../../src/services/util/coldObservableProvider', () => ({ coldObservableProvider: jest.fn() }));
const coldObservableProviderMock: jest.Mock = jest.requireMock(
  '../../../src/services/util/coldObservableProvider'
).coldObservableProvider;

describe('RewardAccounts', () => {
  const poolId1 = Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh');
  const poolId2 = Cardano.PoolId('pool1y6chk7x7fup4ms9leesdr57r4qy9cwxuee0msan72x976a6u0nc');
  const twoRewardAccounts = [
    'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
    'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d'
  ].map(Cardano.RewardAccount);

  test.todo('createQueryStakePoolsProvider emits stored values if they exist, updates storage when provider resolves');

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
            tx: { body: { certificates: [{
              __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash
            }] } }
          } as TxWithEpoch
        ],
        c: [
          {
            tx: { body: { certificates: [{
              __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash
            }] } }
          } as TxWithEpoch,
          {
            tx: { body: { certificates: [{
              __typename: Cardano.CertificateType.StakeKeyDeregistration, stakeKeyHash
            }] } }
          } as TxWithEpoch
        ]
      });
      const transactionsInFlight$ = cold('abaca', {
        a: [],
        b: [
          {
            body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash }] }
          } as Cardano.NewTxAlonzo
        ],
        c: [
          {
            body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, stakeKeyHash }] }
          } as Cardano.NewTxAlonzo
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
    starting with stored values and following up with provider, subtracting withdrawals in-flight`, () => {
      createTestScheduler().run(({ cold, hot, expectObservable }) => {
        const acc1Balance1 = 10_000_000n;
        const acc1Balance2 = 9_000_000n;
        const acc2Balance = 8_000_000n;
        const storedBalances = [7_000_000n, 6_000_000n];
        const acc1PendingWithdrawalQty = 1_000_000n;
        const transactionsInFlight$ = hot('a-b--c', {
          a: [],
          b: [{ body: { withdrawals: [{
            quantity: acc1PendingWithdrawalQty, stakeAddress: twoRewardAccounts[0] } as Cardano.Withdrawal
          ] } as Cardano.NewTxBodyAlonzo } as Cardano.NewTxAlonzo],
          c: []
        });
        const rewardsProvider = () => hot('-a--b-', {
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
        expectObservable(addressRewards$).toBe('abc-de', {
          a: storedBalances,
          b: [acc1Balance1, acc2Balance],
          c: [acc1Balance1 - acc1PendingWithdrawalQty, acc2Balance],
          d: [acc1Balance2 - acc1PendingWithdrawalQty, acc2Balance],
          e: [acc1Balance2, acc2Balance]
        });
      });
    });
  });

  describe('fetchRewardsTrigger$', () => {
    it('emits every epoch and after making a transaction with withdrawals', () => {
      const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      createTestScheduler().run(({ cold, expectObservable }) => {
        const tx2 = { body: { withdrawals: [{ quantity: 5n, stakeAddress: rewardAccount }] } } as Cardano.TxAlonzo;
        const epoch$ = cold(      'a-b--', { a: 100, b: 101 });
        const txConfirmed$ = cold('-a--b', {
          a: { body: {
            withdrawals: [{
              quantity: 3n,
              stakeAddress: Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')
            }] } } as Cardano.TxAlonzo,
          b: tx2
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
    const epoch$ = null as unknown as Observable<Cardano.Epoch>; // not used in this test
    const txConfirmed$ = EMPTY as Observable<Cardano.NewTxAlonzo>;
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
      expectObservable(target$).toBe('-ab', {
        a: [0n, 3n],
        b: [5n, 3n]
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
