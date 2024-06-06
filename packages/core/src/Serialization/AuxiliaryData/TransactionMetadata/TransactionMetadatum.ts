/* eslint-disable max-statements,complexity */
import { CborReader, CborReaderState, CborTag, CborWriter } from '../../CBOR/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { MetadatumList } from './MetadatumList.js';
import { MetadatumMap } from './MetadatumMap.js';
import { NotImplementedError, SerializationError, SerializationFailure } from '../../../errors.js';
import { TransactionMetadatumKind } from './TransactionMetadatumKind.js';
import { bytesToHex } from '../../../util/misc/index.js';
import type * as Cardano from '../../../Cardano/index.js';

const MAX_WORD64 = 18_446_744_073_709_551_615n;

const check64Length = (metadatum: string | Uint8Array): void => {
  const len = typeof metadatum === 'string' ? Buffer.from(metadatum, 'utf8').length : metadatum.length;
  if (len > 64)
    throw new SerializationError(
      SerializationFailure.MaxLengthLimit,
      `Metadatum value '${metadatum}' is too long. Length is ${len}. Max length is 64 bytes`
    );
};

/**
 * Transaction metadatum (or simply metadata) is supplementary information that can
 * be attached to a transaction. Unlike the core components of a transaction
 * (such as inputs, outputs, and witnesses), metadata isn't used to determine transaction
 * validity. Instead, it provides a way to embed additional, arbitrary data into
 * the blockchain.
 */
export class TransactionMetadatum {
  #map: MetadatumMap | undefined = undefined;
  #list: MetadatumList | undefined = undefined;
  #integer: bigint | undefined = undefined;
  #bytes: Uint8Array | undefined = undefined;
  #text: string | undefined = undefined;
  #kind: TransactionMetadatumKind = TransactionMetadatumKind.Map;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes this TransactionMetadatum instance into its CBOR representation as a HexBlob.
   *
   * @returns The CBOR representation of this instance as a HexBlob.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    let cbor: HexBlob;

