import { Cardano } from '@cardano-sdk/core';
import {
  StakeKeyStatus,
  addressKeyStatuses,
  createDelegateeTracker,
  getStakePoolIdAtEpoch
} from '../../../src/services';
import { TxWithEpoch } from '../../../src/services/DelegationTracker/types';
import { createTestScheduler } from '../../testScheduler';
import { currentEpoch } from '../../mocks';

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
    expect(getStakePoolIdAtEpoch(transactions)(103)).toBe('pool1');
    expect(getStakePoolIdAtEpoch(transactions)(104)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(105)).toBeUndefined();
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
                  { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.StakeAddressCertificate
                ],
                epoch: epoch - 2
              },
              {
                certificates: [
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
