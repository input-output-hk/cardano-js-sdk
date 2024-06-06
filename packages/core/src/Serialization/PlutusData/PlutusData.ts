import * as Cardano from '../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborReaderState, CborTag, CborWriter } from '../CBOR/index.js';
import { ConstrPlutusData } from './ConstrPlutusData.js';
import { HexBlob } from '@cardano-sdk/util';
import { NotImplementedError } from '../../errors.js';
import { PlutusDataKind } from './PlutusDataKind.js';
import { PlutusList } from './PlutusList.js';
import { PlutusMap } from './PlutusMap.js';
import { bytesToHex } from '../../util/misc/index.js';

const MAX_WORD64 = 18_446_744_073_709_551_615n;
const INDEFINITE_BYTE_STRING = new Uint8Array([95]);
const MAX_BYTE_STRING_CHUNK_SIZE = 64;
const HASH_LENGTH_IN_BYTES = 32;

/**
 * A type corresponding to the Plutus Core Data datatype.
 *
 * The point of this type is to be opaque as to ensure that it is only used in ways
 * that plutus scripts can handle.
 *
 * Use this type to build any data structures that you want to be representable on-chain.
 */
export class PlutusData {
  #map: PlutusMap | undefined = undefined;
  #list: PlutusList | undefined = undefined;
  #integer: bigint | undefined = undefined;
  #bytes: Uint8Array | undefined = undefined;
  #constr: ConstrPlutusData | undefined = undefined;
  #kind: PlutusDataKind = PlutusDataKind.ConstrPlutusData;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes this PlutusData instance into its CBOR representation as a Uint8Array.
   *
   * @returns The CBOR representation of this instance as a Uint8Array.
   */
  // eslint-disable-next-line complexity
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    let cbor: HexBlob;

