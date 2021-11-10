import { Cardano } from '@cardano-sdk/core';
import { createDelegateeTracker, getStakePoolIdAtEpoch } from '../../../src/services';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';
import { currentEpoch } from '../../mocks';

describe('Delegatee', () => {
  test('getStakePoolIdAtEpoch ', () => {
    const transactions = [
      { epoch: 100, tx: createStubTxWithCertificates([Cardano.CertificateType.StakeRegistration]) },
      {
        epoch: 101,
        tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation], { poolId: 'pool1' })
      },
      { epoch: 102, tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDeregistration]) },
      {
        epoch: 103,
        tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation], { poolId: 'pool2' })
      }
    ];
    expect(getStakePoolIdAtEpoch(transactions)(102)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(103)).toBe('pool1');
    expect(getStakePoolIdAtEpoch(transactions)(104)).toBeUndefined();
    expect(getStakePoolIdAtEpoch(transactions)(105)).toBeUndefined();
  });

  describe('createDelegationTracker', () => {
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
              { epoch: epoch - 2, tx: createStubTxWithCertificates([Cardano.CertificateType.StakeRegistration]) },
              {
                epoch: epoch - 2,
                tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation], { poolId: 'pool1' })
              },
              {
                epoch: epoch - 1,
                tx: createStubTxWithCertificates([Cardano.CertificateType.StakeDelegation], { poolId: 'pool2' })
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
