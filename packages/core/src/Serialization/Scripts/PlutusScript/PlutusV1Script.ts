import * as Cardano from '../../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const HASH_LENGTH_IN_BYTES = 28;

/**
 * Plutus' scripts are pieces of code that implement pure functions with True or False outputs. These functions take
 * several inputs such as Datum, Redeemer and the transaction context to decide whether an output can be spent or not.
 *
 * V1 was the initial version of Plutus, introduced in the Alonzo hard fork.
 */
export class PlutusV1Script {
  #compiledByteCode: HexBlob;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new Plutus script from the RAW bytes of the compiled script.
   *
   * This does NOT include any CBOR encoding around these bytes (e.g. from "cborBytes" in cardano-cli)
   * If you're creating this from those you should use PlutusV1Script.fromCbor() instead.
   */
  constructor(compiledByteCode: HexBlob) {
    this.#compiledByteCode = compiledByteCode;
  }

  /**
   * Serializes a PlutusV1Script into CBOR format.
   *
   * @returns The PlutusV1Script in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();
    writer.writeByteString(Buffer.from(this.#compiledByteCode, 'hex'));
    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PlutusV1Script from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PlutusV1Script object.
   * @returns The new PlutusV1Script instance.
   */
  static fromCbor(cbor: HexBlob): PlutusV1Script {
    const reader = new CborReader(cbor);

    const bytes = reader.readByteString();

    const script = new PlutusV1Script(HexBlob.fromBytes(bytes));
    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core NativeScript object from the current NativeScript object.
   *
   * @returns The Core NativeScript object.
   */
  toCore(): Cardano.PlutusScript {
    return {
      __type: Cardano.ScriptType.Plutus,
      bytes: this.rawBytes(),
      version: Cardano.PlutusLanguageVersion.V1
    };
  }

  /**
   * Creates a PlutusV1Script object from the given Core PlutusScript object.
   *
   * @param plutusScript The core PlutusScript object.
   */
  static fromCore(plutusScript: Cardano.PlutusScript): PlutusV1Script {
    if (plutusScript.version !== Cardano.PlutusLanguageVersion.V1)
      throw new InvalidArgumentError('script', 'Wrong plutus language version.');

    return new PlutusV1Script(plutusScript.bytes);
  }

  /**
   * Computes the script hash of this Plutus V1 script.
   *
   * @returns the script hash.
   */
  hash(): Crypto.Hash28ByteBase16 {
    // To compute a script hash, note that you must prepend a tag to the bytes of
    // the script before hashing. The tags in the Babbage era for PlutusV1 is "\x01"
    const bytes = `01${this.rawBytes()}`;

    const hash = Crypto.blake2b(HASH_LENGTH_IN_BYTES).update(Buffer.from(bytes, 'hex')).digest();

    return Crypto.Hash28ByteBase16(HexBlob.fromBytes(hash));
  }

  /**
   * Gets the raw bytes of this compiled Plutus script.
   *
   * If you need "cborBytes" for cardano-cli use PlutusV1Script::toCbor() instead.
   *
   * @returns The raw bytes of the compiled plutus script
   */
  rawBytes(): HexBlob {
    return this.#compiledByteCode;
  }

  /**
   * Sets the raw bytes of this compiled Plutus script.
   *
   * @param bytes The raw bytes of the compiled plutus script
   */
  setRawBytes(bytes: HexBlob) {
    this.#compiledByteCode = bytes;
    this.#originalBytes = undefined;
  }
}
