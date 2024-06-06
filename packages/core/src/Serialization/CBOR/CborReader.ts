/* eslint-disable no-bitwise */
/* eslint-disable unicorn/number-literal-case */
import { CborAdditionalInfo } from './CborAdditionalInfo.js';
import { CborContentException, CborInvalidOperationException } from './errors.js';
import { CborInitialByte } from './CborInitialByte.js';
import { CborMajorType } from './CborMajorType.js';
import { CborReaderState } from './CborReaderState.js';
import { decodeHalf } from './Half.js';
import type { CborSimpleValue } from './CborSimpleValue.js';
import type { CborTag } from './CborTag.js';
import type { HexBlob } from '@cardano-sdk/util';

// Constants
const UNEXPECTED_END_OF_BUFFER_MSG = 'Unexpected end of buffer';

/** The stack frame to keep track of nested item data. */
type StackFrame = {
  type: CborMajorType | null;
  frameOffset: number;
  definiteLength?: number;
  itemsRead: number;
  currentKeyOffset: number | null;
};

/** A stateful, forward-only reader for Concise Binary Object Representation (CBOR) encoded data. */
export class CborReader {
  readonly #data: Uint8Array;
  #offset = 0;
  #nestedItems: Array<StackFrame> = new Array<StackFrame>();
  #isTagContext = false;
  #currentFrame: StackFrame;
  #cachedState = CborReaderState.Undefined;

