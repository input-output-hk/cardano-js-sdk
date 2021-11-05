import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { CertificateType } from '@cardano-sdk/core/src/Cardano';
import { InitializeTxProps, Transaction } from '../../src';

describe('Transaction.computeImplicitCoin', () => {
  it('sums registrations for deposit, withdrawals and deregistrations for input', async () => {
    const protocolParameters = { poolDeposit: 3, stakeKeyDeposit: 2 } as ProtocolParametersRequiredByWallet;
    const address = 'stake...';
    const certificates: Cardano.Certificate[] = [
      { __typename: CertificateType.StakeRegistration, address },
      { __typename: CertificateType.StakeDeregistration, address },
      { __typename: CertificateType.StakeRegistration, address },
      { __typename: CertificateType.PoolRetirement, epoch: 500, poolId: 'pool...' },
      { __typename: CertificateType.StakeDelegation, address, epoch: 500, poolId: 'pool...' }
    ];
    const withdrawals: Cardano.Withdrawal[] = [{ quantity: 5n, stakeAddress: address }];
    const txProps = { certificates, withdrawals } as InitializeTxProps;

    const coin = Transaction.computeImplicitCoin(protocolParameters, txProps);
    expect(coin.deposit).toBe(2n + 2n);
    expect(coin.input).toBe(2n + 3n + 5n);
  });
});
