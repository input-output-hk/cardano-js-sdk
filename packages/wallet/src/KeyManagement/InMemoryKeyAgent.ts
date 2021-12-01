import * as errors from './errors';
import {
  AccountKeyDerivationPath,
  Authenticate,
  Bip32PublicKey,
  HexBlob,
  KeyAgentType,
  SerializableKeyAgentData,
  SignBlobResult
} from './types';
import { CSL, Cardano } from '@cardano-sdk/core';
import { KeyAgentBase } from './KeyAgentBase';
import { emip3decrypt, emip3encrypt } from './emip3';
import { harden, joinMnemonicWords, mnemonicWordsToEntropy, validateMnemonic } from './util';

export interface InMemoryKeyAgentProps {
  networkId: Cardano.NetworkId;
  accountIndex: number;
  encryptedRootPrivateKey: Uint8Array;
  authenticate: Authenticate;
}

export interface FromBip39MnemonicWordsProps {
  networkId: Cardano.NetworkId;
  mnemonicWords: string[];
  authenticate: Authenticate;
  accountIndex?: number;
}

// eslint-disable-next-line max-len
// See https://github.com/Emurgo/yoroi-frontend/blob/aea5c9d69bfa091dfc3957dfefa0e9beccb5331c/packages/yoroi-extension/app/api/ada/lib/cardanoCrypto/cryptoWallet.js#L70-L76
const EMPTY_PASSWORD = Buffer.from('');

const getPassword = async (authenticate: Authenticate) => {
  try {
    return await authenticate();
  } catch {
    // TODO: create new error types for KeyAgent failures
    throw new Error('Failed to enter password');
  }
};

export class InMemoryKeyAgent extends KeyAgentBase {
  readonly #networkId: Cardano.NetworkId;
  readonly #accountIndex: number;
  readonly #encryptedRootPrivateKey: Uint8Array;
  readonly #authenticate: Authenticate;

  constructor({ networkId, accountIndex, encryptedRootPrivateKey, authenticate }: InMemoryKeyAgentProps) {
    super();
    this.#accountIndex = accountIndex;
    this.#networkId = networkId;
    this.#encryptedRootPrivateKey = encryptedRootPrivateKey;
    this.#authenticate = authenticate;
  }

  get __typename(): KeyAgentType {
    return KeyAgentType.InMemory;
  }

  get serializableData(): SerializableKeyAgentData {
    return {
      __typename: KeyAgentType.InMemory,
      accountIndex: this.#accountIndex,
      encryptedRootPrivateKeyBytes: [...this.#encryptedRootPrivateKey],
      networkId: this.networkId
    };
  }

  get extendedAccountPublicKey(): Promise<Bip32PublicKey> {
    return this.#deriveAccountPrivateKey().then((privateKey) =>
      Buffer.from(privateKey.to_public().as_bytes()).toString('hex')
    );
  }

  get networkId(): Cardano.NetworkId {
    return this.#networkId;
  }
  get accountIndex(): number {
    return this.#accountIndex;
  }

  get agentSpecificData() {
    // eslint-disable-next-line unicorn/no-useless-undefined
    return [...this.#encryptedRootPrivateKey];
  }

  async signBlob({ index, type }: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult> {
    const accountKey = await this.#deriveAccountPrivateKey();
    const signingKey = accountKey.derive(type).derive(index).to_raw_key();
    const signature = Cardano.Ed25519Signature(signingKey.sign(Buffer.from(blob, 'hex')).to_hex());
    const publicKey = Cardano.Ed25519PublicKey(Buffer.from(signingKey.to_public().as_bytes()).toString('hex'));
    return { publicKey, signature };
  }

  async derivePublicKey({ index, type }: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey> {
    const accountPrivateKey = await this.#deriveAccountPrivateKey();
    const cslPublicKey = accountPrivateKey.derive(type).derive(index).to_public().to_raw_key();
    return Cardano.Ed25519PublicKey(Buffer.from(cslPublicKey.as_bytes()).toString('hex'));
  }

  // To export mnemonic, get entropy by reversing this:
  // rootPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(entropy, EMPTY_PASSWORD);
  // eslint-disable-next-line max-len
  // https://github.com/Emurgo/cardano-serialization-lib/blob/f817a033ade7a2255591d7c6444fa4f9ffbcf061/rust/src/chain_crypto/derive.rs#L30-L38
  async exportPrivateKey(): Promise<Uint8Array> {
    const rootPrivateKey = await this.#decryptRootPrivateKey();
    return rootPrivateKey.as_bytes();
  }

  static async fromBip39MnemonicWords({
    networkId,
    authenticate,
    mnemonicWords,
    accountIndex = 0
  }: FromBip39MnemonicWordsProps): Promise<InMemoryKeyAgent> {
    const mnemonic = joinMnemonicWords(mnemonicWords);
    const validMnemonic = validateMnemonic(mnemonic);
    if (!validMnemonic) throw new errors.InvalidMnemonic();
    const entropy = Buffer.from(mnemonicWordsToEntropy(mnemonicWords), 'hex');
    const rootPrivateKey = CSL.Bip32PrivateKey.from_bip39_entropy(entropy, EMPTY_PASSWORD);
    const password = await getPassword(authenticate);
    const encryptedRootPrivateKey = await emip3encrypt(rootPrivateKey.as_bytes(), password);
    return new InMemoryKeyAgent({
      accountIndex,
      authenticate,
      encryptedRootPrivateKey,
      networkId
    });
  }

  async #deriveAccountPrivateKey() {
    const rootPrivateKey = await this.#decryptRootPrivateKey();
    return rootPrivateKey.derive(harden(1852)).derive(harden(1815)).derive(harden(this.accountIndex));
  }

  async #decryptRootPrivateKey() {
    const decryptedAccountKeyBytes = await emip3decrypt(
      this.#encryptedRootPrivateKey,
      await getPassword(this.#authenticate)
    );
    if (!decryptedAccountKeyBytes) {
      // TODO: create new error types for KeyAgent failures
      throw new Error('Failed to decrypt account key');
    }
    return CSL.Bip32PrivateKey.from_bytes(decryptedAccountKeyBytes);
  }
}
