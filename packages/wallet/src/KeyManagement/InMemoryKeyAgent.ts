import * as errors from './errors';
import {
  AccountKeyDerivationPath,
  GetPassword,
  GroupedAddress,
  KeyAgentType,
  SerializableKeyAgentData,
  SignBlobResult
} from './types';
import { AuthenticationError } from './errors';
import { CSL, Cardano, util } from '@cardano-sdk/core';
import { KeyAgentBase } from './KeyAgentBase';
import { emip3decrypt, emip3encrypt } from './emip3';
import { harden, joinMnemonicWords, mnemonicWordsToEntropy, validateMnemonic } from './util';

export interface InMemoryKeyAgentProps {
  networkId: Cardano.NetworkId;
  accountIndex: number;
  knownAddresses: GroupedAddress[];
  encryptedRootPrivateKey: Uint8Array;
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
  readonly #networkId: Cardano.NetworkId;
  readonly #accountIndex: number;
  readonly #encryptedRootPrivateKey: Uint8Array;
  readonly #getPassword: GetPassword;
  readonly #knownAddresses: GroupedAddress[];

  constructor({
    networkId,
    accountIndex,
    encryptedRootPrivateKey,
    getPassword,
    knownAddresses
  }: InMemoryKeyAgentProps) {
    super();
    this.#accountIndex = accountIndex;
    this.#networkId = networkId;
    this.#encryptedRootPrivateKey = encryptedRootPrivateKey;
    this.#getPassword = getPassword;
    this.#knownAddresses = knownAddresses;
  }

  get __typename(): KeyAgentType {
    return KeyAgentType.InMemory;
  }

  get knownAddresses(): GroupedAddress[] {
    return this.#knownAddresses;
  }

  get serializableData(): SerializableKeyAgentData {
    return {
      __typename: KeyAgentType.InMemory,
      accountIndex: this.#accountIndex,
      encryptedRootPrivateKeyBytes: [...this.#encryptedRootPrivateKey],
      knownAddresses: this.#knownAddresses,
      networkId: this.networkId
    };
  }

  get networkId(): Cardano.NetworkId {
    return this.#networkId;
  }
  get accountIndex(): number {
    return this.#accountIndex;
  }

  async getExtendedAccountPublicKey(): Promise<Cardano.Bip32PublicKey> {
    const privateKey = await this.#deriveAccountPrivateKey();
    return Cardano.Bip32PublicKey.fromHexBlob(util.bytesToHex(privateKey.to_public().as_bytes()));
  }

  async signBlob({ index, type }: AccountKeyDerivationPath, blob: Cardano.util.HexBlob): Promise<SignBlobResult> {
    const accountKey = await this.#deriveAccountPrivateKey();
    const signingKey = accountKey.derive(type).derive(index).to_raw_key();
    const signature = Cardano.Ed25519Signature(signingKey.sign(Buffer.from(blob, 'hex')).to_hex());
    const publicKey = Cardano.Ed25519PublicKey.fromHexBlob(util.bytesToHex(signingKey.to_public().as_bytes()));
    return { publicKey, signature };
  }

  async derivePublicKey({ index, type }: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey> {
    const accountPrivateKey = await this.#deriveAccountPrivateKey();
    const cslPublicKey = accountPrivateKey.derive(type).derive(index).to_public().to_raw_key();
    return Cardano.Ed25519PublicKey.fromHexBlob(util.bytesToHex(cslPublicKey.as_bytes()));
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
    return new InMemoryKeyAgent({
      accountIndex,
      encryptedRootPrivateKey,
      getPassword,
      knownAddresses: [],
      networkId
    });
  }

  async #deriveAccountPrivateKey() {
    const rootPrivateKey = await this.#decryptRootPrivateKey();
    return rootPrivateKey.derive(harden(1852)).derive(harden(1815)).derive(harden(this.accountIndex));
  }

  async #decryptRootPrivateKey(noCache?: true) {
    const password = await getPasswordRethrowTypedError(() => this.#getPassword(noCache));
    let decryptedRootKeyBytes: Uint8Array;
    try {
      decryptedRootKeyBytes = await emip3decrypt(this.#encryptedRootPrivateKey, password);
    } catch (error) {
      throw new AuthenticationError('Failed to decrypt root private key', error);
    }
    return CSL.Bip32PrivateKey.from_bytes(decryptedRootKeyBytes);
  }
}
