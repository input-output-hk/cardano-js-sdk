import { Ed25519SignatureHex } from '../hexTypes.js';
import { InvalidArgumentError } from '@cardano-sdk/util';

export const ED25519_SIGNATURE_LENGTH = 64;

/** Ed25519 cryptographic digital signature. */
export class Ed25519Signature {
  readonly #signature: Uint8Array;

  /**
   * Initializes a new instance of the Ed25519Signature class.
   *
   * @param signature The bip32 private key.
   */
  constructor(signature: Uint8Array) {
    this.#signature = signature;
  }

  /**
   * Initializes a new Ed25519Signature provided as a byte array.
   *
   * @param signature The Ed25519 signature.
   */
  static fromBytes(signature: Uint8Array) {
    if (signature.length !== ED25519_SIGNATURE_LENGTH)
      throw new InvalidArgumentError(
        'signature',
        `signature should be ${ED25519_SIGNATURE_LENGTH} bytes; however ${signature.length} bytes were provided.`
      );
    return new Ed25519Signature(signature);
  }

  /**
   * Initializes a new instance of the Ed25519Signature class from its signature provided as a hex string.
   *
   * @param signature The signature as a hex string.
   */
  static fromHex(signature: Ed25519SignatureHex) {
    return Ed25519Signature.fromBytes(Buffer.from(signature, 'hex'));
  }

  /** Gets the Ed25519Signature as a byte array. */
  bytes(): Uint8Array {
    return this.#signature;
  }

  /** Gets the Ed25519Signature as a hex string. */
  hex(): Ed25519SignatureHex {
    return Ed25519SignatureHex(Buffer.from(this.#signature).toString('hex'));
  }
}
