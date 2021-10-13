import { loadCardanoSerializationLib, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { testKeyManager } from '../testKeyManager';
import { Transaction } from '../../src';
import { InitializeTxProps } from '../../src/Transaction';

describe('Transaction.computeImplicitCoin', () => {
  it('sums registrations for deposit, withdrawals and deregistrations for input', async () => {
    const protocolParameters = { stakeKeyDeposit: 2, poolDeposit: 3 } as ProtocolParametersRequiredByWallet;
    const csl = await loadCardanoSerializationLib();
    const keyManager = testKeyManager(csl);
    const certs = new Transaction.CertificateFactory(csl, keyManager);
    const certificates = [
      certs.stakeKeyRegistration(),
      certs.stakeKeyDeregistration(),
      certs.stakeKeyRegistration(),
      certs.poolRetirement(keyManager.stakeKey.hash().to_bech32('key'), 1000),
      certs.stakeDelegation('pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt')
    ];
    const withdrawals = [Transaction.withdrawal(csl, keyManager, 5n)];
    const txProps = { certificates, withdrawals } as unknown as InitializeTxProps;

    const coin = Transaction.computeImplicitCoin(protocolParameters, txProps);
    expect(coin.deposit).toBe(2n + 2n);
    expect(coin.input).toBe(2n + 3n + 5n);
  });
});
