import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';

describe('Cardano.util.computeImplicitCoin', () => {
  it('sums registrations for deposit, withdrawals and deregistrations for input', async () => {
    const protocolParameters = { poolDeposit: 3, stakeKeyDeposit: 2 } as ProtocolParametersRequiredByWallet;
    const rewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
    const certificates: Cardano.Certificate[] = [
      { __typename: Cardano.CertificateType.StakeKeyRegistration, rewardAccount },
      { __typename: Cardano.CertificateType.StakeKeyDeregistration, rewardAccount },
      { __typename: Cardano.CertificateType.StakeKeyRegistration, rewardAccount },
      {
        __typename: Cardano.CertificateType.PoolRetirement,
        epoch: 500,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh')
      },
      {
        __typename: Cardano.CertificateType.StakeDelegation,
        epoch: 500,
        poolId: Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
        rewardAccount
      }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 5n, stakeAddress: rewardAccount }];
    const coin = Cardano.util.computeImplicitCoin(protocolParameters, { certificates, withdrawals });
    expect(coin.deposit).toBe(2n + 2n);
    expect(coin.input).toBe(2n + 3n + 5n);
  });
});
