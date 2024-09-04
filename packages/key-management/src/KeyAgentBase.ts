import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  GroupedAddress,
  KeyAgent,
  KeyAgentDependencies,
  KeyPurpose,
  SerializableKeyAgentData,
  SignBlobResult,
  SignTransactionContext,
  SignTransactionOptions
} from './types';
import { Bip32Account } from './Bip32Account';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { Cip8SignDataContext } from './cip8';
import { HexBlob } from '@cardano-sdk/util';

export abstract class KeyAgentBase implements KeyAgent {
  readonly #serializableData: SerializableKeyAgentData;
  readonly #bip32Ed25519: Crypto.Bip32Ed25519;
  readonly #account: Bip32Account;

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

  get purpose(): KeyPurpose {
    return this.serializableData.purpose || KeyPurpose.STANDARD;
  }

  abstract signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult>;
  abstract signCip8Data(context: Cip8SignDataContext): Promise<Cip30DataSignature>;
  abstract exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex>;
  abstract signTransaction(
    txBody: Serialization.TransactionBody,
    context: SignTransactionContext,
    signTransactionOptions?: SignTransactionOptions
  ): Promise<Cardano.Signatures>;

  constructor(serializableData: SerializableKeyAgentData, { bip32Ed25519 }: KeyAgentDependencies) {
    this.#serializableData = serializableData;
    this.#bip32Ed25519 = bip32Ed25519;
    this.#account = new Bip32Account(serializableData);
  }

  /** See https://github.com/cardano-foundation/CIPs/tree/master/CIP-1852#specification */
  async deriveAddress(
    paymentKeyDerivationPath: AccountAddressDerivationPath,
    stakeKeyDerivationIndex: number
  ): Promise<GroupedAddress> {
    return this.#account.deriveAddress(paymentKeyDerivationPath, stakeKeyDerivationIndex);
  }

  async derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    return (await this.#account.derivePublicKey(derivationPath)).hex();
  }
}