    switch (this.#kind) {
      case PlutusDataKind.ConstrPlutusData: {
        cbor = this.#constr!.toCbor();
        break;
      }
      case PlutusDataKind.Map: {
        cbor = this.#map!.toCbor();
        break;
      }
      case PlutusDataKind.List: {
        cbor = this.#list!.toCbor();
        break;
      }
      // Note [The 64-byte limit]: See https://github.com/input-output-hk/plutus/blob/1f31e640e8a258185db01fa899da63f9018c0e85/plutus-core/plutus-core/src/PlutusCore/Data.hs#L61-L105
      // If the bytestring is >64bytes, we encode it as indefinite-length bytestrings with 64-byte chunks. We have to write
      // our own encoders/decoders so we can produce chunks of the right size and check
      // the sizes when we decode.
      case PlutusDataKind.Bytes: {
        const writer = new CborWriter();

        if (this.#bytes!.length <= MAX_BYTE_STRING_CHUNK_SIZE) {
          writer.writeByteString(this.#bytes!);
        } else {
          writer.writeEncodedValue(INDEFINITE_BYTE_STRING);

          for (let i = 0; i < this.#bytes!.length; i += MAX_BYTE_STRING_CHUNK_SIZE) {
            const chunk = this.#bytes!.slice(i, i + MAX_BYTE_STRING_CHUNK_SIZE);
            writer.writeByteString(chunk);
          }

          writer.writeEndArray();
        }

        cbor = bytesToHex(writer.encode());
        break;
      }
      // For integers, we have two cases. Small integers (<64bits) can be encoded normally. Big integers are already
      // encoded *with a byte string*. The spec allows this to be an indefinite-length bytestring. Again, we need to
      // write some manual encoders/decoders.
      case PlutusDataKind.Integer: {
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
        throw new Error('Unsupported PlutusData kind');
    }

    return cbor;
  }

  /**
   * Deserializes a PlutusData instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a Uint8Array.
   * @returns A PlutusData instance.
   */
  // eslint-disable-next-line max-statements
  static fromCbor(cbor: HexBlob): PlutusData {
    const data = new PlutusData();
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
            data.#integer = PlutusData.bufferToBigint(bytes);
            data.#kind = PlutusDataKind.Integer;
            break;
          }
          case CborTag.NegativeBigNum: {
            reader.readTag();
            const bytes = reader.readByteString();
            data.#integer = PlutusData.bufferToBigint(bytes) * -1n;
            data.#kind = PlutusDataKind.Integer;
            break;
          }
          default: {
            data.#constr = ConstrPlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
            data.#kind = PlutusDataKind.ConstrPlutusData;
          }
        }
        break;
      }
      case CborReaderState.NegativeInteger:
      case CborReaderState.UnsignedInteger: {
        data.#integer = reader.readInt();
        data.#kind = PlutusDataKind.Integer;
        break;
      }
      case CborReaderState.StartIndefiniteLengthByteString:
      case CborReaderState.ByteString: {
        data.#bytes = reader.readByteString();
        data.#kind = PlutusDataKind.Bytes;
        break;
      }
      case CborReaderState.StartArray: {
        data.#list = PlutusList.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        data.#kind = PlutusDataKind.List;
        break;
      }
      case CborReaderState.StartMap: {
        data.#map = PlutusMap.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        data.#kind = PlutusDataKind.Map;
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
   * Creates a Core Tx object from the current PlutusData object.
   *
   * @returns The PlutusData object.
   */
  toCore(): Cardano.PlutusData {
    switch (this.#kind) {
      case PlutusDataKind.Bytes:
        return this.#bytes!;
      case PlutusDataKind.ConstrPlutusData: {
        const constrPlutusData = this.#constr;
        return {
          cbor: this.toCbor(),
          constructor: constrPlutusData!.getAlternative(),
          fields: PlutusData.mapToCorePlutusList(constrPlutusData!.getData())
        } as Cardano.ConstrPlutusData;
      }
      case PlutusDataKind.Integer:
        return this.#integer!;
      case PlutusDataKind.List:
        return PlutusData.mapToCorePlutusList(this.#list!);
      case PlutusDataKind.Map: {
        const plutusMap = this.#map!;
        const coreMap = new Map<Cardano.PlutusData, Cardano.PlutusData>();
        const keys = plutusMap.getKeys();
        for (let i = 0; i < keys.getLength(); i++) {
          const key = keys.get(i);
          coreMap.set(key.toCore(), plutusMap.get(key)!.toCore());
        }
        return { cbor: this.toCbor(), data: coreMap } as Cardano.PlutusMap;
      }
      default:
        throw new NotImplementedError(`PlutusData mapping for kind ${this.#kind}`); // Probably can't happen
    }
  }

  /**
   * Computes the plutus data hash.
   *
   * @returns the plutus data hash.
   */
  hash(): Crypto.Hash32ByteBase16 {
    const hash = Crypto.blake2b(HASH_LENGTH_IN_BYTES).update(Buffer.from(this.toCbor(), 'hex')).digest();

    return Crypto.Hash32ByteBase16(HexBlob.fromBytes(hash));
  }

  /**
   * Creates a PlutusData object from the given Core PlutusData object.
   *
   * @param data The core PlutusData object.
   */
  static fromCore(data: Cardano.PlutusData) {
    if (Cardano.util.isPlutusBoundedBytes(data)) {
      return PlutusData.newBytes(data);
    } else if (Cardano.util.isPlutusBigInt(data)) {
      return PlutusData.newInteger(data);
    }

    if (data.cbor) return PlutusData.fromCbor(data.cbor);

    if (Cardano.util.isPlutusList(data)) {
      return PlutusData.newList(PlutusData.mapToPlutusList(data.items));
    } else if (Cardano.util.isPlutusMap(data)) {
      const plutusMap = new PlutusMap();
      for (const [key, val] of data.data) {
        plutusMap.insert(PlutusData.fromCore(key), PlutusData.fromCore(val));
      }
      return PlutusData.newMap(plutusMap);
    } else if (Cardano.util.isConstrPlutusData(data)) {
      const alternative = data.constructor;
      const constrPlutusData = new ConstrPlutusData(alternative, PlutusData.mapToPlutusList(data.fields.items));

      return PlutusData.newConstrPlutusData(constrPlutusData);
    }

    throw new NotImplementedError('PlutusData type not implemented');
  }

  /**
   * Create a PlutusData type from the given ConstrPlutusData.
   *
   * @param constrPlutusData The ConstrPlutusData to be 'cast' as PlutusData.
   * @returns The ConstrPlutusData as a PlutusData object.
   */
  static newConstrPlutusData(constrPlutusData: ConstrPlutusData): PlutusData {
    const data = new PlutusData();

    data.#constr = constrPlutusData;
    data.#kind = PlutusDataKind.ConstrPlutusData;

    return data;
  }

  /**
   * Create a PlutusData type from the given PlutusMap.
   *
   * @param map The PlutusMap to be 'cast' as PlutusData.
   * @returns The PlutusMap as a PlutusData object.
   */
  static newMap(map: PlutusMap): PlutusData {
    const data = new PlutusData();

    data.#map = map;
    data.#kind = PlutusDataKind.Map;

    return data;
  }

  /**
   * Create a PlutusData type from the given PlutusList.
   *
   * @param list The PlutusList to be 'cast' as PlutusData.
   * @returns The PlutusMap as a PlutusList object.
   */
  static newList(list: PlutusList): PlutusData {
    const data = new PlutusData();

    data.#list = list;
    data.#kind = PlutusDataKind.List;

    return data;
  }

  /**
   * Create a PlutusData type from the given bigint.
   *
   * @param integer The bigint to be 'cast' as PlutusData.
   * @returns The bigint as a PlutusList object.
   */
  static newInteger(integer: bigint): PlutusData {
    const data = new PlutusData();

    data.#integer = integer;
    data.#kind = PlutusDataKind.Integer;

    return data;
  }

  /**
   * Create a PlutusData type from the given Uint8Array.
   *
   * @param bytes The Uint8Array to be 'cast' as PlutusData.
   * @returns The Uint8Array as a PlutusList object.
   */
  static newBytes(bytes: Uint8Array): PlutusData {
    const data = new PlutusData();

    data.#bytes = bytes;
    data.#kind = PlutusDataKind.Bytes;

    return data;
  }

  /**
   * Gets the underlying type of this PlutusData instance.
   *
   * @returns The underlying type.
   */
  getKind(): PlutusDataKind {
    return this.#kind;
  }

  /**
   * Down casts this PlutusData instance as a ConstrPlutusData instance.
   *
   * @returns The ConstrPlutusData instance or undefined if it can not be 'down cast'.
   */
  asConstrPlutusData(): ConstrPlutusData | undefined {
    return this.#constr;
  }

  /**
   * Down casts this PlutusData instance as a PlutusMap instance.
   *
   * @returns The PlutusMap instance or undefined if it can not be 'down cast'.
   */
  asMap(): PlutusMap | undefined {
    return this.#map;
  }

  /**
   * Down casts this PlutusData instance as a PlutusList instance.
   *
   * @returns The PlutusList instance or undefined if it can not be 'down cast'.
   */
  asList(): PlutusList | undefined {
    return this.#list;
  }

  /**
   * Down casts this PlutusData instance as a bigint instance.
   *
   * @returns The bigint value or undefined if it can not be 'down cast'.
   */
  asInteger(): bigint | undefined {
    return this.#integer;
  }

  /**
   * Down casts this PlutusData instance as a Uint8Array instance.
   *
   * @returns The Uint8Array or undefined if it can not be 'down cast'.
   */
  asBoundedBytes(): Uint8Array | undefined {
    return this.#bytes;
  }

  /**
   * Indicates whether some other PlutusData is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  // eslint-disable-next-line complexity
  equals(other: PlutusData): boolean {
    switch (this.#kind) {
      case PlutusDataKind.Bytes:
        if (this.#bytes && other.#bytes) {
          return (
            this.#bytes!.length === other.#bytes!.length &&
            this.#bytes!.every((value, index) => value === other.#bytes![index])
          );
        }
        return false;
      case PlutusDataKind.Integer:
        return this.#integer === other.#integer;
      case PlutusDataKind.ConstrPlutusData:
        if (this.#constr && other.#constr) {
          return this.#constr.equals(other.#constr);
        }
        return false;
      case PlutusDataKind.List:
        if (this.#list && other.#list) {
          return this.#list.equals(other.#list);
        }
        return false;
      case PlutusDataKind.Map:
        if (this.#map && other.#map) {
          return this.#map.equals(other.#map);
        }
        return false;
      default:
        return false;
    }
  }

  /**
   * Maps to PlutusList from a core plutus list.
   *
   * @param list The core plutus list.
   */
  private static mapToPlutusList(list: Cardano.PlutusData[]): PlutusList {
    const plutusList = new PlutusList();
    for (const listItem of list) {
      plutusList.add(PlutusData.fromCore(listItem));
    }
    return plutusList;
  }

  /**
   * Maps to Core plutus list from PlutusList.
   *
   * @param list The PlutusList
   */
  private static mapToCorePlutusList(list: PlutusList): Cardano.PlutusList {
    const items: Cardano.PlutusData[] = [];
    for (let i = 0; i < list.getLength(); i++) {
      const element = list.get(i);
      items.push(element.toCore());
    }
    return { cbor: list.toCbor(), items };
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
