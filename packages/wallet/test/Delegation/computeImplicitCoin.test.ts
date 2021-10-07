import { loadCardanoSerializationLib, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { testKeyManager } from '../testKeyManager';
import { Delegation, InitializeTxProps } from '../../src';

describe('Delegation.computeImplicitCoin', () => {
  it('computes correctly', async () => {
    const protocolParameters = { stakeKeyDeposit: 2, poolDeposit: 3 } as ProtocolParametersRequiredByWallet;
    const csl = await loadCardanoSerializationLib();
    const keyManager = testKeyManager(csl);
    const certs = new Delegation.CertificateFactory(csl, keyManager);
    const certificates = [
      certs.stakeKeyRegistration(),
      certs.stakeKeyDeregistration(),
      certs.stakeKeyRegistration(),
      certs.poolRetirement(keyManager.stakeKey.hash().to_bech32('key'), 1000),
      certs.stakeDelegation('pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt')
    ];
    const withdrawals = [Delegation.withdrawal(csl, keyManager, 5)];
    const txProps = { certificates, withdrawals } as unknown as InitializeTxProps;

    const coin = Delegation.computeImplicitCoin(protocolParameters, txProps);
    expect(coin.deposit).toBe(2 + 2);
    expect(coin.input).toBe(2 + 3 + 5);
  });
});
