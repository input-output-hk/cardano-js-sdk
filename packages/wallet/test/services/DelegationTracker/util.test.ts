import { Cardano } from '@cardano-sdk/core';
import { Transactions } from '../../../src/services';
import { certificateTransactions } from '../../../src/services/DelegationTracker/util';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler } from '../../testScheduler';

describe('DelegationTracker/util', () => {
  describe('certificateTransactions', () => {
    it('emits outgoing transactions containing given certificate types', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const transactions = [
          createStubTxWithCertificates([
            Cardano.CertificateType.PoolRetirement,
            Cardano.CertificateType.StakeDelegation
          ]),
          createStubTxWithCertificates([Cardano.CertificateType.GenesisKeyDelegation])
        ];
        const target$ = certificateTransactions(
          {
            history: {
              outgoing$: cold('a--a', {
                a: transactions
              })
            }
          } as unknown as Transactions,
          [Cardano.CertificateType.StakeDelegation]
        );
        expectObservable(target$).toBe('a--a', {
          a: [transactions[0]]
        });
      });
    });
  });
});
