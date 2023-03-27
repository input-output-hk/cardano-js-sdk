/* eslint-disable no-bitwise */
/* eslint-disable unicorn/number-literal-case */
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { MajorType } from './MajorType';
import { Tag } from './Tag';

// Constants
const MINUS_ONE = BigInt(-1);
const SHIFT32 = BigInt('0x100000000');
const ONE = 24;
const TWO = 25;
const FOUR = 26;
const EIGHT = 27;
const FALSE = 0xf4;
const TRUE = 0xf5;
const NULL = 0xf6;
const UNDEFINED = 0xf7;
const INDEFINITE_LENGTH_ARRAY = 0x9f;
const INDEFINITE_LENGTH_MAP = 0xbf;
const BREAK = 0xff;

/**
 * A simple writer for Concise Binary Object Representation (CBOR) encoded data.
 *
 * remark: This is not a complete CBOR encoder as this is only intended to be used to serialize Cardano's domain
 * structures specified in the CDDL, as such, only the types needed to represent these structures are supported.
 */
export class CborWriter {
  #buffer = Buffer.from([]);

  /**
   * Writes the provided value as a tagged bignum encoding, as described in RFC7049 section 2.4.2.
   *
   * @param value The value to write.
   */
  writeBigInteger(value: bigint) {
    let tag = Tag.UnsignedBigNum;

    if (value < 0) {
      value = -value + MINUS_ONE;
      tag = Tag.NegativeBigNum;
    }

    let str = value.toString(16);
    if (str.length % 2) {
      str = `0${str}`;
    }
    const buffer = Buffer.from(str, 'hex');
    this.writeTag(tag);
    this.#writeTypeValue(MajorType.ByteString, buffer.length);
    this.#buffer = Buffer.concat([this.#buffer, buffer]);
  }

  /**
   * Writes a boolean value (major type 7).
   *
   * @param value The value to write.
   */
  writeBoolean(value: boolean) {
    this.#pushUInt8(value ? TRUE : FALSE);
  }

  /**
   * Writes a buffer as a byte string encoding (major type 2).
   *
   * @param value The value to write.
   */
  writeByteString(value: Uint8Array) {
    this.#writeTypeValue(MajorType.ByteString, value.length);
    this.#buffer = Buffer.concat([this.#buffer, value]);
  }

  /**
   * Writes a single CBOR data item which has already been encoded.
   *
   * @param value The value to write.
   */
  writeEncodedValue(value: Uint8Array) {
    this.#buffer = Buffer.concat([this.#buffer, value]);
  }

  /**
   * Writes the start of a definite or indefinite-length array (major type 4).
   *
   * @param length The length of the definite-length array, or undefined for an indefinite-length array.
   */
  writeStartArray(length?: number) {
    if (length) {
      this.#writeTypeValue(MajorType.Array, length);
    } else {
      this.#pushUInt8(INDEFINITE_LENGTH_ARRAY);
    }
  }

  /**
   * Writes the end of an array (major type 4).
   */
  writeEndArray() {
    this.#pushUInt8(BREAK);
  }

  /**
   * Writes the start of a definite or indefinite-length map (major type 5).
   *
   * @param length The length of the definite-length map, or null for an indefinite-length map.
   */
  writeStartMap(length?: number) {
    if (length) {
      this.#writeTypeValue(MajorType.Map, length);
    } else {
      this.#pushUInt8(INDEFINITE_LENGTH_MAP);
    }
  }

  /**
   * Writes the end of a map (major type 5).
   */
  writeEndMap() {
    this.#pushUInt8(BREAK);
  }

  /**
   * Writes a value as a signed integer encoding (major types 0,1)
   *
   * @param value The value to write.
   */
  writeInt(value: number) {
    if (value < 0) {
      this.#writeTypeValue(MajorType.NegativeUnsignedInteger, -(value + 1));
    } else {
      this.#writeTypeValue(MajorType.PositiveUnsignedInteger, value);
    }
  }

  /**
   * Writes a value as a unsigned integer encoding (major types 0)
   *
   * @param value The value to write.
   */
  writeUInt(value: number) {
    this.#writeTypeValue(MajorType.PositiveUnsignedInteger, value);
  }

  /**
   * Writes a null value (major type 7).
   */
  writeNull() {
    this.#pushUInt8(NULL);
  }

  /**
   * Writes an undefined value.
   */
  writeUndefined() {
    this.#pushUInt8(UNDEFINED);
  }

  /**
   * Assign a semantic tag (major type 6) to the next data item.
   *
   * @param tag semantic tag.
   */
  writeTag(tag: Tag | number) {
    return this.#writeTypeValue(tag, MajorType.Tag);
  }

  /**
   * Returns a new array containing the encoded value.
   */
  encode(): HexBlob {
    return this.#buffer.toString('hex') as unknown as HexBlob;
  }

  /**
   * Resets the writer to have no data.
   */
  reset() {
    this.#buffer = Buffer.from([]);
  }

  /**
   * Writes a typed value to the buffer.
   *
   * @param majorType The major type of the value.
   * @param value The value.
   */
  #writeTypeValue(majorType: MajorType, value: number) {
    const m = majorType << 5;
    if (value < 24) {
      this.#pushUInt8(m | value);
    } else if (value <= 256) {
      this.#pushUInt8(m | ONE);
      this.#pushUInt8(value);
    } else if (value <= 65_536) {
      this.#pushUInt8(m | TWO);
      this.#pushUInt16(value);
    } else if (value <= 4_294_967_296) {
      this.#pushUInt8(m | FOUR);
      this.#pushUInt32(value);
    } else {
      let max = Number.MAX_SAFE_INTEGER;
      if (majorType === MajorType.NegativeUnsignedInteger) {
        // Special case for Number.MIN_SAFE_INTEGER - 1
        max--;
      }

      if (value <= max) {
        this.#pushUInt8(m | EIGHT);
        this.#pushUInt32(Math.floor(value / Number(SHIFT32)));
        this.#pushUInt32(value % Number(SHIFT32));
      } else {
        throw new InvalidArgumentError('value', 'Out of range');
      }
    }
  }

  /**
   * Push an Uint8 byte to the buffer in Big Endian.
   *
   * @param {number} value Number(0-255) to encode.
   */
  #pushUInt8(value: number) {
    const b = Buffer.allocUnsafe(1);
    b.writeUInt8(value, 0);

    this.#buffer = Buffer.concat([this.#buffer, b]);
  }

  /**
   * Push an Uint16 byte to the buffer in Big Endian.
   *
   * @param {number} value Number(0-65535) to encode.
   */
  #pushUInt16(value: number) {
    const b = Buffer.allocUnsafe(2);
    b.writeUInt16BE(value, 0);

    this.#buffer = Buffer.concat([this.#buffer, b]);
  }

  /**
   * Push an Uint32 byte to the buffer in Big Endian.
   *
   * @param {number} value Number(0..2**32-1) to encode.
   */
  #pushUInt32(value: number) {
    const b = Buffer.allocUnsafe(4);
    b.writeUInt32BE(value, 0);

    this.#buffer = Buffer.concat([this.#buffer, b]);
  }
}
