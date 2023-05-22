import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  GroupedAddress,
  KeyAgent,
  KeyAgentDependencies,
  KeyRole,
  SerializableKeyAgentData,
  SignBlobResult,
  SignTransactionOptions
} from './types';
import { Cardano } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';

export abstract class KeyAgentBase implements KeyAgent {
  readonly #serializableData: SerializableKeyAgentData;
  readonly #bip32Ed25519: Crypto.Bip32Ed25519;
  protected readonly inputResolver: Cardano.InputResolver;

  get knownAddresses(): GroupedAddress[] {
    return this.#serializableData.knownAddresses;
  }
  set knownAddresses(addresses: GroupedAddress[]) {
    this.#serializableData.knownAddresses = addresses;
  }
  get serializableData(): SerializableKeyAgentData {
    return this.#serializableData;
  }
  get extendedAccountPublicKey(): Crypto.Bip32PublicKeyHex {
    return this.serializableData.extendedAccountPublicKey;
  }
  get chainId(): Cardano.ChainId {
    return this.serializableData.chainId;
  }
  get accountIndex(): number {
    return this.serializableData.accountIndex;
  }
  get bip32Ed25519(): Crypto.Bip32Ed25519 {
    return this.#bip32Ed25519;
  }

  abstract signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  abstract exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex>;
  abstract signTransaction(
    txInternals: Cardano.TxBodyWithHash,
    signTransactionOptions?: SignTransactionOptions
  ): Promise<Cardano.Signatures>;

  constructor(serializableData: SerializableKeyAgentData, { inputResolver, bip32Ed25519 }: KeyAgentDependencies) {
    this.#serializableData = serializableData;
    this.inputResolver = inputResolver;
    this.#bip32Ed25519 = bip32Ed25519;
  }

  /**
   * See https://github.com/cardano-foundation/CIPs/tree/master/CIP-1852#specification
   */
  async deriveAddress(
    { index, type }: AccountAddressDerivationPath,
    stakeKeyDerivationIndex: number,
    pure?: boolean
  ): Promise<GroupedAddress> {
    const stakeKeyDerivationPath = {
      index: stakeKeyDerivationIndex,
      role: KeyRole.Stake
    };

    const knownAddress = this.knownAddresses.find(
      (addr) =>
        addr.type === type &&
        addr.index === index &&
        addr.stakeKeyDerivationPath?.index === stakeKeyDerivationPath.index
    );

    if (knownAddress) return knownAddress;
    const derivedPublicPaymentKey = await this.derivePublicKey({
      index,
      role: type as unknown as KeyRole
    });

    const derivedPublicPaymentKeyHash = await this.#bip32Ed25519.getPubKeyHash(derivedPublicPaymentKey);

    const publicStakeKey = await this.derivePublicKey(stakeKeyDerivationPath);
    const publicStakeKeyHash = await this.#bip32Ed25519.getPubKeyHash(publicStakeKey);

    const stakeCredential = { hash: Hash28ByteBase16(publicStakeKeyHash), type: Cardano.CredentialType.KeyHash };

    const address = Cardano.BaseAddress.fromCredentials(
      this.chainId.networkId,
      { hash: Hash28ByteBase16(derivedPublicPaymentKeyHash), type: Cardano.CredentialType.KeyHash },
      stakeCredential
    ).toAddress();

    const rewardAccount = Cardano.RewardAddress.fromCredentials(this.chainId.networkId, stakeCredential).toAddress();

    const groupedAddress = {
      accountIndex: this.accountIndex,
      address: Cardano.PaymentAddress(address.toBech32()),
      index,
      networkId: this.chainId.networkId,
      rewardAccount: Cardano.RewardAccount(rewardAccount.toBech32()),
      stakeKeyDerivationPath,
      type
    };

    if (!pure) this.knownAddresses = [...this.knownAddresses, groupedAddress];

    return groupedAddress;
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    const childKey = await this.#bip32Ed25519.derivePublicKey(this.extendedAccountPublicKey, [
      derivationPath.role,
      derivationPath.index
    ]);

    return await this.#bip32Ed25519.getRawPublicKey(childKey);
  }
}
