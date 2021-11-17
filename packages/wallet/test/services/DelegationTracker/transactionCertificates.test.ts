import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler } from '../../testScheduler';
import {
  isLastStakeKeyCertOfType,
  stakeKeyCertficates,
  transactionHasAnyCertificate,
  transactionsWithCertificates
} from '../../../src';

describe('transactionCertificates', () => {
  test('transactionStakeKeyCertficates', () => {
    const certificates = stakeKeyCertficates([
      { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeKeyRegistration } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.Certificate
    ]);
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
    const certificates = [
      [
        { __typename: Cardano.CertificateType.StakeKeyRegistration, address } as Cardano.Certificate,
        { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate
      ],
      [
        ({ __typename: Cardano.CertificateType.PoolRegistration } as Cardano.Certificate,
        { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.Certificate)
      ]
    ];
    expect(isLastStakeKeyCertOfType(certificates, Cardano.CertificateType.StakeKeyRegistration)).toBe(false);
    expect(isLastStakeKeyCertOfType(certificates, Cardano.CertificateType.StakeKeyRegistration, address)).toBe(true);
    expect(isLastStakeKeyCertOfType(certificates, Cardano.CertificateType.StakeKeyDeregistration)).toBe(true);
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
        b: [{ body: { certificates: [{ __typename: Cardano.CertificateType.MIR }] } } as Cardano.TxAlonzo],
        c: [{ body: {} } as Cardano.TxAlonzo, tx]
      });
      expectObservable(transactionsWithCertificates(outgoing$, [Cardano.CertificateType.PoolRegistration])).toBe(
        'a-b',
        {
          a: [],
          b: [tx]
        }
      );
    });
  });
});
