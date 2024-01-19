import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { isLastStakeKeyCertOfType, stakeKeyCertificates, transactionsWithCertificates } from '../../../src';

describe('transactionCertificates', () => {
  test('transactionStakeKeyCertficates', () => {
    const certificates = stakeKeyCertificates([
      { __typename: Cardano.CertificateType.StakeDelegation } as Cardano.Certificate, // does not register stake key
      { __typename: Cardano.CertificateType.StakeRegistration } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeDeregistration } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeVoteDelegation } as Cardano.Certificate, // does not register stake key
      { __typename: Cardano.CertificateType.StakeRegistrationDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.StakeVoteDelegation } as Cardano.Certificate, // does not register stake key
      { __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.VoteRegistrationDelegation } as Cardano.Certificate,
      { __typename: Cardano.CertificateType.Registration } as Cardano.Certificate
    ]);
    expect(certificates).toHaveLength(6);
    expect(certificates[0].__typename).toBe(Cardano.CertificateType.StakeRegistration);
    expect(certificates[1].__typename).toBe(Cardano.CertificateType.StakeDeregistration);
  });

  test('isLastStakeKeyCertOfType', () => {
    const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
    const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
    const stakeCredential = {
      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
      type: Cardano.CredentialType.KeyHash
    };

    const certificates = [
      [
        {
          __typename: Cardano.CertificateType.StakeRegistration,
          stakeCredential
        } as Cardano.Certificate,
        {
          __typename: Cardano.CertificateType.StakeDelegation,
          stakeCredential
        } as Cardano.Certificate
      ],
      [
        ({ __typename: Cardano.CertificateType.PoolRegistration } as Cardano.Certificate,
        {
          __typename: Cardano.CertificateType.StakeDeregistration,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
            type: Cardano.CredentialType.KeyHash
          }
        } as Cardano.Certificate)
      ]
    ];
    expect(isLastStakeKeyCertOfType(certificates, [Cardano.CertificateType.StakeRegistration])).toBe(false);
    expect(isLastStakeKeyCertOfType(certificates, [Cardano.CertificateType.StakeRegistration], rewardAccount)).toBe(
      true
    );
    expect(isLastStakeKeyCertOfType(certificates, [Cardano.CertificateType.StakeDeregistration])).toBe(true);
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
      } as Cardano.HydratedTx<Cardano.HydratedTxBodyPostConway>;
      const outgoing$ = cold('abc', {
        a: [],
        b: [
          {
            body: { certificates: [{ __typename: Cardano.CertificateType.MIR }] }
          } as Cardano.HydratedTx<Cardano.HydratedTxBodyPostConway>
        ],
        c: [{ body: {} } as Cardano.HydratedTx<Cardano.HydratedTxBodyPostConway>, tx]
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
