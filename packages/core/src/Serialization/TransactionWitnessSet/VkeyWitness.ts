import { CborReader, CborWriter } from '../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc/index.js';
import type * as Crypto from '@cardano-sdk/crypto';

const VKEY_ARRAY_SIZE = 2;

/**
 * VkeyWitness (Verification Key Witness) is a component of a transaction that
 * provides cryptographic proof that proves that the creator of the transaction
 * has access to the private keys controlling the UTxOs being spent.
 */
export class VkeyWitness {
  #vkey: Crypto.Ed25519PublicKeyHex;
  #signature: Crypto.Ed25519SignatureHex;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the VkeyWitness class.
   *
   * @param vkey This is the public counterpart to the private key (SKey). It's used to verify the signature.
   * @param signature This is a cryptographic signature produced by signing the hash of the transaction body with
   * the corresponding private key (SKey). Anyone can verify this signature using the provided VKey,
   * ensuring that the transaction was authorized by the holder of the private key.
   */
  constructor(vkey: Crypto.Ed25519PublicKeyHex, signature: Crypto.Ed25519SignatureHex) {
    this.#vkey = vkey;
    this.#signature = signature;
  }

  /**
   * Serializes a VkeyWitness into CBOR format.
   *
   * @returns The VkeyWitness in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // vkeywitness = [ $vkey, $signature ]
    writer.writeStartArray(VKEY_ARRAY_SIZE);
    writer.writeByteString(hexToBytes(this.#vkey as unknown as HexBlob));
    writer.writeByteString(hexToBytes(this.#signature as unknown as HexBlob));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the VkeyWitness from a CBOR byte array.
   *
   * @param cbor The CBOR encoded VkeyWitness object.
   * @returns The new VkeyWitness instance.
   */
  static fromCbor(cbor: HexBlob): VkeyWitness {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== VKEY_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${VKEY_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const vkey = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Ed25519PublicKeyHex;
    const signature = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Ed25519SignatureHex;

    reader.readEndArray();

    const witness = new VkeyWitness(vkey, signature);
    witness.#originalBytes = cbor;

    return witness;
  }

  /**
   * Creates a tuple with the vkey and the signature from the current VkeyWitness object.
   *
   * @returns The tuple with the vkey and the signature.
   */
  toCore(): [Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex] {
    return [this.#vkey, this.#signature];
  }

  /**
   * Creates a VkeyWitness object from a tuple with the vkey and the signature.
   *
   * @param signatureEntry A tuple with the vkey and the signature.
   */
  static fromCore(signatureEntry: [Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex]) {
    return new VkeyWitness(signatureEntry[0], signatureEntry[1]);
  }

  /**
   * Gets the public key associated with the provided signature.
   *
   * @returns The public key.
   */
  vkey(): Crypto.Ed25519PublicKeyHex {
    return this.#vkey;
  }

  /**
   * Sets the public key associated with the provided signature.
   *
   * @param vkey The public key.
   */
  setVkey(vkey: Crypto.Ed25519PublicKeyHex) {
    this.#vkey = vkey;
    this.#originalBytes = undefined;
  }

  /**
   * Gets transaction body signature computed with the private counterpart to the public key (VKey).
   *
   * @returns The Ed25519 signature.
   */
  signature(): Crypto.Ed25519SignatureHex {
    return this.#signature;
  }

  /**
   * Sets the transaction body signature computed with the private counterpart to the public key (VKey).
   *
   * @param signature The Ed25519 signature.
   */
  setSignature(signature: Crypto.Ed25519SignatureHex) {
    this.#signature = signature;
    this.#originalBytes = undefined;
  }
}
