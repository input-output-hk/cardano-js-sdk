import * as Bip32KeyDerivation from './Bip32KeyDerivation.js';
import { BIP32_PUBLIC_KEY_HASH_LENGTH, Bip32PublicKeyHashHex, Bip32PublicKeyHex } from '../hexTypes.js';
import { ED25519_PUBLIC_KEY_LENGTH, Ed25519PublicKey } from '../Ed25519e/index.js';
import { InvalidArgumentError } from '@cardano-sdk/util';
import { crypto_generichash, ready } from 'libsodium-wrappers-sumo';

export const BIP32_ED25519_PUBLIC_KEY_LENGTH = 64;

/** BIP32 public key. */
export class Bip32PublicKey {
  readonly #key: Uint8Array;

  /**
   * Initializes a new instance of the Bip32PublicKey class.
   *
   * @param key The BIP32 public key.
   */
  private constructor(key: Uint8Array) {
    this.#key = key;
  }

  /**
   * Initializes a new Bip32PublicKey provided as a byte array.
   *
   * @param key The BIP32 public key.
   */
  static fromBytes(key: Uint8Array): Bip32PublicKey {
    if (key.length !== BIP32_ED25519_PUBLIC_KEY_LENGTH)
      throw new InvalidArgumentError(
        'key',
        `Key should be ${BIP32_ED25519_PUBLIC_KEY_LENGTH} bytes; however ${key.length} bytes were provided.`
      );
    return new Bip32PublicKey(key);
  }

  /**
   * Initializes a new instance of the Bip32PublicKey class from its key material provided as a hex string.
   *
   * @param key The key as a hex string.
   */
  static fromHex(key: Bip32PublicKeyHex): Bip32PublicKey {
    return Bip32PublicKey.fromBytes(Buffer.from(key, 'hex'));
  }

  /**
   * Gets the Ed25519 raw public key. This key can be used for cryptographically verifying messages
   * previously signed with the matching Ed25519 raw private key.
   */
  toRawKey(): Ed25519PublicKey {
    return Ed25519PublicKey.fromBytes(this.#key.slice(0, ED25519_PUBLIC_KEY_LENGTH));
  }

  /**
   * Given a set of indices, this function computes the corresponding child extended key.
   *
   * @param derivationIndices The list of derivation indices.
   * @returns The child extended private key.
   */
  async derive(derivationIndices: number[]): Promise<Bip32PublicKey> {
    await ready;
    let key = Buffer.from(this.#key);

    for (const index of derivationIndices) {
      key = Bip32KeyDerivation.derivePublic(key, index);
    }

    return Bip32PublicKey.fromBytes(key);
  }

  /** Gets the Bip32PublicKey as a byte array. */
  bytes(): Uint8Array {
    return this.#key;
  }

  /** Gets the Bip32PublicKey as a hex string. */
  hex(): Bip32PublicKeyHex {
    return Bip32PublicKeyHex(Buffer.from(this.#key).toString('hex'));
  }

  /** Gets the blake2 hash of the key. */
  async hash(): Promise<Bip32PublicKeyHashHex> {
    await ready;
    const hash = crypto_generichash(BIP32_PUBLIC_KEY_HASH_LENGTH, this.#key);
    return Bip32PublicKeyHashHex(Buffer.from(hash).toString('hex'));
  }
}
