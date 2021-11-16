import { Cardano } from '@cardano-sdk/core';
import {
  TransactionsTracker,
  isLastStakeKeyCertOfType,
  outgoingTransactionsWithCertificates,
  transactionHasAnyCertificate,
  transactionStakeKeyCertficates
} from '../../../src';
import { createTestScheduler } from '../../testScheduler';

describe('transactionCertificates', () => {
  test('transactionStakeKeyCertficates', () => {
    const certificates = transactionStakeKeyCertficates({
      certificates: [
        { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate,
        { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.Certificate,
        { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.Certificate
      ]
    } as Cardano.TxBodyAlonzo);
    expect(certificates).toHaveLength(2);
    expect(certificates[0].__typename).toBe(Cardano.CertificateType.StakeKeyRegistration);
    expect(certificates[1].__typename).toBe(Cardano.CertificateType.StakeKeyDeregistration);
  });

  test('transactionHasAnyCertificate', () => {
    const tx = {
      body: {
        certificates: [
          { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.Certificate,
          { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate
        ]
      }
    } as Cardano.TxAlonzo;
    expect(
      transactionHasAnyCertificate(tx, [
        Cardano.CertificateType.StakeKeyDeregistration,
        Cardano.CertificateType.StakeDelegation
      ])
    ).toBe(true);
    expect(
      transactionHasAnyCertificate(tx, [
        Cardano.CertificateType.StakeKeyDeregistration,
        Cardano.CertificateType.PoolRegistration
      ])
    ).toBe(false);
  });

  test('isLastStakeKeyCertOfType', () => {
    const address = 'stake...';
    const transactions = [
      {
        body: {
          certificates: [
            { __typename: Cardano.CertificateType.StakeKeyRegistration, address } as Cardano.Certificate,
            { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate
          ]
        }
      } as Cardano.TxAlonzo,
      {
        body: {
          certificates: [
            { __typename: Cardano.CertificateType.PoolRegistration } as Cardano.Certificate,
            { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.Certificate
          ]
        }
      } as Cardano.TxAlonzo
    ];
    expect(isLastStakeKeyCertOfType(transactions, Cardano.CertificateType.StakeKeyRegistration)).toBe(false);
    expect(isLastStakeKeyCertOfType(transactions, Cardano.CertificateType.StakeKeyRegistration, address)).toBe(true);
    expect(isLastStakeKeyCertOfType(transactions, Cardano.CertificateType.StakeKeyDeregistration)).toBe(true);
  });

  test('outgoingTransactionsWithCertificates', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const tx = {
        body: {
          certificates: [{ __typename: Cardano.CertificateType.PoolRegistration } as Cardano.Certificate]
        }
      } as Cardano.TxAlonzo;
      const outgoing$ = cold('abc', {
        a: [],
        b: [{ body: { certificates: [{ __typename: Cardano.CertificateType.MIR }] } }],
        c: [{ body: {} } as Cardano.TxAlonzo, tx]
      });
      const txTracker = { history: { outgoing$ } } as unknown as TransactionsTracker;
      expectObservable(
        outgoingTransactionsWithCertificates(txTracker, [Cardano.CertificateType.PoolRegistration])
      ).toBe('a-b', {
        a: [],
        b: [tx]
      });
    });
  });
});
