/* eslint-disable  no-bitwise */
import { Ed25519PrivateExtendedKeyHex, Ed25519PrivateNormalKeyHex } from '../hexTypes';
import { Ed25519PublicKey } from './Ed25519PublicKey';
import { Ed25519Signature } from './Ed25519Signature';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import sodium from 'libsodium-wrappers-sumo';

const SCALAR_INDEX = 0;
const SCALAR_SIZE = 32;
const IV_INDEX = 32;
const IV_SIZE = 32;

export const NORMAL_ED25519_PRIVATE_KEY_LENGTH = 32;
export const EXTENDED_ED25519_PRIVATE_KEY_LENGTH = 64;

/**
 * Extract the scalar part (first 32 bytes) from the extended key.
 *
 * @param extendedKey The extended key.
 * @returns the scalar part of the extended key.
 */
const extendedScalar = (extendedKey: Uint8Array) => extendedKey.slice(SCALAR_INDEX, SCALAR_SIZE);

/**
 * Extract the random part (last 32 bytes) from the extended key to be used as IV for signing.
 *
 * @param extendedKey The extended key.
 * @returns the random part of the extended key.
 */
const extendedIv = (extendedKey: Uint8Array) => extendedKey.slice(IV_INDEX, IV_INDEX + IV_SIZE);

/**
 * Creates a detached Ed25519 digital signatures using libSodium elliptic curve primitives.
 *
 * @param extendedKey The extended secret.
 * @param message The message to be signed.
 */
const signExtendedDetached = (extendedKey: Uint8Array, message: Uint8Array) => {
  const scalar = extendedScalar(extendedKey);
  const publicKey = sodium.crypto_scalarmult_ed25519_base_noclamp(scalar);
  const nonce = sodium.crypto_core_ed25519_scalar_reduce(
    sodium.crypto_hash_sha512(Buffer.concat([extendedIv(extendedKey), message]))
  );

  const r = sodium.crypto_scalarmult_ed25519_base_noclamp(nonce);

  let hram = sodium.crypto_hash_sha512(Buffer.concat([r, publicKey, message]));
  hram = sodium.crypto_core_ed25519_scalar_reduce(hram);

  return Buffer.concat([
    r,
    sodium.crypto_core_ed25519_scalar_add(sodium.crypto_core_ed25519_scalar_mul(hram, scalar), nonce)
  ]);
};

/** Ed25519 private key type. */
export enum Ed25519PrivateKeyType {
  Normal = 'Normal',
  Extended = 'Extended'
}

/** Ed25519 raw private key. This key can be used for cryptographically signing messages. */
export class Ed25519PrivateKey {
  readonly #keyMaterial: Uint8Array;
  readonly __type: Ed25519PrivateKeyType;

  /**
   * Initializes a new instance of the Ed25519PrivateKey class.
   *
   * @param keyMaterial The key Ed25519 private key material.
   * @param type The ley type (Normal or Extended).
   */
  private constructor(keyMaterial: Uint8Array, type: Ed25519PrivateKeyType) {
    this.#keyMaterial = keyMaterial;
    this.__type = type;
  }

  /**
   * Computes the raw public key from this raw private key.
   *
   * @returns the public key.
   */
  async toPublic(): Promise<Ed25519PublicKey> {
    await sodium.ready;

    return Ed25519PublicKey.fromBytes(
      this.__type === Ed25519PrivateKeyType.Extended
        ? sodium.crypto_scalarmult_ed25519_base_noclamp(extendedScalar(this.#keyMaterial))
        : sodium.crypto_sign_seed_keypair(this.#keyMaterial).publicKey
    );
  }

  /**
   * Generates an Ed25519 signature.
   *
   * @param message The message to be signed.
   * @returns The Ed25519 digital signature.
   */
  async sign(message: HexBlob): Promise<Ed25519Signature> {
    await sodium.ready;
    return Ed25519Signature.fromBytes(
      this.__type === Ed25519PrivateKeyType.Extended
        ? signExtendedDetached(this.#keyMaterial, Buffer.from(message, 'hex'))
        : sodium.crypto_sign_detached(
            Buffer.from(message, 'hex'),
            Buffer.concat([this.#keyMaterial, (await this.toPublic()).bytes()])
          )
    );
  }

  /**
   * Initializes a new Normal Ed25519PrivateKey from its key material provided as a byte array.
   *
   * @param keyMaterial The key material.
   */
  static fromNormalBytes(keyMaterial: Uint8Array): Ed25519PrivateKey {
    if (keyMaterial.length !== NORMAL_ED25519_PRIVATE_KEY_LENGTH)
      throw new InvalidArgumentError(
        'keyMaterial',
        `Key should be ${NORMAL_ED25519_PRIVATE_KEY_LENGTH} bytes; however ${keyMaterial.length} bytes were provided.`
      );

    return new Ed25519PrivateKey(keyMaterial, Ed25519PrivateKeyType.Normal);
  }

  /**
   * Initializes a new Extended Ed25519PrivateKey from its key material provided as a byte array.
   *
   * @param keyMaterial The key material.
   */
  static fromExtendedBytes(keyMaterial: Uint8Array): Ed25519PrivateKey {
    if (keyMaterial.length !== EXTENDED_ED25519_PRIVATE_KEY_LENGTH)
      throw new InvalidArgumentError(
        'keyMaterial',
        `Key should be ${EXTENDED_ED25519_PRIVATE_KEY_LENGTH} bytes; however ${keyMaterial.length} bytes were provided.`
      );
    return new Ed25519PrivateKey(keyMaterial, Ed25519PrivateKeyType.Extended);
  }

  /**
   * Initializes a new Normal Ed25519PrivateKey from its key material provided as a hex string.
   *
   * @param keyMaterial The key material as a hex string.
   */
  static fromNormalHex(keyMaterial: Ed25519PrivateNormalKeyHex): Ed25519PrivateKey {
    return Ed25519PrivateKey.fromNormalBytes(Buffer.from(keyMaterial, 'hex'));
  }

  /**
   * Initializes a new Extended Ed25519PrivateKey from its key material provided as a hex string.
   *
   * @param keyMaterial The key material as a hex string.
   */
  static fromExtendedHex(keyMaterial: Ed25519PrivateExtendedKeyHex): Ed25519PrivateKey {
    return Ed25519PrivateKey.fromExtendedBytes(Buffer.from(keyMaterial, 'hex'));
  }

  /** Gets the Ed25519PrivateKey key material as a byte array. */
  bytes(): Uint8Array {
    return this.#keyMaterial;
  }

  /** Gets the Ed25519PrivateKey key material as a hex string. */
  hex(): Ed25519PrivateNormalKeyHex | Ed25519PrivateExtendedKeyHex {
    return this.__type === Ed25519PrivateKeyType.Extended
      ? Ed25519PrivateExtendedKeyHex(Buffer.from(this.#keyMaterial).toString('hex'))
      : Ed25519PrivateNormalKeyHex(Buffer.from(this.#keyMaterial).toString('hex'));
  }
}
