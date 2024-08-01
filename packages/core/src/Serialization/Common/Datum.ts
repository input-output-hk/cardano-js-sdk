import * as Crypto from '@cardano-sdk/crypto';
import { PlutusData as CardanoPlutusData, DatumHash } from '../../Cardano/types';
import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { PlutusData } from '../PlutusData';

const DATUM_ARRAY_SIZE = 2;

/**
 * Gets whether the given datum is a datum hash.
 *
 * @param datum The datum to be checked for.
 */
export const isDatumHash = (datum: unknown): datum is DatumHash => datum !== null && typeof datum === 'string';

/** Represents different ways of associating a Datum with a UTxO in a transaction. */
export enum DatumKind {
  /**
   * Instead of including the full Datum directly within the transaction, it's possible to
   * include just a hash of the Datum. This is the DatumHash. By referencing the Datum
   * by its hash, the transaction can be more compact, especially if the Datum itself is large.
   * However, when using a DatumHash, the actual Datum value it represents must be provided
   * in the transaction witness set to ensure that users and validators can verify and use it.
   */
  DataHash,

  /**
   * This represents the actual Datum value being included directly
   * within the transaction output. So, the Datum is "inlined" in the transaction
   * data itself.
   */
  InlineData
}

/**
 * Represents a piece of data attached to a UTxO that a Plutus script can read when the
 * UTxO is being spent. Essentially, the Datum acts as a state for that UTxO, allowing
 * Plutus scripts to perform more complex logic based on this stored state.
 */
export class Datum {
  #datumKind: DatumKind;
  #dataHash: DatumHash | undefined;
  #inlineData: PlutusData | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Datum class.
   *
   * REMARK: A datum must be either a hash or the inlined data, but not both.
   *
   * @param dataHash The hash of the Datum.
   * @param inlineData The data being included directly within the transaction output.
   */
  constructor(dataHash?: DatumHash, inlineData?: PlutusData) {
    if (dataHash && inlineData) throw new InvalidStateError('Datum can only be DataHash or PlutusData but not both');
    if (!dataHash && !inlineData) throw new InvalidStateError('Datum must be either DataHash or PlutusData');

    if (dataHash) this.#datumKind = DatumKind.DataHash;
    if (inlineData) this.#datumKind = DatumKind.InlineData;

    this.#dataHash = dataHash;
    this.#inlineData = inlineData;
  }

  /**
   * Serializes a Datum into CBOR format.
   *
   * @returns The Datum in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // datum_hash = $hash32
    // data = #6.24(bytes .cbor plutus_data)
    //
    // datum_option = [ 0, $hash32 // 1, data ]
    writer.writeStartArray(DATUM_ARRAY_SIZE);
    writer.writeInt(this.#datumKind);

    if (this.#datumKind === DatumKind.DataHash) {
      writer.writeByteString(Buffer.from(this.#dataHash!, 'hex').valueOf());
    } else {
      writer.writeEncodedValue(Buffer.from(this.#inlineData!.toCbor(), 'hex').valueOf());
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Datum from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Datum object.
   * @returns The new Datum instance.
   */
  static fromCbor(cbor: HexBlob): Datum {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== DATUM_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${DATUM_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    let datumHash: DatumHash | undefined;
    let inlineDatum: PlutusData | undefined;

    switch (kind) {
      case DatumKind.DataHash:
        datumHash = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash32ByteBase16;
        break;
      case DatumKind.InlineData:
        inlineDatum = PlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        break;
      default:
        throw new InvalidArgumentError('cbor', `Unexpected datum kind ${kind}`);
    }

    reader.readEndArray();

    const exUnit = new Datum(datumHash, inlineDatum);
    exUnit.#originalBytes = cbor;

    return exUnit;
  }

  /**
   * Creates a Core Datum object from the current Datum object.
   *
   * @returns The Core Datum object.
   */
  toCore(): DatumHash | CardanoPlutusData {
    let result;

    switch (this.#datumKind) {
      case DatumKind.DataHash:
        result = this.#dataHash as DatumHash;
        break;
      case DatumKind.InlineData:
        result = this.#inlineData!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected datum kind ${this.#datumKind}`);
    }

    return result;
  }

  /**
   * Creates a Datum object from the given Core Datum object.
   *
   * @param datum core Datum object.
   */
  static fromCore(datum: DatumHash | CardanoPlutusData) {
    if (isDatumHash(datum)) return new Datum(datum);

    return new Datum(undefined, PlutusData.fromCore(datum));
  }

  /**
   * Gets the datum kind.
   *
   * @returns the datum kind.
   */
  kind(): DatumKind {
    return this.#datumKind;
  }

  /**
   * Gets this datum as a Datum hash.
   *
   * @returns a DatumHash if the Datum can be cast, otherwise, undefined.
   */
  asDataHash(): DatumHash | undefined {
    return this.#dataHash;
  }

  /**
   * Gets this datum as PlutusData.
   *
   * @returns a PlutusData instance if the Datum can be cast, otherwise, undefined.
   */
  asInlineData(): PlutusData | undefined {
    return this.#inlineData;
  }

  /**
   * Gets a Datum instance from a Datum hash.
   *
   * @param dataHash The Datum hash to 'cast' to Datum.
   */
  static newDataHash(dataHash: DatumHash): Datum {
    return new Datum(dataHash);
  }

  /**
   * Gets a Datum instance from Inline Data.
   *
   * @param inlineData The PlutusData to 'cast' to Datum.
   */
  static newInlineData(inlineData: PlutusData): Datum {
    return new Datum(undefined, inlineData);
  }
}
