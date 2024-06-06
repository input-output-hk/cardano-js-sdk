import { CborReader, CborWriter } from '../CBOR/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { PlutusList } from './PlutusList.js';
import { hexToBytes } from '../../util/misc/index.js';

const GENERAL_FORM_TAG = 102n;
const ALTERNATIVE_TAG_OFFSET = 7n;

/**
 * The main datatype `Constr` represents the nth constructor
 * along with its arguments.
 *
 * Remark: We don't directly serialize the alternative in the tag,
 * instead the scheme is:
 *
 * - Alternatives 0-6 -> tags 121-127, followed by the arguments in a list.
 * - Alternatives 7-127 -> tags 1280-1400, followed by the arguments in a list.
 * - Any alternatives, including those that don't fit in the above -> tag 102 followed by a list containing
 * an unsigned integer for the actual alternative, and then the arguments in a (nested!) list.
 */
export class ConstrPlutusData {
  readonly #alternative: bigint = 0n;
  readonly #data = new PlutusList();

  /**
   * Initializes a new instance of the ConstrPlutusData class.
   *
   * @param alternative Get the Constr alternative. The alternative represents the nth
   * constructor of a 'Sum Type'.
   * @param data Gets the list of arguments of the 'Sum Type' as a 'PlutusList'.
   */
  constructor(alternative: bigint, data: PlutusList) {
    this.#alternative = alternative;
    this.#data = data;
  }

  /**
   * Serializes this ConstrPlutusData instance into its CBOR representation as a Uint8Array.
   *
   * @returns The CBOR representation of this instance as a Uint8Array.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();
    const compactTag = ConstrPlutusData.alternativeToCompactCborTag(this.#alternative);

    writer.writeTag(Number(compactTag));

    if (compactTag !== GENERAL_FORM_TAG) {
      writer.writeEncodedValue(hexToBytes(this.#data.toCbor()));
    } else {
      writer.writeStartArray(2);
      writer.writeInt(this.#alternative);
      writer.writeEncodedValue(hexToBytes(this.#data.toCbor()));
    }

    return HexBlob.fromBytes(writer.encode());
  }

  /**
   * Deserializes a ConstrPlutusData instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a Uint8Array.
   * @returns A ConstrPlutusData instance.
   */
  static fromCbor(cbor: HexBlob): ConstrPlutusData {
    const reader = new CborReader(cbor);

    const tag = reader.readTag();

    if (tag === Number(GENERAL_FORM_TAG)) {
      reader.readStartArray();

      const alternative = reader.readInt();
      const data = reader.readEncodedValue();
      const plutusList = PlutusList.fromCbor(HexBlob.fromBytes(data));

      reader.readEndArray();

      return new ConstrPlutusData(alternative, plutusList);
    }

    const alternative = ConstrPlutusData.compactCborTagToAlternative(BigInt(tag));
    const data = reader.readEncodedValue();
    const plutusList = PlutusList.fromCbor(HexBlob.fromBytes(data));

    return new ConstrPlutusData(alternative, plutusList);
  }

  /**
   * Gets the ConstrPlutusData alternative. The alternative represents the nth
   * constructor of a 'Sum Type'.
   *
   * @returns The alternative constructor of the 'Sum Type'.
   */
  getAlternative(): bigint {
    return this.#alternative;
  }

  /**
   * The list of arguments of the 'Sum Type' as a 'PlutusList'.
   *
   * @returns The list of arguments.
   */
  getData(): PlutusList {
    return this.#data;
  }

  /**
   * Indicates whether some other ConstrPlutusData is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: ConstrPlutusData): boolean {
    if (this.#alternative !== other.#alternative) return false;

    return this.#data.equals(other.#data);
  }

  // Mapping functions to and from alternative to and from CBOR tags.
  // See https://github.com/input-output-hk/plutus/blob/1f31e640e8a258185db01fa899da63f9018c0e85/plutus-core/plutus-core/src/PlutusCore/Data.hs#L69-L72

  /**
   * Converts a CBOR compact tag to a Constr alternative.
   *
   * @param tag The tag to be converted.
   * @returns The Constr alternative.
   */
  private static compactCborTagToAlternative(tag: bigint): bigint {
    if (tag >= 121n && tag <= 127) return tag - 121n;
    if (tag >= 1280n && tag <= 1400) return tag - 1280n + ALTERNATIVE_TAG_OFFSET;

    return GENERAL_FORM_TAG;
  }

  /**
   * Converts the constructor alternative to its CBOR compact tag.
   *
   * @param alternative The Constr alternative to be converted.
   * @returns The compact CBOR tag.
   */
  private static alternativeToCompactCborTag(alternative: bigint): bigint {
    if (alternative <= 6n) return 121n + alternative;
    if (alternative >= 7n && alternative <= 127n) return 1280n - ALTERNATIVE_TAG_OFFSET + alternative;

    return GENERAL_FORM_TAG;
  }
}
