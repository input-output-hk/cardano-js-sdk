import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { BootstrapWitness as CardanoBootstrapWitness } from '../../Cardano/types/Transaction';
import { CborReader, CborWriter } from '../CBOR';
import { hexToBytes } from '../../util/misc';

const BOOTSTRAP_WITNESS_ARRAY_SIZE = 4;
const EMPTY_ATTRIBUTES_CBOR = HexBlob('a0');

/**
 * The bootstrap witness proves that the transaction has the authority to spend
 * the value from the associated Byron-era input UTxOs.
 *
 * Cardano has transitioned away from this type of witness from Shelley and later eras, BootstrapWitnesses
 * are currently deprecated.
 */
export class BootstrapWitness {
  #vkey: Crypto.Ed25519PublicKeyHex;
  #signature: Crypto.Ed25519SignatureHex;
  #chainCode: HexBlob;
  #attributes: HexBlob;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the BootstrapWitness class.
   *
   * @param vkey This is the public counterpart to the private key (SKey). It's used to verify the signature.
   * @param signature This is a cryptographic signature produced by signing the hash of the transaction body with
   * the corresponding private key (SKey). Anyone can verify this signature using the provided VKey,
   * ensuring that the transaction was authorized by the holder of the private key.
   * @param chainCode The chain code is used to compute HD (Hierarchical Deterministic) wallet addresses in the Byron era.
   * @param attributes Additional attributes that are used for network discrimination.
   */
  constructor(
    vkey: Crypto.Ed25519PublicKeyHex,
    signature: Crypto.Ed25519SignatureHex,
    chainCode: HexBlob,
    attributes: HexBlob
  ) {
    this.#vkey = vkey;
    this.#signature = signature;
    this.#chainCode = chainCode;
    this.#attributes = attributes;
  }

  /**
   * Serializes a BootstrapWitness into CBOR format.
   *
   * @returns The BootstrapWitness in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    if (this.#chainCode.length / 2 !== 32)
      throw new InvalidStateError(`Chaincode must be 32 bytes long, but got ${this.#chainCode.length / 2} bytes long`);

    // CDDL
    // bootstrap_witness =
    //   [ public_key : $vkey
    //   , signature  : $signature
    //   , chain_code : bytes .size 32
    //   , attributes : bytes
    //   ]
    writer.writeStartArray(BOOTSTRAP_WITNESS_ARRAY_SIZE);
    writer.writeByteString(hexToBytes(this.#vkey as unknown as HexBlob));
    writer.writeByteString(hexToBytes(this.#signature as unknown as HexBlob));
    writer.writeByteString(hexToBytes(this.#chainCode));
    writer.writeByteString(hexToBytes(this.#attributes));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the BootstrapWitness from a CBOR byte array.
   *
   * @param cbor The CBOR encoded BootstrapWitness object.
   * @returns The new BootstrapWitness instance.
   */
  static fromCbor(cbor: HexBlob): BootstrapWitness {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== BOOTSTRAP_WITNESS_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${BOOTSTRAP_WITNESS_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const vkey = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Ed25519PublicKeyHex;
    const signature = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Ed25519SignatureHex;
    const chainCode = HexBlob.fromBytes(reader.readByteString());
    const attributes = HexBlob.fromBytes(reader.readByteString());

    reader.readEndArray();

    const witness = new BootstrapWitness(vkey, signature, chainCode, attributes);
    witness.#originalBytes = cbor;

    return witness;
  }

  /**
   * Creates a core BootstrapWitness from the BootstrapWitness object.
   *
   * @returns The core BootstrapWitness.
   */
  toCore(): CardanoBootstrapWitness {
    return {
      addressAttributes: Base64Blob.fromBytes(hexToBytes(this.#attributes)),
      chainCode: this.#chainCode,
      key: this.#vkey,
      signature: this.#signature
    };
  }

  /**
   * Creates a BootstrapWitness object from a core BootstrapWitness.
   *
   * @param core A core BootstrapWitness object.
   */
  static fromCore(core: CardanoBootstrapWitness) {
    // REMARK: there is a quirk with our BootstrapWitness core type related to Ogmios, some fields are mark as optional,
    // however all fields are required. See https://github.com/CardanoSolutions/ogmios/discussions/285#discussioncomment-4271726.
    // If chainCode is not present or is not the right size we will throw.
    // If addressAttributes is not present we will serialize it as an empty byte string.

    if (!core.chainCode) throw new InvalidStateError('Chaincode must be present');

    if (core.chainCode.length / 2 !== 32)
      throw new InvalidStateError(`Chaincode must be 32 bytes long, but got ${core.chainCode.length / 2} bytes long`);

    return new BootstrapWitness(
      core.key,
      core.signature,
      core.chainCode,
      core.addressAttributes ? HexBlob.fromBase64(core.addressAttributes) : EMPTY_ATTRIBUTES_CBOR
    );
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

  /**
   * Gets the chaincode of this bootstrap witness.
   *
   * @returns The chain code.
   */
  chainCode(): HexBlob {
    return this.#chainCode;
  }

  /**
   * Sets the chaincode of this bootstrap witness.
   *
   * @param chainCode The chain code.
   */
  setChainCode(chainCode: HexBlob) {
    if (chainCode.length / 2 !== 32)
      throw new InvalidStateError(`Chaincode must be 32 bytes long, but got ${chainCode.length / 2} bytes long`);

    this.#chainCode = chainCode;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the attributes of this bootstrap witness.
   *
   * @returns The attributes.
   */
  attributes(): HexBlob {
    return this.#attributes;
  }

  /**
   * Sets the attributes of this bootstrap witness.
   *
   * @param attributes The attributes.
   */
  setAttributes(attributes: HexBlob) {
    this.#attributes = attributes;
    this.#originalBytes = undefined;
  }
}
