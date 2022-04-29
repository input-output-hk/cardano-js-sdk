import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler } from '../../testScheduler';
import { isLastStakeKeyCertOfType, stakeKeyCertficates, transactionsWithCertificates } from '../../../src';

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

  test('isLastStakeKeyCertOfType', () => {
    const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
    const stakeKeyHash = Cardano.Ed25519KeyHash.fromRewardAccount(rewardAccount);
    const certificates = [
      [
        {
          __typename: Cardano.CertificateType.StakeKeyRegistration,
          stakeKeyHash
        } as Cardano.Certificate,
        { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate
      ],
      [
        ({ __typename: Cardano.CertificateType.PoolRegistration } as Cardano.Certificate,
        { __typename: Cardano.CertificateType.StakeKeyDeregistration } as Cardano.Certificate)
      ]
    ];
    expect(isLastStakeKeyCertOfType(certificates, Cardano.CertificateType.StakeKeyRegistration)).toBe(false);
    expect(isLastStakeKeyCertOfType(certificates, Cardano.CertificateType.StakeKeyRegistration, rewardAccount)).toBe(
      true
    );
    expect(isLastStakeKeyCertOfType(certificates, Cardano.CertificateType.StakeKeyDeregistration)).toBe(true);
  });

  test('outgoingTransactionsWithCertificates', () => {
    createTestScheduler().run(({ cold, expectObservable }) => {
      const rewardAccount = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');
      const tx = {
        body: {
          certificates: [
            {
              __typename: Cardano.CertificateType.PoolRegistration,
              poolParameters: {
                rewardAccount
              }
            } as Cardano.Certificate
          ]
        }
      } as Cardano.TxAlonzo;
      const outgoing$ = cold('abc', {
        a: [],
        b: [{ body: { certificates: [{ __typename: Cardano.CertificateType.MIR }] } } as Cardano.TxAlonzo],
        c: [{ body: {} } as Cardano.TxAlonzo, tx]
      });
      const rewardAccounts$ = cold('a', {
        a: [rewardAccount]
      });
      expectObservable(
        transactionsWithCertificates(outgoing$, rewardAccounts$, [Cardano.CertificateType.PoolRegistration])
      ).toBe('a-b', {
        a: [],
        b: [tx]
      });
    });
  });
});
