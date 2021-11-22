/* eslint-disable space-in-parens */
/* eslint-disable no-multi-spaces */
/* eslint-disable prettier/prettier */
import { Cardano, WalletProvider } from '@cardano-sdk/core';
import { EMPTY, Observable } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import {
  StakeKeyStatus,
  addressKeyStatuses,
  createDelegateeTracker,
  createRewardsProvider,
  fetchRewardsTrigger$,
  getStakePoolIdAtEpoch
} from '../../../src/services';
import { TxWithEpoch } from '../../../src/services/DelegationTracker/types';
import { createTestScheduler } from '../../testScheduler';
import { currentEpoch } from '../../mocks';

jest.mock('../../../src/services/util/coldObservableProvider', () => ({ coldObservableProvider: jest.fn() }));
const coldObservableProviderMock: jest.Mock = jest.requireMock(
  '../../../src/services/util/coldObservableProvider'
).coldObservableProvider;

describe('RewardAccounts', () => {
  test('getStakePoolIdAtEpoch ', () => {
    const transactions = [
      {
        certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.StakeAddressCertificate],
        epoch: 100
      },
      {
        certificates: [
          { __typename: Cardano.CertificateType.StakeDelegation, poolId: 'pool1' } as Cardano.StakeDelegationCertificate
        ],
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
          { __typename: Cardano.CertificateType.StakeDelegation, poolId: 'pool2' } as Cardano.StakeDelegationCertificate
        ],
        epoch: 103
      }
    ];
    expect(getStakePoolIdAtEpoch(transactions)(102)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(103)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(104)).toBe('pool1');
    expect(getStakePoolIdAtEpoch(transactions)(105)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(106)).toBeUndefined();
  });

  test('addressKeyStatuses ', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const address = 'stake...';
      const transactions$ = cold('a-b-c', {
        a: [],
        b: [
          {
            tx: { body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, address }] } }
          } as TxWithEpoch
        ],
        c: [
          {
            tx: { body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, address }] } }
          } as TxWithEpoch,
          {
            tx: { body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, address }] } }
          } as TxWithEpoch
        ]
      });
      const transactionsInFlight$ = cold('abaca', {
        a: [],
        b: [
          {
            body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyRegistration, address }] }
          } as Cardano.NewTxAlonzo
        ],
        c: [
          {
            body: { certificates: [{ __typename: Cardano.CertificateType.StakeKeyDeregistration, address }] }
          } as Cardano.NewTxAlonzo
        ]
      });
      const tracker$ = addressKeyStatuses([address], transactions$, transactionsInFlight$);
      expectObservable(tracker$).toBe('abcda', {
        a: [StakeKeyStatus.Unregistered],
        b: [StakeKeyStatus.Registering],
        c: [StakeKeyStatus.Registered],
        d: [StakeKeyStatus.Unregistering]
      });
    });
  });

  describe('fetchRewardsTrigger$', () => {
    it('emits every epoch and after making a transaction with withdrawals', () => {
      const rewardAccount = 'stake...';
      createTestScheduler().run(({ cold, expectObservable }) => {
        const tx2 = { body: { withdrawals: [{ quantity: 5n, stakeAddress: rewardAccount }] } } as Cardano.TxAlonzo;
        const epoch$ = cold(      'a-b--', { a: 100, b: 101 });
        const txConfirmed$ = cold('-a--b', {
          a: { body: { withdrawals: [{ quantity: 3n, stakeAddress: 'stakeother...' }] } } as Cardano.TxAlonzo,
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
    const walletProvider = null as unknown as WalletProvider; // not used in this test
    const config = null as unknown as RetryBackoffConfig; // not used in this test
    const epoch$ = null as unknown as Observable<Cardano.Epoch>; // not used in this test
    const txConfirmed$ = EMPTY as Observable<Cardano.NewTxAlonzo>;
    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      coldObservableProviderMock
        .mockReturnValueOnce(
          cold('a-b-c', {
            a: {},
            b: { delegationAndRewards: { rewards: 5n } },
            c: { delegationAndRewards: { rewards: 5n } }
          })
        )
        .mockReturnValueOnce(
          cold('-a', {
            a: { delegationAndRewards: { rewards: 3n } }
          })
        );
      const target$ = createRewardsProvider(
        epoch$,
        txConfirmed$,
        walletProvider,
        config
      )(['stake...', 'stakeother...']);
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
        const stakePoolQueryResult = [{ id: 'pool1' }, { id: 'pool2' }];
        const stakePoolSearchProvider = jest.fn().mockReturnValue(cold('-a', { a: stakePoolQueryResult }));
        const target$ = createDelegateeTracker(
          stakePoolSearchProvider,
          epoch$,
          cold('a', {
            a: [
              {
                certificates: [
                  { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.StakeAddressCertificate,
                  {
                    __typename: Cardano.CertificateType.StakeDelegation,
                    poolId: 'pool1'
                  } as Cardano.StakeDelegationCertificate
                ],
                epoch: epoch - 2
              },
              {
                certificates: [
                  {
                    __typename: Cardano.CertificateType.StakeDelegation,
                    poolId: 'pool2'
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
        expect(stakePoolSearchProvider).toBeCalledTimes(1);
        expect(stakePoolSearchProvider).toBeCalledWith(['pool1', 'pool2']);
      });
    });
  });
});
