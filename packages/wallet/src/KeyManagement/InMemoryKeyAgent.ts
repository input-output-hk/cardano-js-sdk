import * as errors from './errors';
import {
  AccountKeyDerivationPath,
  GetPassword,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SignBlobResult,
  SignTransactionOptions
} from './types';
import { AuthenticationError } from './errors';
import { CSL, Cardano, util } from '@cardano-sdk/core';
import { KeyAgentBase } from './KeyAgentBase';
import { deriveAccountPrivateKey, joinMnemonicWords, mnemonicWordsToEntropy, validateMnemonic } from './util';
import { emip3decrypt, emip3encrypt } from './emip3';
import { ownSignatureKeyPaths } from './util';
import { TxInternals } from '../Transaction';
import { uniqBy } from 'lodash-es';

export interface InMemoryKeyAgentProps extends Omit<SerializableInMemoryKeyAgentData, '__typename'> {
  getPassword: GetPassword;
}

export interface FromBip39MnemonicWordsProps {
  networkId: Cardano.NetworkId;
  mnemonicWords: string[];
  mnemonic2ndFactorPassphrase?: Uint8Array;
  getPassword: GetPassword;
  accountIndex?: number;
}

const getPasswordRethrowTypedError = async (getPassword: GetPassword) => {
  try {
    return await getPassword();
  } catch (error) {
    throw new AuthenticationError('Failed to enter password', error);
  }
};

export class InMemoryKeyAgent extends KeyAgentBase {
  readonly #getPassword: GetPassword;

  constructor({ getPassword, ...serializableData }: InMemoryKeyAgentProps) {
    super({ ...serializableData, __typename: KeyAgentType.InMemory });
    this.#getPassword = getPassword;
  }

  async signBlob({ index, role: type }: AccountKeyDerivationPath, blob: Cardano.util.HexBlob): Promise<SignBlobResult> {
    const rootPrivateKey = await this.#decryptRootPrivateKey();
    const accountKey = deriveAccountPrivateKey(rootPrivateKey, this.accountIndex);
    const signingKey = accountKey.derive(type).derive(index).to_raw_key();
    const signature = Cardano.Ed25519Signature(signingKey.sign(Buffer.from(blob, 'hex')).to_hex());
    const publicKey = Cardano.Ed25519PublicKey.fromHexBlob(util.bytesToHex(signingKey.to_public().as_bytes()));
    return { publicKey, signature };
  }

  // To export mnemonic, get entropy by reversing this:
  // rootPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(entropy, EMPTY_PASSWORD);
  // eslint-disable-next-line max-len
  // https://github.com/Emurgo/cardano-serialization-lib/blob/f817a033ade7a2255591d7c6444fa4f9ffbcf061/rust/src/chain_crypto/derive.rs#L30-L38
  async exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey> {
    const rootPrivateKey = await this.#decryptRootPrivateKey(true);
    return Cardano.Bip32PrivateKey.fromHexBlob(util.bytesToHex(rootPrivateKey.as_bytes()));
  }

  /**
   * @throws AuthenticationError
   */
  static async fromBip39MnemonicWords({
    networkId,
    getPassword,
    mnemonicWords,
    mnemonic2ndFactorPassphrase = Buffer.from(''),
    accountIndex = 0
  }: FromBip39MnemonicWordsProps): Promise<InMemoryKeyAgent> {
    const mnemonic = joinMnemonicWords(mnemonicWords);
    const validMnemonic = validateMnemonic(mnemonic);
    if (!validMnemonic) throw new errors.InvalidMnemonicError();
    const entropy = Buffer.from(mnemonicWordsToEntropy(mnemonicWords), 'hex');
    const rootPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(entropy, mnemonic2ndFactorPassphrase);
    const password = await getPasswordRethrowTypedError(getPassword);
    const encryptedRootPrivateKey = await emip3encrypt(rootPrivateKey.as_bytes(), password);
    const extendedAccountPublicKey = Cardano.Bip32PublicKey(
      Buffer.from(deriveAccountPrivateKey(rootPrivateKey, accountIndex).to_public().as_bytes()).toString('hex')
    );
    return new InMemoryKeyAgent({
      accountIndex,
      encryptedRootPrivateKeyBytes: [...encryptedRootPrivateKey],
      extendedAccountPublicKey,
      getPassword,
      knownAddresses: [],
      networkId
    });
  }

  async signTransaction(
    { body, hash }: TxInternals,
    { inputAddressResolver, additionalKeyPaths = [] }: SignTransactionOptions
  ): Promise<Cardano.Signatures> {
    // Possible optimization is casting strings to OpaqueString types directly and skipping validation
    const blob = Cardano.util.HexBlob(hash.toString());
    const derivationPaths = ownSignatureKeyPaths(body, this.knownAddresses, inputAddressResolver);
    const keyPaths = uniqBy([...derivationPaths, ...additionalKeyPaths], ({ role, index }) => `${role}.${index}`);
    // TODO:
    // if (keyPaths.length === 0) {
    //   throw new ProofGenerationError();
    // }
    return new Map<Cardano.Ed25519PublicKey, Cardano.Ed25519Signature>(
      await Promise.all(
        keyPaths.map(async ({ role, index }) => {
          const { publicKey, signature } = await this.signBlob({ index, role }, blob);
          return [publicKey, signature] as const;
        })
      )
    );
  }

  async #decryptRootPrivateKey(noCache?: true) {
    const password = await getPasswordRethrowTypedError(() => this.#getPassword(noCache));
    let decryptedRootKeyBytes: Uint8Array;
    try {
      decryptedRootKeyBytes = await emip3decrypt(
        new Uint8Array((this.serializableData as SerializableInMemoryKeyAgentData).encryptedRootPrivateKeyBytes),
        password
      );
    } catch (error) {
      throw new AuthenticationError('Failed to decrypt root private key', error);
    }
    return CSL.Bip32PrivateKey.from_bytes(decryptedRootKeyBytes);
  }
}
