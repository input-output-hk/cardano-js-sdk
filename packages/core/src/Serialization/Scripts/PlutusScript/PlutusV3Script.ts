import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { PlutusLanguageVersion, ScriptType } from '../../../Cardano/types/Script';
import type * as Cardano from '../../../Cardano';

const HASH_LENGTH_IN_BYTES = 28;

/**
 * Plutus' scripts are pieces of code that implement pure functions with True or False outputs. These functions take
 * several inputs such as Datum, Redeemer and the transaction context to decide whether an output can be spent or not.
 *
 * V3 was introduced in the Conway hard fork.
 *
 * The main changes in V3 of Plutus were to the interface to scripts. The ScriptContext was extended
 * to include the following information:
 *
 *  - A Map with all the votes that were included in the transaction.
 *  - A list with Proposals that will be turned into GovernanceActions, that everyone can vote on
 *  - Optional amount for the current treasury. If included it will be checked to be equal the current amount in the treasury.
 *  - Optional amount for donating to the current treasury. If included, specified amount will go into the treasury.
 */
export class PlutusV3Script {
  #compiledByteCode: HexBlob;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new Plutus script from the RAW bytes of the compiled script.
   *
   * This does NOT include any CBOR encoding around these bytes (e.g. from "cborBytes" in cardano-cli)
   * If you're creating this from those you should use PlutusV3Script.fromCbor() instead.
   */
  constructor(compiledByteCode: HexBlob) {
    this.#compiledByteCode = compiledByteCode;
  }

  /**
   * Serializes a PlutusV3Script into CBOR format.
   *
   * @returns The PlutusV3Script in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();
    writer.writeByteString(Buffer.from(this.#compiledByteCode, 'hex'));
    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PlutusV3Script from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PlutusV3Script object.
   * @returns The new PlutusV3Script instance.
   */
  static fromCbor(cbor: HexBlob): PlutusV3Script {
    const reader = new CborReader(cbor);

    const bytes = reader.readByteString();

    const script = new PlutusV3Script(HexBlob.fromBytes(bytes));
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
      __type: ScriptType.Plutus,
      bytes: this.rawBytes(),
      version: PlutusLanguageVersion.V3
    };
  }

  /**
   * Creates a PlutusV3Script object from the given Core PlutusScript object.
   *
   * @param plutusScript The core PlutusScript object.
   */
  static fromCore(plutusScript: Cardano.PlutusScript): PlutusV3Script {
    if (plutusScript.version !== PlutusLanguageVersion.V3)
      throw new InvalidArgumentError('script', 'Wrong plutus language version.');

    return new PlutusV3Script(plutusScript.bytes);
  }

  /**
   * Computes the script hash of this Plutus V3 script.
   *
   * @returns the script hash.
   */
  hash(): Crypto.Hash28ByteBase16 {
    // To compute a script hash, note that you must prepend a tag to the bytes of
    // the script before hashing. The tags in the Conway era for PlutusV3 is "\x03"
    const bytes = `03${this.rawBytes()}`;

    const hash = Crypto.blake2b(HASH_LENGTH_IN_BYTES).update(Buffer.from(bytes, 'hex')).digest();

    return Crypto.Hash28ByteBase16(HexBlob.fromBytes(hash));
  }

  /**
   * Gets the raw bytes of this compiled Plutus script.
   *
   * If you need "cborBytes" for cardano-cli use PlutusV3Script::toCbor() instead.
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