  /**
   * Initializes a CborReader instance over the specified data with the given configuration.
   *
   * @param data The CBOR encoded data to read.
   */
  constructor(data: HexBlob) {
    this.#data = new Uint8Array(Buffer.from(data, 'hex'));
    this.#currentFrame = {
      currentKeyOffset: null,
      frameOffset: 0,
      itemsRead: 0,
      type: null
    };
  }

  /**
   * Reads the next CBOR token, without advancing the reader.
   *
   * @returns The current CBOR reader state.
   */
  peekState(): CborReaderState {
    if (this.#cachedState === CborReaderState.Undefined) this.#cachedState = this.#peekStateCore();

    return this.#cachedState;
  }

  /**
   * Gets the total number of unread bytes in the buffer.
   *
   * @returns The total number of unread bytes in the buffer.
   */
  getBytesRemaining() {
    return this.#data.length - this.#offset;
  }

  /** Skips the next CBOR data item and advance the reader. For indefinite length encodings this includes the break byte. */
  skipValue(): void {
    this.readEncodedValue();
  }

  /**
   * Reads the next CBOR data item, returning a subarray with the encoded value. For indefinite length encodings
   * this includes the break byte.
   *
   * @returns A subarray with the encoded value as a contiguous region of memory.
   */
  readEncodedValue(): Uint8Array {
    const initialOffset = this.#offset;

    let depth = 0;

    do {
      depth = this.#skipNextNode(depth);
    } while (depth > 0);

    // return the slice corresponding to the consumed value
    return this.#data.slice(initialOffset, this.#offset);
  }

  /** Reads the next data item as the start of an array (major type 4). */
  readStartArray(): number | null {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Array);

    if (header.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength) {
      this.#advanceBuffer(1);
      this.#pushDataItem(CborMajorType.Array);
      return null;
    }

    const buffer = this.#getRemainingBytes();
    const { length, bytesRead } = CborReader.#peekDefiniteLength(header, buffer);

    this.#advanceBuffer(bytesRead);
    this.#pushDataItem(CborMajorType.Array, length);
    return length;
  }

  /** Reads the end of an array (major type 4). */
  readEndArray() {
    if (this.#currentFrame.definiteLength === undefined) {
      this.#validateNextByteIsBreakByte();
      this.#popDataItem(CborMajorType.Array);
      this.#advanceDataItemCounters();
      this.#advanceBuffer(1);
    } else {
      this.#popDataItem(CborMajorType.Array);
      this.#advanceDataItemCounters();
    }
  }

  /**
   * Reads the next data item as a signed integer (major types 0,1).
   *
   * @returns The decoded integer value.
   */
  readInt(): bigint {
    const value = this.#peekSignedInteger();
    this.#advanceBuffer(value.bytesRead);
    this.#advanceDataItemCounters();
    return value.signedInt;
  }

  /**
   * Reads the next data item as an unsigned integer (major type 0).
   *
   * @returns The decoded integer value.
   */
  readUInt() {
    const value = this.#peekUnsignedInteger();
    this.#advanceBuffer(value.bytesRead);
    this.#advanceDataItemCounters();
    return value.unsignedInt;
  }

  /**
   * Reads the next data item as a double-precision floating point number (major type 7).
   *
   * @returns The decoded double value.
   */
  readDouble(): number {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Simple);
    let result;

    const remainingBytes = this.#getRemainingBytes();
    switch (header.getAdditionalInfo()) {
      case CborAdditionalInfo.Additional16BitData: {
        this.#ensureReadCapacity(3);
        result = decodeHalf(remainingBytes.slice(1));

        this.#advanceBuffer(3);
        this.#advanceDataItemCounters();

        return result;
      }
      case CborAdditionalInfo.Additional32BitData: {
        this.#ensureReadCapacity(5);
        result = Buffer.from(remainingBytes).readFloatBE(1);

        this.#advanceBuffer(5);
        this.#advanceDataItemCounters();

        return result;
      }
      case CborAdditionalInfo.Additional64BitData: {
        this.#ensureReadCapacity(9);
        result = Buffer.from(remainingBytes).readDoubleBE(1);

        this.#advanceBuffer(9);
        this.#advanceDataItemCounters();

        return result;
      }
      default:
        throw new CborInvalidOperationException('Not a float encoding');
    }
  }

  /**
   * Reads the next data item as a CBOR simple value (major type 7).
   *
   * @returns The decoded CBOR simple value.
   */
  readSimpleValue(): CborSimpleValue {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Simple);

    if ((header.getInitialByte() & CborInitialByte.AdditionalInformationMask) < CborAdditionalInfo.Additional8BitData) {
      this.#advanceBuffer(1);
      this.#advanceDataItemCounters();

      return header.getAdditionalInfo().valueOf() as CborSimpleValue;
    }

    if (header.getAdditionalInfo() === CborAdditionalInfo.Additional8BitData) {
      this.#ensureReadCapacity(2);

      const value = this.#data[this.#offset + 1];

      this.#advanceBuffer(2);
      this.#advanceDataItemCounters();

      return value as CborSimpleValue;
    }

    throw new CborInvalidOperationException('Not a simple value encoding');
  }

  /**
   * Reads the next data item as a CBOR negative integer representation (major type 1).
   *
   * @returns An unsigned integer denoting -1 minus the integer.
   */
  readCborNegativeIntegerRepresentation() {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.NegativeInteger);
    const value = CborReader.#decodeUnsignedInteger(header, this.#getRemainingBytes());
    this.#advanceBuffer(value.bytesRead);
    this.#advanceDataItemCounters();
    return value.unsignedInt;
  }

  /**
   * Reads the next data item as the start of a map (major type 5).
   *
   * @returns The number of key-value pairs in a definite-length map, or null if the map is indefinite-length.
   *
   * remark: Map contents are consumed as if they were arrays twice the length of the map's declared size.
   *
   * For example, a map of size 1 containing a key of type int with a value of type string
   * must be consumed by successive calls to readInt32 and readTextString.
   */
  readStartMap(): number | null {
    let length = null;
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Map);

    if (header.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength) {
      this.#advanceBuffer(1);
      this.#pushDataItem(CborMajorType.Map);

      length = null;
    } else {
      const buffer = this.#getRemainingBytes();

      const result = CborReader.#peekDefiniteLength(header, buffer);

      if (2 * result.length > buffer.length - result.bytesRead)
        throw new CborContentException('Definite length exceeds buffer size');

      this.#advanceBuffer(result.bytesRead);
      this.#pushDataItem(CborMajorType.Map, 2 * result.length);
      length = result.length;
    }

    this.#currentFrame.currentKeyOffset = this.#offset;
    return length;
  }

  /** Reads the end of a map (major type 5). */
  readEndMap(): void {
    if (this.#currentFrame.definiteLength === undefined) {
      this.#validateNextByteIsBreakByte();

      if (this.#currentFrame.itemsRead % 2 !== 0) throw new CborContentException('Key missing value');

      this.#popDataItem(CborMajorType.Map);
      this.#advanceDataItemCounters();
      this.#advanceBuffer(1);
    } else {
      this.#popDataItem(CborMajorType.Map);
      this.#advanceDataItemCounters();
    }
  }

  /**
   * Reads the next data item as a boolean value (major type 7).
   *
   * @returns The decoded value.
   */
  readBoolean(): boolean {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Simple);

    const val = header.getAdditionalInfo();

    if (val !== CborAdditionalInfo.AdditionalTrue && val !== CborAdditionalInfo.AdditionalFalse)
      throw new CborContentException('Not a boolean encoding');

    const result = val === CborAdditionalInfo.AdditionalTrue;

    this.#advanceBuffer(1);
    this.#advanceDataItemCounters();
    return result;
  }

  /** Reads the next data item as a null value (major type 7). */
  readNull(): void {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Simple);

    const val = header.getAdditionalInfo();

    if (val !== CborAdditionalInfo.AdditionalNull) throw new CborContentException('Not a null encoding');

    this.#advanceBuffer(1);
    this.#advanceDataItemCounters();
  }

  /** Reads the next data item as the start of an indefinite-length byte string (major type 2). */
  readStartIndefiniteLengthByteString() {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.ByteString);

    if (header.getAdditionalInfo() !== CborAdditionalInfo.IndefiniteLength)
      throw new CborInvalidOperationException('Not indefinite length string');

    this.#advanceBuffer(1);
    this.#pushDataItem(CborMajorType.ByteString);
  }

  /** Ends reading an indefinite-length byte string (major type 2). */
  readEndIndefiniteLengthByteString() {
    this.#validateNextByteIsBreakByte();
    this.#popDataItem(CborMajorType.ByteString);
    this.#advanceDataItemCounters();
    this.#advanceBuffer(1);
  }

  /**
   * Reads the next data item as a byte string (major type 2).
   *
   * @returns The decoded byte array.
   *
   * Remark: The method accepts indefinite length strings, which it concatenates to a single string.
   */
  readByteString(): Uint8Array {
    const header = this.#peekInitialByte(CborMajorType.ByteString);

    if (header.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength) {
      const { val, encodingLength } = this.#readIndefiniteLengthByteStringConcatenated(CborMajorType.ByteString);

      this.#advanceBuffer(encodingLength);
      this.#advanceDataItemCounters();

      return val;
    }

    const buffer = this.#getRemainingBytes();
    const { length, bytesRead } = CborReader.#peekDefiniteLength(header, buffer);

    this.#ensureReadCapacity(bytesRead + length);
    this.#advanceBuffer(bytesRead + length);
    this.#advanceDataItemCounters();

    return buffer.slice(bytesRead, bytesRead + length);
  }

  /**
   * Reads the next data item as a byte string (major type 2).
   *
   * @returns The decoded byte array.
   *
   * Remark: The method accepts indefinite length strings, which it concatenates to a single string.
   */
  readDefiniteLengthByteString(): Uint8Array {
    const header = this.#peekInitialByte(CborMajorType.ByteString);

    if (header.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength) {
      throw new CborInvalidOperationException('Expected definite length array and got indefinite length');
    }

    const buffer = this.#getRemainingBytes();
    const { length, bytesRead } = CborReader.#peekDefiniteLength(header, buffer);

    this.#ensureReadCapacity(bytesRead + length);
    this.#advanceBuffer(bytesRead + length);
    this.#advanceDataItemCounters();

    return buffer.slice(bytesRead, bytesRead + length);
  }

  /** Reads the next data item as the start of an indefinite-length UTF-8 text string (major type 3). */
  readStartIndefiniteLengthTextString() {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Utf8String);

    if (header.getAdditionalInfo() !== CborAdditionalInfo.IndefiniteLength)
      throw new CborInvalidOperationException('Not indefinite length string');

    this.#advanceBuffer(1);
    this.#pushDataItem(CborMajorType.Utf8String);
  }

  /** Ends reading an indefinite-length UTF-8 text string (major type 3). */
  readEndIndefiniteLengthTextString() {
    this.#validateNextByteIsBreakByte();
    this.#popDataItem(CborMajorType.Utf8String);
    this.#advanceDataItemCounters();
    this.#advanceBuffer(1);
  }

  /**
   * Reads the next data item as a UTF-8 text string (major type 3).
   *
   * @returns The decoded string.
   *
   * Remark: The method accepts indefinite length strings, which it concatenates to a single string.
   */
  readTextString(): string {
    const header = this.#peekInitialByte(CborMajorType.Utf8String);

    if (header.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength) {
      const { val, encodingLength } = this.#readIndefiniteLengthByteStringConcatenated(CborMajorType.Utf8String);

      this.#advanceBuffer(encodingLength);
      this.#advanceDataItemCounters();

      return Buffer.from(val).toString('utf8');
    }

    const buffer = this.#getRemainingBytes();
    const { length, bytesRead } = CborReader.#peekDefiniteLength(header, buffer);

    this.#ensureReadCapacity(bytesRead + length);
    this.#advanceBuffer(bytesRead + length);
    this.#advanceDataItemCounters();

    return Buffer.from(buffer.slice(bytesRead, bytesRead + length)).toString('utf8');
  }

  /**
   * Reads the next data item as a UTF-8 text string (major type 3).
   *
   * @returns The decoded string.
   *
   * Remark: The method accepts indefinite length strings, which it concatenates to a single string.
   */
  readDefiniteLengthTextString(): string {
    const header = this.#peekInitialByte(CborMajorType.Utf8String);

    if (header.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength) {
      throw new CborInvalidOperationException('Expected definite length string and got indefinite length');
    }

    const buffer = this.#getRemainingBytes();
    const { length, bytesRead } = CborReader.#peekDefiniteLength(header, buffer);

    this.#ensureReadCapacity(bytesRead + length);
    this.#advanceBuffer(bytesRead + length);
    this.#advanceDataItemCounters();

    return Buffer.from(buffer.slice(bytesRead, bytesRead + length)).toString('utf8');
  }

  /**
   * Reads the next data item as a semantic tag (major type 6), without advancing the reader.
   *
   * @returns The decoded value.
   */
  readTag(): CborTag {
    const { tag, bytesRead } = this.#peekTagCore();

    this.#advanceBuffer(bytesRead);
    this.#isTagContext = true;
    return tag;
  }

  /**
   * Reads the next data item as a semantic tag (major type 6), without advancing the reader.
   *
   * @returns The decoded value.
   */
  peekTag(): CborTag {
    const { tag } = this.#peekTagCore();
    return tag;
  }

  // Private methods.

  /**
   * Peeks the next initial byte without advancing the data stream.
   *
   * @param expectedType If an expected type is given, the method will throw in the event of a major type mismatch.
   * @returns The next initial byte.
   */
  // eslint-disable-next-line complexity
  #peekInitialByte(expectedType?: CborMajorType): CborInitialByte {
    if (
      this.#currentFrame.definiteLength !== undefined &&
      this.#currentFrame.definiteLength - this.#currentFrame.itemsRead === 0
    )
      throw new CborInvalidOperationException('No more data items to read');

    if (this.#offset === this.#data.length) {
      if (this.#currentFrame.type === null && this.#currentFrame.definiteLength === undefined && this.#offset > 0)
        throw new CborInvalidOperationException('End of root-level. No more data items to read');

      throw new CborContentException(UNEXPECTED_END_OF_BUFFER_MSG);
    }

    const nextByte = CborInitialByte.from(this.#data[this.#offset]);

    switch (this.#currentFrame.type) {
      case CborMajorType.ByteString:
      case CborMajorType.Utf8String:
        // Indefinite-length string contexts allow two possible data items:
        // 1) Definite-length string chunks of the same major type OR
        // 2) a break byte denoting the end of the indefinite-length string context.
        if (
          nextByte.getInitialByte() === CborInitialByte.IndefiniteLengthBreakByte ||
          (nextByte.getMajorType() === this.#currentFrame.type &&
            nextByte.getAdditionalInfo() !== CborAdditionalInfo.IndefiniteLength)
        ) {
          break;
        }

        throw new CborContentException(
          `Indefinite length string contains invalid data item, ${nextByte.getMajorType()}`
        );
    }

    if (expectedType && expectedType !== nextByte.getMajorType())
      throw new CborInvalidOperationException(
        `Major type mismatch, expected type ${expectedType} but got ${nextByte.getMajorType()}`
      );

    return nextByte;
  }

  /**
   * Peeks the next initial byte without advancing the data stream.
   *
   * @param buffer the buffer where to get the initial byte from.
   * @param expectedType If an expected type is given, the method will throw in the event of a major type mismatch.
   * @returns The next initial byte.
   */
  static #peekNextInitialByte(buffer: Uint8Array, expectedType?: CborMajorType): CborInitialByte {
    CborReader.ensureReadCapacityInArray(buffer, 1);
    const header = CborInitialByte.from(buffer[0]);

    if (header.getInitialByte() !== CborInitialByte.IndefiniteLengthBreakByte && header.getMajorType() !== expectedType)
      throw new CborContentException('Indefinite length string contains invalid data item');

    return header;
  }

  /** Checks whether the next initial byte is a break byte. */
  #validateNextByteIsBreakByte() {
    const result = this.#peekInitialByte();

    if (result.getInitialByte() !== CborInitialByte.IndefiniteLengthBreakByte)
      throw new CborInvalidOperationException('Not at end of indefinite length data item');
  }

  /**
   * Goes one level down into the stack.
   *
   * @param majorType The current major type.
   * @param definiteLength The definite length of the current type (if applicable).
   */
  #pushDataItem(majorType: CborMajorType, definiteLength?: number): void {
    const frame: StackFrame = {
      currentKeyOffset: this.#currentFrame.currentKeyOffset,
      definiteLength: this.#currentFrame.definiteLength,
      frameOffset: this.#currentFrame.frameOffset,
      itemsRead: this.#currentFrame.itemsRead,
      type: this.#currentFrame.type
    };

    this.#nestedItems.push(frame);

    this.#currentFrame.type = majorType;
    this.#currentFrame.definiteLength = definiteLength;
    this.#currentFrame.itemsRead = 0;
    this.#currentFrame.frameOffset = this.#offset;
    this.#isTagContext = false;
    this.#currentFrame.currentKeyOffset = null;
  }

  /**
   * Goes one level up on the stack.
   *
   * @param expectedType The expected major type.
   */
  #popDataItem(expectedType: CborMajorType): void {
    if (this.#currentFrame.type === null || this.#nestedItems.length <= 0)
      throw new CborInvalidOperationException('Is at root context');

    if (expectedType !== this.#currentFrame.type)
      throw new CborInvalidOperationException(
        `Pop major type mismatch, expected ${expectedType} but got ${this.#currentFrame.type}`
      );

    if (
      this.#currentFrame.definiteLength !== undefined &&
      this.#currentFrame.definiteLength - this.#currentFrame.itemsRead > 0
    )
      throw new CborInvalidOperationException('Not at end of definite length data item');

    if (this.#isTagContext) throw new CborContentException('Tag not followed by value');

    const frame = this.#nestedItems.pop();

    this.#restoreStackFrame(frame!);
  }

  /**
   * Restores the stack after popping the current stack frame.
   *
   * @param frame the stack frame.
   */
  #restoreStackFrame(frame: StackFrame) {
    this.#currentFrame.type = frame.type;
    this.#currentFrame.frameOffset = frame.frameOffset;
    this.#currentFrame.definiteLength = frame.definiteLength;
    this.#currentFrame.itemsRead = frame.itemsRead;
    this.#currentFrame.currentKeyOffset = frame.currentKeyOffset;
    this.#cachedState = CborReaderState.Undefined;
  }

  /**
   * Gets the remaining bytes in the buffer.
   *
   * @returns An array with the remaining bytes in the buffer.
   */
  #getRemainingBytes(): Uint8Array {
    return this.#data.slice(this.#offset);
  }

  /** Advances the data item counters. */
  #advanceDataItemCounters() {
    ++this.#currentFrame.itemsRead;
    this.#isTagContext = false;
  }

  /**
   * Advances the buffer pointer.
   *
   * @param length The number of bytes to advance the buffer.
   */
  #advanceBuffer(length: number) {
    if (this.#offset + length > this.#data.length) throw new CborContentException('Buffer offset out of bounds');
    this.#offset += length;
    this.#cachedState = CborReaderState.Undefined;
  }

  /**
   * Asserts that there are enough bytes remaining in the buffer to read the give amount of bytes.
   *
   * @param bytesToRead The number of bytes to read.
   */
  #ensureReadCapacity(bytesToRead: number) {
    if (this.#data.length - this.#offset < bytesToRead) {
      throw new CborContentException(UNEXPECTED_END_OF_BUFFER_MSG);
    }
  }

  /**
   * Asserts that there are enough bytes remaining in the buffer to read the give amount of bytes.
   *
   * @param data The array to read the bytes from.
   * @param bytesToRead The number of bytes to read.
   */
  static ensureReadCapacityInArray(data: Uint8Array, bytesToRead: number) {
    if (data.length < bytesToRead) {
      throw new CborContentException(UNEXPECTED_END_OF_BUFFER_MSG);
    }
  }

  /**
   * Reads the next CBOR token, without advancing the reader.
   *
   * @returns An object that represents the current CBOR reader state.
   */
  // eslint-disable-next-line sonarjs/cognitive-complexity,complexity
  #peekStateCore(): CborReaderState {
    if (
      this.#currentFrame.definiteLength !== undefined &&
      this.#currentFrame.definiteLength - this.#currentFrame.itemsRead === 0
    ) {
      // is at the end of a definite-length context
      if (this.#currentFrame.type === null) return CborReaderState.Finished;

      switch (this.#currentFrame.type) {
        case CborMajorType.Array:
          return CborReaderState.EndArray;
        case CborMajorType.Map:
          return CborReaderState.EndMap;
        default:
          throw new CborInvalidOperationException('Invalid CBOR major type pushed to stack.');
      }
    }

    if (this.#offset === this.#data.length) {
      if (this.#currentFrame.type === null && this.#currentFrame.definiteLength === undefined) {
        return CborReaderState.Finished;
      }

      throw new CborInvalidOperationException(UNEXPECTED_END_OF_BUFFER_MSG);
    }

    // peek the next initial byte
    const initialByte = CborInitialByte.from(this.#data[this.#offset]);

    if (initialByte.getInitialByte() === CborInitialByte.IndefiniteLengthBreakByte) {
      if (this.#isTagContext) {
        throw new CborContentException('Tag not followed by value');
      }

      if (this.#currentFrame.definiteLength === undefined) {
        switch (this.#currentFrame.type) {
          case null:
            // found a break byte at the end of a root-level data item sequence
            throw new CborContentException('Unexpected break byte');
          case CborMajorType.ByteString:
            return CborReaderState.EndIndefiniteLengthByteString;
          case CborMajorType.Utf8String:
            return CborReaderState.EndIndefiniteLengthTextString;
          case CborMajorType.Array:
            return CborReaderState.EndArray;
          case CborMajorType.Map: {
            if (this.#currentFrame.itemsRead % 2 === 0) return CborReaderState.EndMap;

            throw new CborContentException('Key missing value');
          }
          default:
            throw new CborInvalidOperationException('Invalid CBOR major type pushed to stack.');
        }
      } else {
        throw new CborContentException('Unexpected break byte');
      }
    }

    if (this.#currentFrame.type !== null && this.#currentFrame.definiteLength !== null) {
      // is at indefinite-length nested data item
      switch (this.#currentFrame.type) {
        case CborMajorType.ByteString:
        case CborMajorType.Utf8String:
          if (initialByte.getMajorType() !== this.#currentFrame.type) {
            throw new CborContentException('Indefinite length string contains invalid data item');
          }
          break;
      }
    }

    switch (initialByte.getMajorType()) {
      case CborMajorType.UnsignedInteger:
        return CborReaderState.UnsignedInteger;
      case CborMajorType.NegativeInteger:
        return CborReaderState.NegativeInteger;
      case CborMajorType.ByteString:
        return initialByte.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength
          ? CborReaderState.StartIndefiniteLengthByteString
          : CborReaderState.ByteString;
      case CborMajorType.Utf8String:
        return initialByte.getAdditionalInfo() === CborAdditionalInfo.IndefiniteLength
          ? CborReaderState.StartIndefiniteLengthTextString
          : CborReaderState.TextString;
      case CborMajorType.Array:
        return CborReaderState.StartArray;
      case CborMajorType.Map:
        return CborReaderState.StartMap;
      case CborMajorType.Tag:
        return CborReaderState.Tag;
      case CborMajorType.Simple:
        return CborReader.mapSimpleValueDataToReaderState(initialByte.getAdditionalInfo());
      default:
        throw new CborContentException('Invalid CBOR major type.');
    }
  }

  /**
   * Maps simple value data to reader state.
   *
   * @param value The value.
   */
  static mapSimpleValueDataToReaderState(value: CborAdditionalInfo): CborReaderState {
    // https://tools.ietf.org/html/rfc7049#section-2.3
    switch (value) {
      case CborAdditionalInfo.AdditionalNull:
        return CborReaderState.Null;
      case CborAdditionalInfo.AdditionalFalse:
      case CborAdditionalInfo.AdditionalTrue:
        return CborReaderState.Boolean;
      case CborAdditionalInfo.Additional16BitData:
        return CborReaderState.HalfPrecisionFloat;
      case CborAdditionalInfo.Additional32BitData:
        return CborReaderState.SinglePrecisionFloat;
      case CborAdditionalInfo.Additional64BitData:
        return CborReaderState.DoublePrecisionFloat;
      default:
        return CborReaderState.SimpleValue;
    }
  }

  /**
   * Peeks the definite length for given data item.
   *
   * @param header The initial byte header.
   * @param data The data stream.
   * @returns An object with the definite length and the bytes read.
   */
  static #peekDefiniteLength(header: CborInitialByte, data: Uint8Array): { length: number; bytesRead: number } {
    const { unsignedInt: length, bytesRead } = CborReader.#decodeUnsignedInteger(header, data);
    return { bytesRead, length: Number(length) };
  }

  /**
   * Peeks an unsigned integer from the data stream.
   *
   * @returns An object with the unsigned int and the bytes read.
   */
  #peekUnsignedInteger(): { unsignedInt: bigint; bytesRead: number } {
    const header: CborInitialByte = this.#peekInitialByte();

    switch (header.getMajorType()) {
      case CborMajorType.UnsignedInteger: {
        return CborReader.#decodeUnsignedInteger(header, this.#getRemainingBytes());
      }
      case CborMajorType.NegativeInteger: {
        throw new CborContentException('Integer overflow');
      }
      default:
        throw new CborInvalidOperationException(
          `Reader type mismatch, expected ${CborMajorType.UnsignedInteger} but got ${header.getMajorType()}`
        );
    }
  }

  /**
   * Peeks a signed integer from the data stream.
   *
   * @returns An object with the signed int and the bytes read.
   */
  #peekSignedInteger(): { signedInt: bigint; bytesRead: number } {
    const header: CborInitialByte = this.#peekInitialByte();

    switch (header.getMajorType()) {
      case CborMajorType.UnsignedInteger: {
        const { unsignedInt: signedInt, bytesRead } = CborReader.#decodeUnsignedInteger(
          header,
          this.#getRemainingBytes()
        );

        return { bytesRead, signedInt: BigInt(signedInt) };
      }
      case CborMajorType.NegativeInteger: {
        const { unsignedInt, bytesRead } = CborReader.#decodeUnsignedInteger(header, this.#getRemainingBytes());

        return { bytesRead, signedInt: BigInt(-1) - unsignedInt };
      }
      default:
        throw new CborInvalidOperationException(
          `Reader type mismatch, expected ${CborMajorType.UnsignedInteger} or ${
            CborMajorType.NegativeInteger
          } but got ${header.getMajorType()}`
        );
    }
  }

  /**
   * Reads the contents of a indefinite length bytearray or text and returns all the chunks concatenated.
   *
   * @param type The type of the indefinite array.
   * @returns The concatenated array.
   */
  #readIndefiniteLengthByteStringConcatenated(type: CborMajorType): {
    val: Uint8Array;
    encodingLength: number;
  } {
    const data = this.#getRemainingBytes();
    let concat = Buffer.from([]);
    let encodingLength = 0;

    let i = 1; // skip the indefinite-length initial byte

    let nextInitialByte = CborReader.#peekNextInitialByte(data.slice(i), type);

    while (nextInitialByte.getInitialByte() !== CborInitialByte.IndefiniteLengthBreakByte) {
      const { length: chunkLength, bytesRead } = CborReader.#peekDefiniteLength(nextInitialByte, data.slice(i));
      const payloadSize = bytesRead + Number(chunkLength);

      concat = Buffer.concat([concat, this.#data.slice(i + (payloadSize - chunkLength), i + payloadSize)]);

      i += payloadSize;

      nextInitialByte = CborReader.#peekNextInitialByte(data.slice(i), type);
    }

    encodingLength = i + 1; // include the break byte

    return { encodingLength, val: new Uint8Array(concat) };
  }

  /**
   * Peeks the core tag.
   *
   * @returns the Core tag and the bytes that would be consumed from the stream.
   */
  #peekTagCore(): { tag: CborTag; bytesRead: number } {
    const header: CborInitialByte = this.#peekInitialByte(CborMajorType.Tag);
    const { unsignedInt: result, bytesRead } = CborReader.#decodeUnsignedInteger(header, this.#getRemainingBytes());

    return { bytesRead, tag: Number(result) as CborTag };
  }

  /**
   * Decodes an unsigned integer.
   *
   * https://tools.ietf.org/html/rfc7049#section-2.1
   *
   * @param header The header byte.
   * @param data the data.
   */
  static #decodeUnsignedInteger(header: CborInitialByte, data: Uint8Array): { unsignedInt: bigint; bytesRead: number } {
    if ((header.getInitialByte() & CborInitialByte.AdditionalInformationMask) < CborAdditionalInfo.Additional8BitData)
      return { bytesRead: 1, unsignedInt: BigInt(header.getAdditionalInfo()) };

    switch (header.getAdditionalInfo()) {
      case CborAdditionalInfo.Additional8BitData: {
        CborReader.ensureReadCapacityInArray(data, 2);

        return { bytesRead: 2, unsignedInt: BigInt(data[1]) };
      }
      case CborAdditionalInfo.Additional16BitData: {
        CborReader.ensureReadCapacityInArray(data, 3);

        const buffer = Buffer.from(data.slice(1));
        const val = buffer.readUInt16BE();

        return { bytesRead: 3, unsignedInt: BigInt(val) };
      }
      case CborAdditionalInfo.Additional32BitData: {
        CborReader.ensureReadCapacityInArray(data, 5);

        const buffer = Buffer.from(data.slice(1));
        const val = buffer.readUInt32BE();

        return { bytesRead: 5, unsignedInt: BigInt(val) };
      }
      case CborAdditionalInfo.Additional64BitData: {
        CborReader.ensureReadCapacityInArray(data, 9);

        const buffer = Buffer.from(data.slice(1, 9));

        let result = BigInt(0);

        for (const element of buffer) {
          result = (result << BigInt(8)) + BigInt(element);
        }

        return { bytesRead: 9, unsignedInt: result };
      }
      default:
        throw new CborContentException('Invalid integer encoding');
    }
  }

  /**
   * Skips the next item in the current nested level
   *
   * @param initialDepth The starting depth.
   * @returns the depth after the node has been skipped.
   */
  // eslint-disable-next-line complexity
  #skipNextNode(initialDepth: number): number {
    let state: CborReaderState;
    let depth = initialDepth;

    // peek, skipping any tags we might encounter
    while ((state = this.#peekStateCore()) === CborReaderState.Tag) this.readTag();

    switch (state) {
      case CborReaderState.UnsignedInteger:
        this.readUInt();
        break;

      case CborReaderState.NegativeInteger:
        this.readCborNegativeIntegerRepresentation();
        break;

      case CborReaderState.ByteString:
        this.readByteString();
        break;

      case CborReaderState.TextString:
        this.readTextString();
        break;

      case CborReaderState.StartIndefiniteLengthByteString:
        this.readStartIndefiniteLengthByteString();
        depth++;
        break;

      case CborReaderState.EndIndefiniteLengthByteString:
        this.readEndIndefiniteLengthByteString();
        depth--;
        break;

      case CborReaderState.StartIndefiniteLengthTextString:
        this.readStartIndefiniteLengthTextString();
        depth++;
        break;

      case CborReaderState.EndIndefiniteLengthTextString:
        if (depth === 0) throw new CborInvalidOperationException(`Skip invalid state: ${state}`);

        this.readEndIndefiniteLengthTextString();
        depth--;
        break;

      case CborReaderState.StartArray:
        this.readStartArray();
        depth++;
        break;

      case CborReaderState.EndArray:
        if (depth === 0) throw new CborInvalidOperationException(`Skip invalid state: ${state}`);

        this.readEndArray();
        depth--;
        break;

      case CborReaderState.StartMap:
        this.readStartMap();
        depth++;
        break;

      case CborReaderState.EndMap:
        if (depth === 0) throw new CborInvalidOperationException(`Skip invalid state: ${state}`);

        this.readEndMap();
        depth--;
        break;

      case CborReaderState.HalfPrecisionFloat:
      case CborReaderState.SinglePrecisionFloat:
      case CborReaderState.DoublePrecisionFloat:
        this.readDouble();
        break;

      case CborReaderState.Null:
      case CborReaderState.Boolean:
      case CborReaderState.SimpleValue:
        this.readSimpleValue();
        break;

      default:
        throw new CborInvalidOperationException(`Skip invalid state: ${state}`);
    }

    return depth;
  }
}
