import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '../../../src';

describe('Cardano.util.computeImplicitCoin', () => {
  it('sums registrations for deposit, withdrawals and deregistrations for input', async () => {
    const protocolParameters = { dRepDeposit: 5, poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
    const stakeCredential = {
      hash: Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };
    const stakeKeyDeposit = BigInt(protocolParameters.stakeKeyDeposit);
    const drepDeposit = BigInt(protocolParameters.dRepDeposit);
    const certificates: Cardano.Certificate[] = [
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential },
      { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential },
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential },
      {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(500),
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh')
      },
      {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
        anchor: null,
        dRepCredential: {} as Cardano.Credential,
        deposit: drepDeposit
      },
      {
        __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
        dRepCredential: {} as Cardano.Credential,
        deposit: drepDeposit
      },
      {
        __typename: Cardano.CertificateType.Registration,
        deposit: stakeKeyDeposit,
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.StakeRegistrationDelegation,
        deposit: stakeKeyDeposit,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.VoteRegistrationDelegation,
        dRep: {} as Cardano.DelegateRepresentative,
        deposit: stakeKeyDeposit,
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
        dRep: {} as Cardano.DelegateRepresentative,
        deposit: stakeKeyDeposit,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      },
      {
        __typename: Cardano.CertificateType.Unregistration,
        deposit: stakeKeyDeposit,
        stakeCredential
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 5n, stakeAddress: rewardAccount }];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals });
    expect(coin.deposit).toBe(2n + 2n + 5n + 2n + 2n + 2n + 2n);
    expect(coin.input).toBe(2n + 3n + 5n + 5n + 2n);
    expect(coin.withdrawals).toBe(5n);
  });
});
