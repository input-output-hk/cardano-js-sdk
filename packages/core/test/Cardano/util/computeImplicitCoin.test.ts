import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '../../../src';

describe('Cardano.util.computeImplicitCoin', () => {
  it('sums registrations for deposit, withdrawals and deregistrations for input', async () => {
    const protocolParameters = { poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
    const stakeCredential = {
      hash: Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };
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
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 5n, stakeAddress: rewardAccount }];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals });
    expect(coin.deposit).toBe(2n + 2n);
    expect(coin.input).toBe(2n + 3n + 5n);
    expect(coin.withdrawals).toBe(5n);
    expect(coin.reclaimDeposit).toBe(5n);
  });

  it('sums registrations for deposit, withdrawals and deregistrations for input for own reward accounts when given reward accounts array', async () => {
    const protocolParameters = { poolDeposit: 3, stakeKeyDeposit: 2 } as Cardano.ProtocolParameters;
    const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
    const foreignRewardAccount = Cardano.RewardAccount(
      'stake_test17rphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcljw6kf'
    );

    const stakeCredential = {
      hash: Cardano.RewardAccount.toHash(rewardAccount) as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };
    const foreignStakeCredential = {
      hash: Cardano.RewardAccount.toHash(foreignRewardAccount) as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    };

    const certificates: Cardano.Certificate[] = [
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential },
      { __typename: Cardano.CertificateType.Registration, deposit: 10n, stakeCredential },
      { __typename: Cardano.CertificateType.Unregistration, deposit: 20n, stakeCredential },
      { __typename: Cardano.CertificateType.Unregistration, deposit: 100n, stakeCredential: foreignStakeCredential },
      { __typename: Cardano.CertificateType.StakeDeregistration, stakeCredential: foreignStakeCredential },
      { __typename: Cardano.CertificateType.StakeRegistration, stakeCredential: foreignStakeCredential },
      {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: Cardano.EpochNo(500),
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh')
      },
      {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        stakeCredential
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 10n, stakeAddress: rewardAccount }];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals }, [rewardAccount]);
    expect(coin.deposit).toBe(2n + 10n);
    expect(coin.reclaimDeposit).toBe(20n);
    expect(coin.input).toBe(10n + 20n);
    expect(coin.withdrawals).toBe(10n);
  });
});
