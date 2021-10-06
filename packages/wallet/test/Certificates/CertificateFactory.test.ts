import { loadCardanoSerializationLib } from '@cardano-sdk/core';
import { testKeyManager } from '../testKeyManager';
import { CertificateFactory } from '../../src/Delegation';

describe('Delegation.CertificateFactory', () => {
  it('uses stake key from KeyManager', async () => {
    const csl = await loadCardanoSerializationLib();
    const delegatee = 'pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt';
    const keyManager = testKeyManager(csl);
    const stakeKey = keyManager.stakeKey.hash().to_bech32('ed25519_pk');
    const certs = new CertificateFactory(csl, keyManager);
    expect(
      certs.stakeKeyRegistration().as_stake_registration()?.stake_credential().to_keyhash()?.to_bech32('ed25519_pk')
    ).toBe(stakeKey);
    expect(
      certs.stakeKeyDeregistration().as_stake_deregistration()?.stake_credential().to_keyhash()?.to_bech32('ed25519_pk')
    ).toBe(stakeKey);
    const delegation = certs.stakeDelegation(delegatee).as_stake_delegation()!;
    expect(delegation.stake_credential().to_keyhash()?.to_bech32('ed25519_pk')).toBe(stakeKey);
    expect(delegation.pool_keyhash().to_bech32('pool')).toBe(delegatee);
  });
});
