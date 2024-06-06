import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { KeyRole } from './types.js';
import type { AccountAddressDerivationPath, AccountKeyDerivationPath, AsyncKeyAgent, GroupedAddress } from './types.js';

type Bip32AccountProps = {
  extendedAccountPublicKey: Crypto.Bip32PublicKeyHex;
  accountIndex: number;
  chainId: Cardano.ChainId;
};

/** Derives public keys and addresses from a BIP32-ED25519 public key */
export class Bip32Account {
  readonly extendedAccountPublicKey: Crypto.Bip32PublicKey;
  readonly chainId: Cardano.ChainId;
  readonly accountIndex: number;

  /** Initializes a new instance of the Bip32Ed25519AddressManager class. */
  constructor({ extendedAccountPublicKey, chainId, accountIndex }: Bip32AccountProps) {
    this.extendedAccountPublicKey = Crypto.Bip32PublicKey.fromHex(extendedAccountPublicKey);
    this.chainId = chainId;
    this.accountIndex = accountIndex;
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath) {
    const key = await this.extendedAccountPublicKey.derive([derivationPath.role, derivationPath.index]);
    return key.toRawKey();
  }

  async deriveAddress(
    paymentKeyDerivationPath: AccountAddressDerivationPath,
    stakeKeyDerivationIndex: number
  ): Promise<GroupedAddress> {
    const stakeKeyDerivationPath = {
      index: stakeKeyDerivationIndex,
      role: KeyRole.Stake
    };

    const derivedPublicPaymentKey = await this.derivePublicKey({
      index: paymentKeyDerivationPath.index,
      role: Number(paymentKeyDerivationPath.type)
    });

    const derivedPublicPaymentKeyHash = await derivedPublicPaymentKey.hash();

    const publicStakeKey = await this.derivePublicKey(stakeKeyDerivationPath);
    const publicStakeKeyHash = await publicStakeKey.hash();

    const stakeCredential = { hash: Hash28ByteBase16(publicStakeKeyHash.hex()), type: Cardano.CredentialType.KeyHash };

    const address = Cardano.BaseAddress.fromCredentials(
      this.chainId.networkId,
      { hash: Hash28ByteBase16(derivedPublicPaymentKeyHash.hex()), type: Cardano.CredentialType.KeyHash },
      stakeCredential
    ).toAddress();

    const rewardAccount = Cardano.RewardAddress.fromCredentials(this.chainId.networkId, stakeCredential).toAddress();

    return {
      accountIndex: this.accountIndex,
      address: Cardano.PaymentAddress(address.toBech32()),
      networkId: this.chainId.networkId,
      rewardAccount: Cardano.RewardAccount(rewardAccount.toBech32()),
      stakeKeyDerivationPath,
      ...paymentKeyDerivationPath
    };
  }

  /**
   * Creates a new instance of the Bip32Ed25519AddressManager class.
   *
   * @param keyAgent The key agent that will be used to derive addresses.
   */
  static async fromAsyncKeyAgent(keyAgent: AsyncKeyAgent): Promise<Bip32Account> {
    return new Bip32Account({
      accountIndex: await keyAgent.getAccountIndex(),
      chainId: await keyAgent.getChainId(),
      extendedAccountPublicKey: await keyAgent.getExtendedAccountPublicKey()
    });
  }
}
