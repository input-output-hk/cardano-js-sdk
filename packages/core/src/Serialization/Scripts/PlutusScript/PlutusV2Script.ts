import * as Cardano from '../../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const HASH_LENGTH_IN_BYTES = 28;

/**
 * Plutus' scripts are pieces of code that implement pure functions with True or False outputs. These functions take
 * several inputs such as Datum, Redeemer and the transaction context to decide whether an output can be spent or not.
 *
 * V2 was introduced in the Vasil hard fork.
 *
 * The main changes in V2 of Plutus were to the interface to scripts. The ScriptContext was extended
 * to include the following information:
 *
 *  - The full “redeemers” structure, which contains all the redeemers used in the transaction
 *  - Reference inputs in the transaction (proposed in CIP-31)
 *  - Inline datums in the transaction (proposed in CIP-32)
 *  - Reference scripts in the transaction (proposed in CIP-33)
 */
export class PlutusV2Script {
  #compiledByteCode: HexBlob;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new Plutus script from the RAW bytes of the compiled script.
   *
   * This does NOT include any CBOR encoding around these bytes (e.g. from "cborBytes" in cardano-cli)
   * If you're creating this from those you should use PlutusV2Script.fromCbor() instead.
   */
  constructor(compiledByteCode: HexBlob) {
    this.#compiledByteCode = compiledByteCode;
  }

  /**
   * Serializes a PlutusV2Script into CBOR format.
   *
   * @returns The PlutusV2Script in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();
    writer.writeByteString(Buffer.from(this.#compiledByteCode, 'hex'));
    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PlutusV2Script from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PlutusV2Script object.
   * @returns The new PlutusV2Script instance.
   */
  static fromCbor(cbor: HexBlob): PlutusV2Script {
    const reader = new CborReader(cbor);

    const bytes = reader.readByteString();

    const script = new PlutusV2Script(HexBlob.fromBytes(bytes));
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
      version: Cardano.PlutusLanguageVersion.V2
    };
  }

  /**
   * Creates a PlutusV2Script object from the given Core PlutusScript object.
   *
   * @param plutusScript The core PlutusScript object.
   */
  static fromCore(plutusScript: Cardano.PlutusScript): PlutusV2Script {
    if (plutusScript.version !== Cardano.PlutusLanguageVersion.V2)
      throw new InvalidArgumentError('script', 'Wrong plutus language version.');

    return new PlutusV2Script(plutusScript.bytes);
  }

  /**
   * Computes the script hash of this Plutus V2 script.
   *
   * @returns the script hash.
   */
  hash(): Crypto.Hash28ByteBase16 {
    // To compute a script hash, note that you must prepend a tag to the bytes of
    // the script before hashing. The tags in the Babbage era for PlutusV2 is "\x02"
    const bytes = `02${this.rawBytes()}`;

    const hash = Crypto.blake2b(HASH_LENGTH_IN_BYTES).update(Buffer.from(bytes, 'hex')).digest();

    return Crypto.Hash28ByteBase16(HexBlob.fromBytes(hash));
  }

  /**
   * Gets the raw bytes of this compiled Plutus script.
   *
   * If you need "cborBytes" for cardano-cli use PlutusV2Script::toCbor() instead.
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
