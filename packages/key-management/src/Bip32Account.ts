import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  AsyncKeyAgent,
  GroupedAddress,
  KeyRole
} from './types';
import {
  BIP32_PUBLIC_KEY_HASH_LENGTH,
  Bip32Ed25519,
  Blake2b,
  Ed25519PublicKeyHex,
  SodiumBip32Ed25519,
  blake2b
} from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';

type Bip32AccountProps = {
  extendedAccountPublicKey: Crypto.Bip32PublicKeyHex;
  accountIndex: number;
  chainId: Cardano.ChainId;
};

export type Bip32AccountDependencies = {
  bip32Ed25519: Pick<Bip32Ed25519, 'derivePublicKeyAsync'>;
  blake2b: Pick<Blake2b, 'hashAsync'>;
};

/** Derives public keys and addresses from a BIP32-ED25519 public key */
export class Bip32Account {
  readonly extendedAccountPublicKeyHex: Crypto.Bip32PublicKeyHex;
  readonly chainId: Cardano.ChainId;
  readonly accountIndex: number;
  readonly #bip32Ed25519: Bip32AccountDependencies['bip32Ed25519'];
  readonly #blake2b: Bip32AccountDependencies['blake2b'];

  /** Initializes a new instance of the Bip32Ed25519AddressManager class. */
  constructor(
    { extendedAccountPublicKey, chainId, accountIndex }: Bip32AccountProps,
    dependencies: Bip32AccountDependencies
  ) {
    this.extendedAccountPublicKeyHex = extendedAccountPublicKey;
    this.#bip32Ed25519 = dependencies.bip32Ed25519;
    this.#blake2b = dependencies.blake2b;
    this.chainId = chainId;
    this.accountIndex = accountIndex;
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    const extendedKey = await this.#bip32Ed25519.derivePublicKeyAsync(this.extendedAccountPublicKeyHex, [
      derivationPath.role,
      derivationPath.index
    ]);
    return Ed25519PublicKeyHex.fromBip32PublicKey(extendedKey);
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

    const derivedPublicPaymentKeyHash = (await this.#blake2b.hashAsync(
      derivedPublicPaymentKey,
      BIP32_PUBLIC_KEY_HASH_LENGTH
    )) as Crypto.Hash28ByteBase16;

    const publicStakeKey = await this.derivePublicKey(stakeKeyDerivationPath);
    const publicStakeKeyHash = (await this.#blake2b.hashAsync(
      publicStakeKey,
      BIP32_PUBLIC_KEY_HASH_LENGTH
    )) as Crypto.Hash28ByteBase16;

    const stakeCredential = { hash: publicStakeKeyHash, type: Cardano.CredentialType.KeyHash };

    const address = Cardano.BaseAddress.fromCredentials(
      this.chainId.networkId,
      { hash: derivedPublicPaymentKeyHash, type: Cardano.CredentialType.KeyHash },
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

  static async createDefaultDependencies(): Promise<Bip32AccountDependencies> {
    return {
      bip32Ed25519: await SodiumBip32Ed25519.create(),
      blake2b
    };
  }

  /**
   * Creates a new instance of the Bip32Ed25519AddressManager class.
   *
   * @param keyAgent The key agent that will be used to derive addresses.
   * @param dependencies Optional dependencies for the Bip32Account. If not provided, default dependencies will be created.
   */
  static async fromAsyncKeyAgent(
    keyAgent: AsyncKeyAgent,
    dependencies?: Bip32AccountDependencies
  ): Promise<Bip32Account> {
    dependencies ||= await Bip32Account.createDefaultDependencies();
    return new Bip32Account(
      {
        accountIndex: await keyAgent.getAccountIndex(),
        chainId: await keyAgent.getChainId(),
        extendedAccountPublicKey: await keyAgent.getExtendedAccountPublicKey()
      },
      dependencies
    );
  }
}
