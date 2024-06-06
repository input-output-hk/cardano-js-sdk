import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { lastStakeKeyCertOfType, transactionsWithCertificates } from '../../../src/index.js';

describe('transactionCertificates', () => {
  test('lastStakeKeyCertOfType', () => {
    const rewardAccount = Cardano.RewardAccount('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d');
    const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
    const stakeCredential = {
      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(stakeKeyHash),
      type: Cardano.CredentialType.KeyHash
    };

    const certificates = [
      [
        {
          __typename: Cardano.CertificateType.Registration,
          deposit: 2_000_000n,
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
          __typename: Cardano.CertificateType.Unregistration,
          deposit: 2_000_000n,
          stakeCredential: {
            hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
            type: Cardano.CredentialType.KeyHash
          }
        } as Cardano.Certificate)
      ]
    ];
    expect(lastStakeKeyCertOfType(certificates, [Cardano.CertificateType.Registration])).toBeFalsy();
    expect(lastStakeKeyCertOfType(certificates, [Cardano.CertificateType.Registration], rewardAccount)).toEqual(
      expect.objectContaining({ __typename: Cardano.CertificateType.Registration, deposit: 2_000_000n })
    );
    expect(lastStakeKeyCertOfType(certificates, [Cardano.CertificateType.Unregistration])).toEqual(
      expect.objectContaining({ __typename: Cardano.CertificateType.Unregistration, deposit: 2_000_000n })
    );
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
      } as Cardano.HydratedTx;
      const outgoing$ = cold('abc', {
        a: [],
        b: [{ body: { certificates: [{ __typename: Cardano.CertificateType.MIR }] } } as Cardano.HydratedTx],
        c: [{ body: {} } as Cardano.HydratedTx, tx]
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
