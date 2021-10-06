import { CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { KeyManager } from '../KeyManagement';

export type Bech32Key = string;

export class CertificateFactory {
  private readonly stakeCredential: CSL.StakeCredential;

  constructor(private csl: CardanoSerializationLib, keyManager: KeyManager) {
    // this.stakeCredential = csl.StakeCredential.from_keyhash(
    //   csl.Ed25519KeyHash.from_bech32(keyManager.stakeKey.to_bech32())
    // );
    this.stakeCredential = csl.StakeCredential.from_keyhash(keyManager.stakeKey.hash());
  }

  public stakeKeyRegistration() {
    return this.csl.Certificate.new_stake_registration(this.csl.StakeRegistration.new(this.stakeCredential));
  }

  public stakeKeyDeregistration() {
    return this.csl.Certificate.new_stake_deregistration(this.csl.StakeDeregistration.new(this.stakeCredential));
  }

  public stakeDelegation(delegatee: Bech32Key) {
    return this.csl.Certificate.new_stake_delegation(
      this.csl.StakeDelegation.new(this.stakeCredential, this.csl.Ed25519KeyHash.from_bech32(delegatee))
    );
  }
}
