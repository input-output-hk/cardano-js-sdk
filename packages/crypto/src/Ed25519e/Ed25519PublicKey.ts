import { ED25519_PUBLIC_KEY_HASH_LENGTH, Ed25519KeyHash } from './Ed25519KeyHash';
import { Ed25519PublicKeyHex } from '../hexTypes';
import { Ed25519Signature } from './Ed25519Signature';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import sodium from 'libsodium-wrappers-sumo';

export const ED25519_PUBLIC_KEY_LENGTH = 32;

/**
 * Ed25519 raw public key. This key can be used for cryptographically verifying messages
 * previously signed with the matching Ed25519 raw private key.
 */
export class Ed25519PublicKey {
  readonly #keyMaterial: Uint8Array;

  /**
   * Initializes a new instance of the Ed25519PublicKey class.
   *
   * @param keyMaterial The key Ed25519 Public key material.
   */
  constructor(keyMaterial: Uint8Array) {
    this.#keyMaterial = keyMaterial;
  }

  /**
   * Verifies that the passed-in signature was generated with a private key that matches
   * the given public key.
   *
   * @param signature The signature bytes to be verified.
   * @param message The original message the signature was computed from.
   * @returns true if the signature is valid; otherwise; false.
   */
  async verify(signature: Ed25519Signature, message: HexBlob): Promise<boolean> {
    await sodium.ready;
    return sodium.crypto_sign_verify_detached(signature.bytes(), Buffer.from(message, 'hex'), this.#keyMaterial);
  }

  /**
   * Initializes a new Ed25519PublicKey from its key material provided as a byte array.
   *
   * @param keyMaterial The key material.
   */
  static fromBytes(keyMaterial: Uint8Array) {
    if (keyMaterial.length !== ED25519_PUBLIC_KEY_LENGTH)
      throw new InvalidArgumentError(
        'keyMaterial',
        `Key should be ${ED25519_PUBLIC_KEY_LENGTH} bytes; however ${keyMaterial.length} bytes were provided.`
      );
    return new Ed25519PublicKey(keyMaterial);
  }

  /**
   * Initializes a new Ed25519PublicKey from its key material provided as a hex string.
   *
   * @param keyMaterial The key material as a hex string.
   */
  static fromHex(keyMaterial: Ed25519PublicKeyHex) {
    return Ed25519PublicKey.fromBytes(Buffer.from(keyMaterial, 'hex'));
  }

  /** Gets the blake2 hash of the key material. */
  async hash(): Promise<Ed25519KeyHash> {
    await sodium.ready;
    const hash = sodium.crypto_generichash(ED25519_PUBLIC_KEY_HASH_LENGTH, this.#keyMaterial);
    return Ed25519KeyHash.fromBytes(hash);
  }

  /** Gets the Ed25519PublicKey key material as a byte array. */
  bytes(): Uint8Array {
    return this.#keyMaterial;
  }

  /** Gets the Ed25519PublicKey key material as a hex string. */
  hex(): Ed25519PublicKeyHex {
    return Ed25519PublicKeyHex(Buffer.from(this.#keyMaterial).toString('hex'));
  }
}