    switch (this.#kind) {
      case TransactionMetadatumKind.Map: {
        cbor = this.#map!.toCbor();
        break;
      }
      case TransactionMetadatumKind.List: {
        cbor = this.#list!.toCbor();
        break;
      }
      case TransactionMetadatumKind.Bytes: {
        const writer = new CborWriter();

        check64Length(this.#bytes!);

        writer.writeByteString(this.#bytes!);
        cbor = bytesToHex(writer.encode());
        break;
      }
      case TransactionMetadatumKind.Text: {
        const writer = new CborWriter();

        check64Length(this.#text!);

        writer.writeTextString(this.#text!);
        cbor = bytesToHex(writer.encode());
        break;
      }
      // For integers, we have two cases. Small integers (<64bits) can be encoded normally. Big integers are already
      // encoded *with a byte string*. The spec allows this to be an indefinite-length bytestring. Again, we need to
      // write some manual encoders/decoders.
      case TransactionMetadatumKind.Integer: {
        const writer = new CborWriter();
        // If it fits in a Word64, then it's less than 64 bits for sure, and we can just send it off
        // as a normal integer.
        if (
          (this.#integer! >= 0 && this.#integer! <= MAX_WORD64) ||
          (this.#integer! < 0 && this.#integer! >= -1n - MAX_WORD64)
        ) {
          writer.writeInt(this.#integer!);
        } else {
          // Otherwise, it would be encoded as a bignum anyway, so we manually do the bignum
          // encoding with a bytestring inside.
          writer.writeBigInteger(this.#integer!);
        }

        cbor = bytesToHex(writer.encode());
        break;
      }
      default:
        throw new Error('Unsupported TransactionMetadatum kind');
    }

    return cbor;
  }

  /**
   * Deserializes a TransactionMetadatum instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a Uint8Array.
   * @returns A TransactionMetadatum instance.
   */
  static fromCbor(cbor: HexBlob): TransactionMetadatum {
    const data = new TransactionMetadatum();
    const reader = new CborReader(cbor);

    const peekTokenType = reader.peekState();

    switch (peekTokenType) {
      case CborReaderState.Tag: {
        const tag = reader.peekTag();

        // eslint-disable-next-line sonarjs/no-nested-switch
        switch (tag) {
          case CborTag.UnsignedBigNum: {
            reader.readTag();
            const bytes = reader.readByteString();
            data.#integer = TransactionMetadatum.bufferToBigint(bytes);
            data.#kind = TransactionMetadatumKind.Integer;
            break;
          }
          case CborTag.NegativeBigNum: {
            reader.readTag();
            const bytes = reader.readByteString();
            data.#integer = TransactionMetadatum.bufferToBigint(bytes) * -1n;
            data.#kind = TransactionMetadatumKind.Integer;
            break;
          }
        }
        break;
      }
      case CborReaderState.NegativeInteger:
      case CborReaderState.UnsignedInteger: {
        data.#integer = reader.readInt();
        data.#kind = TransactionMetadatumKind.Integer;
        break;
      }
      case CborReaderState.StartIndefiniteLengthByteString:
      case CborReaderState.ByteString: {
        data.#bytes = reader.readByteString();
        data.#kind = TransactionMetadatumKind.Bytes;
        break;
      }
      case CborReaderState.StartIndefiniteLengthTextString:
      case CborReaderState.TextString: {
        data.#text = reader.readTextString();
        data.#kind = TransactionMetadatumKind.Text;
        break;
      }
      case CborReaderState.StartArray: {
        data.#list = MetadatumList.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        data.#kind = TransactionMetadatumKind.List;
        break;
      }
      case CborReaderState.StartMap: {
        data.#map = MetadatumMap.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        data.#kind = TransactionMetadatumKind.Map;
        break;
      }
      default: {
        throw new Error('Invalid Plutus Data');
      }
    }

    data.#originalBytes = cbor;

    return data;
  }

  /**
   * Creates a Core Tx object from the current TransactionMetadatum object.
   *
   * @returns The TransactionMetadatum object.
   */
  toCore(): Cardano.Metadatum {
    switch (this.#kind) {
      case TransactionMetadatumKind.Bytes:
        return new Uint8Array(this.#bytes!);
      case TransactionMetadatumKind.Text:
        return this.#text!;
      case TransactionMetadatumKind.Integer:
        return this.#integer!;
      case TransactionMetadatumKind.List:
        return TransactionMetadatum.mapToCoreMetadatumList(this.#list!);
      case TransactionMetadatumKind.Map: {
        const metadatumMap = this.#map!;
        const coreMap = new Map<Cardano.Metadatum, Cardano.Metadatum>();
        const keys = metadatumMap.getKeys();
        for (let i = 0; i < keys.getLength(); i++) {
          const key = keys.get(i);
          coreMap.set(key.toCore(), metadatumMap.get(key)!.toCore());
        }
        return coreMap;
      }
      default:
        throw new NotImplementedError(`TransactionMetadatum mapping for kind ${this.#kind}`); // Can't happen
    }
  }

  /**
   * Creates a TransactionMetadatum object from the given Core TransactionMetadatum object.
   *
   * @param metadatum The core TransactionMetadatum object.
   */
  static fromCore(metadatum: Cardano.Metadatum) {
    if (metadatum === null) throw new SerializationError(SerializationFailure.InvalidType);
    switch (typeof metadatum) {
      case 'number':
      case 'boolean':
      case 'undefined':
        throw new SerializationError(SerializationFailure.InvalidType);
      case 'bigint': {
        return TransactionMetadatum.newInteger(metadatum);
      }
      case 'string':
        check64Length(metadatum);
        return TransactionMetadatum.newText(metadatum);
      default: {
        if (Array.isArray(metadatum)) {
          const metadatumList = new MetadatumList();
          for (const metadataItem of metadatum) {
            metadatumList.add(TransactionMetadatum.fromCore(metadataItem));
          }
          return TransactionMetadatum.newList(metadatumList);
        } else if (ArrayBuffer.isView(metadatum)) {
          check64Length(metadatum);
          return TransactionMetadatum.newBytes(metadatum);
        }

        const metadataMap = new MetadatumMap();

        for (const [key, data] of metadatum.entries()) {
          metadataMap.insert(TransactionMetadatum.fromCore(key), TransactionMetadatum.fromCore(data));
        }
        return TransactionMetadatum.newMap(metadataMap);
      }
    }
  }

  /**
   * Create a TransactionMetadatum type from the given MetadatumMap.
   *
   * @param map The MetadatumMap to be 'cast' as TransactionMetadatum.
   * @returns The MetadatumMap as a TransactionMetadatum object.
   */
  static newMap(map: MetadatumMap): TransactionMetadatum {
    const data = new TransactionMetadatum();

    data.#map = map;
    data.#kind = TransactionMetadatumKind.Map;

    return data;
  }

  /**
   * Create a TransactionMetadatum type from the given MetadatumList.
   *
   * @param list The MetadatumList to be 'cast' as TransactionMetadatum.
   * @returns The MetadatumMap as a MetadatumList object.
   */
  static newList(list: MetadatumList): TransactionMetadatum {
    const data = new TransactionMetadatum();

    data.#list = list;
    data.#kind = TransactionMetadatumKind.List;

    return data;
  }

  /**
   * Create a TransactionMetadatum type from the given bigint.
   *
   * @param integer The bigint to be 'cast' as TransactionMetadatum.
   * @returns The bigint as a MetadatumList object.
   */
  static newInteger(integer: bigint): TransactionMetadatum {
    const data = new TransactionMetadatum();

    data.#integer = integer;
    data.#kind = TransactionMetadatumKind.Integer;

    return data;
  }

  /**
   * Create a TransactionMetadatum type from the given Uint8Array.
   *
   * @param bytes The Uint8Array to be 'cast' as TransactionMetadatum.
   * @returns The Uint8Array as a MetadatumList object.
   */
  static newBytes(bytes: Uint8Array): TransactionMetadatum {
    const data = new TransactionMetadatum();

    data.#bytes = bytes;
    data.#kind = TransactionMetadatumKind.Bytes;

    return data;
  }

  /**
   * Create a TransactionMetadatum type from the given string.
   *
   * @param text The string to be 'cast' as TransactionMetadatum.
   * @returns The string as a MetadatumList object.
   */
  static newText(text: string): TransactionMetadatum {
    const data = new TransactionMetadatum();

    data.#text = text;
    data.#kind = TransactionMetadatumKind.Text;

    return data;
  }

  /**
   * Gets the underlying type of this TransactionMetadatum instance.
   *
   * @returns The underlying type.
   */
  getKind(): TransactionMetadatumKind {
    return this.#kind;
  }

  /**
   * Down casts this TransactionMetadatum instance as a MetadatumMap instance.
   *
   * @returns The MetadatumMap instance or undefined if it can not be 'down cast'.
   */
  asMap(): MetadatumMap | undefined {
    return this.#map;
  }

  /**
   * Down casts this TransactionMetadatum instance as a MetadatumList instance.
   *
   * @returns The MetadatumList instance or undefined if it can not be 'down cast'.
   */
  asList(): MetadatumList | undefined {
    return this.#list;
  }

  /**
   * Down casts this TransactionMetadatum instance as a bigint instance.
   *
   * @returns The bigint value or undefined if it can not be 'down cast'.
   */
  asInteger(): bigint | undefined {
    return this.#integer;
  }

  /**
   * Down casts this TransactionMetadatum instance as a Uint8Array instance.
   *
   * @returns The Uint8Array or undefined if it can not be 'down cast'.
   */
  asBytes(): Uint8Array | undefined {
    return this.#bytes;
  }

  /**
   * Down casts this TransactionMetadatum instance as a string instance.
   *
   * @returns The string or undefined if it can not be 'down cast'.
   */
  asText(): string | undefined {
    return this.#text;
  }

  /**
   * Indicates whether some other TransactionMetadatum is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  // eslint-disable-next-line complexity
  equals(other: TransactionMetadatum): boolean {
    let result = false;
    switch (this.#kind) {
      case TransactionMetadatumKind.Bytes:
        if (this.#bytes && other.#bytes) {
          return (
            this.#bytes!.length === other.#bytes!.length &&
            this.#bytes!.every((value, index) => value === other.#bytes![index])
          );
        }
        return false;
      case TransactionMetadatumKind.Integer:
        return this.#integer === other.#integer;
      case TransactionMetadatumKind.Text:
        return this.#text === other.#text;
      case TransactionMetadatumKind.List:
        if (this.#list && other.#list) {
          return this.#list.equals(other.#list);
        }
        return false;
      case TransactionMetadatumKind.Map:
        if (this.#map && other.#map) {
          return this.#map.equals(other.#map);
        }
        return false;
      default:
        result = false;
    }

    return result;
  }

  /**
   * Maps to Core metadatum list from MetadatumList.
   *
   * @param list The MetadatumList
   */
  private static mapToCoreMetadatumList(list: MetadatumList): Cardano.Metadatum {
    const items: Cardano.Metadatum[] = [];
    for (let i = 0; i < list.getLength(); i++) {
      const element = list.get(i);
      items.push(element.toCore());
    }
    return items;
  }

  /**
   * Converts an Uint8Array to a bigint.
   *
   * @param buffer The buffer to be converted to bigint.
   * @returns The resulting bigint;
   */
  private static bufferToBigint(buffer: Uint8Array): bigint {
    let ret = 0n;
    for (const i of buffer.values()) {
      const bi = BigInt(i);
      // eslint-disable-next-line no-bitwise
      ret = (ret << 8n) + bi;
    }
    return ret;
  }
}
