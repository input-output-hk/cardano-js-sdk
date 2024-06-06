import * as Crypto from '@cardano-sdk/crypto';
import * as errors from './errors/index.js';
import {
  DREP_KEY_DERIVATION_PATH,
  deriveAccountPrivateKey,
  harden,
  joinMnemonicWords,
  mnemonicWordsToEntropy,
  ownSignatureKeyPaths,
  validateMnemonic
} from './util/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { KeyAgentBase } from './KeyAgentBase.js';
import { KeyAgentType } from './types.js';
import { emip3decrypt, emip3encrypt } from './emip3.js';
import uniqBy from 'lodash/uniqBy.js';
import type {
  AccountKeyDerivationPath,
  GetPassphrase,
  KeyAgent,
  KeyAgentDependencies,
  KeyPair,
  SerializableInMemoryKeyAgentData,
  SignBlobResult,
  SignTransactionContext,
  SignTransactionOptions
} from './types.js';
import type { Cardano } from '@cardano-sdk/core';

export interface InMemoryKeyAgentProps extends Omit<SerializableInMemoryKeyAgentData, '__typename'> {
  getPassphrase: GetPassphrase;
}

export interface FromBip39MnemonicWordsProps {
  chainId: Cardano.ChainId;
  mnemonicWords: string[];
  mnemonic2ndFactorPassphrase?: string;
  getPassphrase: GetPassphrase;
  accountIndex?: number;
}

const getPassphraseRethrowTypedError = async (getPassphrase: GetPassphrase) => {
  try {
    return await getPassphrase();
  } catch (error) {
    throw new errors.AuthenticationError('Failed to enter passphrase', error);
  }
};

export class InMemoryKeyAgent extends KeyAgentBase implements KeyAgent {
  readonly #getPassphrase: GetPassphrase;

  constructor({ getPassphrase, ...serializableData }: InMemoryKeyAgentProps, dependencies: KeyAgentDependencies) {
    super({ ...serializableData, __typename: KeyAgentType.InMemory }, dependencies);
    this.#getPassphrase = getPassphrase;
  }

  async signBlob({ index, role: type }: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult> {
    const rootPrivateKey = await this.#decryptRootPrivateKey();
    const accountKey = await deriveAccountPrivateKey({
      accountIndex: this.accountIndex,
      bip32Ed25519: this.bip32Ed25519,
      rootPrivateKey
    });

    const bip32SigningKey = await this.bip32Ed25519.derivePrivateKey(accountKey, [type, index]);
    const signingKey = await this.bip32Ed25519.getRawPrivateKey(bip32SigningKey);
    const signature = await this.bip32Ed25519.sign(signingKey, blob);
    const publicKey = await this.bip32Ed25519.getPublicKey(signingKey);

    return { publicKey, signature };
  }

  // To export mnemonic, get entropy by reversing this:

  // rootPrivateKey = CML.Bip32PrivateKey.from_bip39_entropy(entropy, EMPTY_PASSPHRASE);
  // eslint-disable-next-line max-len
  // https://github.com/Emurgo/cardano-serialization-lib/blob/f817a033ade7a2255591d7c6444fa4f9ffbcf061/rust/src/chain_crypto/derive.rs#L30-L38
  async exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    return await this.#decryptRootPrivateKey(true);
  }

  /**
   * @throws AuthenticationError
   */
  static async fromBip39MnemonicWords(
    {
      chainId,
      getPassphrase,
      mnemonicWords,
      mnemonic2ndFactorPassphrase = '',
      accountIndex = 0
    }: FromBip39MnemonicWordsProps,
    dependencies: KeyAgentDependencies
  ): Promise<InMemoryKeyAgent> {
    const mnemonic = joinMnemonicWords(mnemonicWords);
    const validMnemonic = validateMnemonic(mnemonic);
    if (!validMnemonic) throw new errors.InvalidMnemonicError();
    const entropy = Buffer.from(mnemonicWordsToEntropy(mnemonicWords), 'hex');
    const rootPrivateKey = await dependencies.bip32Ed25519.fromBip39Entropy(entropy, mnemonic2ndFactorPassphrase);
    const passphrase = await getPassphraseRethrowTypedError(getPassphrase);
    const encryptedRootPrivateKey = await emip3encrypt(Buffer.from(rootPrivateKey, 'hex'), passphrase);
    const accountPrivateKey = await deriveAccountPrivateKey({
      accountIndex,
      bip32Ed25519: dependencies.bip32Ed25519,
      rootPrivateKey
    });

    const extendedAccountPublicKey = await dependencies.bip32Ed25519.getBip32PublicKey(accountPrivateKey);

    return new InMemoryKeyAgent(
      {
        accountIndex,
        chainId,
        encryptedRootPrivateKeyBytes: [...encryptedRootPrivateKey],
        extendedAccountPublicKey,
        getPassphrase
      },
      dependencies
    );
  }

  async signTransaction(
    { body, hash }: Cardano.TxBodyWithHash,
    { txInKeyPathMap, knownAddresses }: SignTransactionContext,
    { additionalKeyPaths = [] }: SignTransactionOptions = {}
  ): Promise<Cardano.Signatures> {
    // Possible optimization is casting strings to OpaqueString types directly and skipping validation
    const blob = HexBlob(hash);
    const dRepKeyHash = (
      await Crypto.Ed25519PublicKey.fromHex(await this.derivePublicKey(DREP_KEY_DERIVATION_PATH)).hash()
    ).hex();
    const derivationPaths = ownSignatureKeyPaths(body, knownAddresses, txInKeyPathMap, dRepKeyHash);
    const keyPaths = uniqBy([...derivationPaths, ...additionalKeyPaths], ({ role, index }) => `${role}.${index}`);
    // TODO:
    // if (keyPaths.length === 0) {
    //   throw new ProofGenerationError();
    // }
    return new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>(
      await Promise.all(
        keyPaths.map(async ({ role, index }) => {
          const { publicKey, signature } = await this.signBlob({ index, role }, blob);
          return [publicKey, signature] as const;
        })
      )
    );
  }

  /** Based on root private key */
  async exportExtendedKeyPair(derivationPath: number[]): Promise<KeyPair> {
    const rootPrivateKey = await this.exportRootPrivateKey();
    const hardenedIndices = derivationPath.map((index: number) => harden(index));
    const childKey = await this.bip32Ed25519.derivePrivateKey(rootPrivateKey, hardenedIndices);

    return {
      skey: childKey,
      vkey: await this.bip32Ed25519.getBip32PublicKey(childKey)
    };
  }

  async #decryptRootPrivateKey(noCache?: true) {
    const passphrase = await getPassphraseRethrowTypedError(() => this.#getPassphrase(noCache));
    let decryptedRootKeyBytes: Uint8Array;

    try {
      decryptedRootKeyBytes = await emip3decrypt(
        new Uint8Array((this.serializableData as SerializableInMemoryKeyAgentData).encryptedRootPrivateKeyBytes),
        passphrase
      );
    } catch (error) {
      throw new errors.AuthenticationError('Failed to decrypt root private key', error);
    }
    return Crypto.Bip32PrivateKeyHex(Buffer.from(decryptedRootKeyBytes).toString('hex'));
  }
}
