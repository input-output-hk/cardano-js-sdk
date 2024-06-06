import { CborReader, CborTag, CborWriter } from '../CBOR/index.js';
import { InvalidArgumentError } from '@cardano-sdk/util';
import Fraction from 'fraction.js';
import type * as Cardano from '../../Cardano/index.js';
import type { HexBlob } from '@cardano-sdk/util';

const UNIT_INTERVAL_ARRAY_SIZE = 2;

/**
 * Unit intervals are serialized as Rational Numbers (Tag 30).
 *
 * Rational numbers are numbers that can be expressed as a ratio of two integers; a numerator,
 * usually written as the top part of a fraction, and the denominator, the bottom part. The value
 * of a rational number is the numerator divided by the denominator.
 */
export class UnitInterval {
  #numerator: bigint;
  #denominator: bigint;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the UnitInterval class.
   *
   * @param numerator The top part of the fraction.
   * @param denominator The bottom part the fraction.
   */
  constructor(numerator: bigint, denominator: bigint) {
    this.#numerator = numerator;
    this.#denominator = denominator;
  }

  /**
   * Initializes a new instance of the UnitInterval class.
   *
   * @param number The float number.
   */
  static fromFloat(number: number | undefined): UnitInterval | undefined {
    if (number === undefined) return undefined;
    const fraction = new Fraction(number);
    return new UnitInterval(BigInt(fraction.n), BigInt(fraction.d));
  }

  /**
   * Serializes a UnitInterval into CBOR format.
   *
   * @returns The UnitInterval in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    //  d8 1e      ---- Tag 30
    //     82      ---- Array length 2
    //        01   ---- 1
    //        03   ---- 3
    writer.writeTag(CborTag.RationalNumber);
    writer.writeStartArray(UNIT_INTERVAL_ARRAY_SIZE);
    writer.writeInt(this.#numerator);
    writer.writeInt(this.#denominator);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the UnitInterval from a CBOR byte array.
   *
   * @param cbor The CBOR encoded UnitInterval object.
   * @returns The new UnitInterval instance.
   */
  static fromCbor(cbor: HexBlob): UnitInterval {
    const reader = new CborReader(cbor);

    if (reader.readTag() !== CborTag.RationalNumber)
      throw new InvalidArgumentError('cbor', `Expected tag ${CborTag.RationalNumber}, but got ${reader.peekTag()}`);

    const length = reader.readStartArray();

    if (length !== UNIT_INTERVAL_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${UNIT_INTERVAL_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const numerator = reader.readInt();
    const denominator = reader.readInt();

    reader.readEndArray();

    const unitInterval = new UnitInterval(numerator, denominator);
    unitInterval.#originalBytes = cbor;

    return unitInterval;
  }

  /**
   * Creates a Core Fraction object from the current UnitInterval object.
   *
   * @returns The Core Fraction object.
   */
  toCore(): Cardano.Fraction {
    return {
      denominator: Number(this.#denominator),
      numerator: Number(this.#numerator)
    };
  }

  /**
   * Creates a UnitInterval object from the given Core Fraction object.
   *
   * @param fraction core Fraction object.
   */
  static fromCore(fraction: Cardano.Fraction) {
    return new UnitInterval(BigInt(fraction.numerator), BigInt(fraction.denominator));
  }

  /**
   * Gets the numerator of the fraction.
   *
   * @returns The top part of the fraction.
   */
  numerator(): bigint {
    return this.#numerator;
  }

  /**
   * Sets the numerator of the fraction.
   *
   * @param numerator The top part of the fraction.
   */
  setNumerator(numerator: bigint): void {
    this.#numerator = numerator;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the denominator of the fraction.
   *
   * @returns The bottom part of the fraction.
   */
  denominator(): bigint {
    return this.#denominator;
  }

  /**
   * Sets the denominator of the fraction.
   *
   * @param denominator The bottom part of the fraction.
   */
  setDenominator(denominator: bigint): void {
    this.#denominator = denominator;
    this.#originalBytes = undefined;
  }

  /**
   * Converts this UnitInterval instance into a float.
   *
   * @returns The init interval as a float.
   */
  toFloat(): number {
    return Number(this.#numerator) / Number(this.#denominator);
  }
}
