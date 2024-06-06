import { Ed25519KeyHashHex } from '../hexTypes.js';
import { InvalidArgumentError } from '@cardano-sdk/util';

export const ED25519_PUBLIC_KEY_HASH_LENGTH = 28;

/** The computed cryptographic hash of an Ed25519 Key with the Blake2b hashing algorithm. */
export class Ed25519KeyHash {
  readonly #hash: Uint8Array;

  /**
   * Initializes a new instance of the Ed25519KeyHash class.
   *
   * @param hash The ED25519 public key hash.
   */
  private constructor(hash: Uint8Array) {
    this.#hash = hash;
  }

  /**
   * Initializes a new Ed25519KeyHash provided as a byte array.
   *
   * @param hash The Ed25519 key hash.
   */
  static fromBytes(hash: Uint8Array) {
    if (hash.length !== ED25519_PUBLIC_KEY_HASH_LENGTH)
      throw new InvalidArgumentError(
        'hash',
        `Hash should be ${ED25519_PUBLIC_KEY_HASH_LENGTH} bytes; however ${hash.length} bytes were provided.`
      );
    return new Ed25519KeyHash(hash);
  }

  /**
   * Initializes a new instance of the Ed25519KeyHash class from its hash provided as a hex string.
   *
   * @param hash The hash as a hex string.
   */
  static fromHex(hash: Ed25519KeyHashHex) {
    return Ed25519KeyHash.fromBytes(Buffer.from(hash, 'hex'));
  }

  /** Gets the Ed25519KeyHash as a byte array. */
  bytes(): Uint8Array {
    return this.#hash;
  }

  /** Gets the Ed25519KeyHash as a hex string. */
  hex(): Ed25519KeyHashHex {
    return Ed25519KeyHashHex(Buffer.from(this.#hash).toString('hex'));
  }
}
