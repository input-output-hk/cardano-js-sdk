import * as Cardano from '../../Cardano';
import { CborReader, CborReaderState, CborTag, CborWriter } from '../CBOR';
import { ConstrPlutusData } from './ConstrPlutusData';
import { HexBlob } from '@cardano-sdk/util';
import { NotImplementedError } from '../../errors';
import { PlutusDataKind } from './PlutusDataKind';
import { PlutusList } from './PlutusList';
import { PlutusMap } from './PlutusMap';
import { bytesToHex } from '../../util/misc';

const MAX_WORD64 = 18_446_744_073_709_551_615n;
const INDEFINITE_BYTE_STRING = new Uint8Array([95]);
const MAX_BYTE_STRING_CHUNK_SIZE = 64;

/**
 * A type corresponding to the Plutus Core Data datatype.
 *
 * The point of this type is to be opaque as to ensure that it is only used in ways
 * that plutus scripts can handle.
 *
 * Use this type to build any data structures that you want to be representable on-chain.
 */
export class PlutusData {
  private _map: PlutusMap | undefined = undefined;
  private _list: PlutusList | undefined = undefined;
  private _integer: bigint | undefined = undefined;
  private _bytes: Uint8Array | undefined = undefined;
  private _constr: ConstrPlutusData | undefined = undefined;
  private _kind: PlutusDataKind = PlutusDataKind.ConstrPlutusData;
  private _originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes this PlutusData instance into its CBOR representation as a Uint8Array.
   *
   * @returns The CBOR representation of this instance as a Uint8Array.
   */
  // eslint-disable-next-line complexity
  toCbor(): HexBlob {
    if (this._originalBytes) return this._originalBytes;

    let cbor: HexBlob;

    switch (this._kind) {
      case PlutusDataKind.ConstrPlutusData: {
        cbor = this._constr!.toCbor();
        break;
      }
      case PlutusDataKind.Map: {
        cbor = this._map!.toCbor();
        break;
      }
      case PlutusDataKind.List: {
        cbor = this._list!.toCbor();
        break;
      }
      // Note [The 64-byte limit]: See https://github.com/input-output-hk/plutus/blob/1f31e640e8a258185db01fa899da63f9018c0e85/plutus-core/plutus-core/src/PlutusCore/Data.hs#L61-L105
      // If the bytestring is >64bytes, we encode it as indefinite-length bytestrings with 64-byte chunks. We have to write
      // our own encoders/decoders so we can produce chunks of the right size and check
      // the sizes when we decode.
      case PlutusDataKind.Bytes: {
        const writer = new CborWriter();

        if (this._bytes!.length <= MAX_BYTE_STRING_CHUNK_SIZE) {
          writer.writeByteString(this._bytes!);
        } else {
          writer.writeEncodedValue(INDEFINITE_BYTE_STRING);

          for (let i = 0; i < this._bytes!.length; i += MAX_BYTE_STRING_CHUNK_SIZE) {
            const chunk = this._bytes!.slice(i, i + MAX_BYTE_STRING_CHUNK_SIZE);
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
          (this._integer! >= 0 && this._integer! <= MAX_WORD64) ||
          (this._integer! < 0 && this._integer! >= -1n - MAX_WORD64)
        ) {
          writer.writeInt(this._integer!);
        } else {
          // Otherwise, it would be encoded as a bignum anyway, so we manually do the bignum
          // encoding with a bytestring inside.
          writer.writeBigInteger(this._integer!);
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
            data._integer = PlutusData.bufferToBigint(bytes);
            data._kind = PlutusDataKind.Integer;
            break;
          }
          case CborTag.NegativeBigNum: {
            reader.readTag();
            const bytes = reader.readByteString();
            data._integer = PlutusData.bufferToBigint(bytes) * -1n;
            data._kind = PlutusDataKind.Integer;
            break;
          }
          default: {
            data._constr = ConstrPlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
            data._kind = PlutusDataKind.ConstrPlutusData;
          }
        }
        break;
      }
      case CborReaderState.NegativeInteger:
      case CborReaderState.UnsignedInteger: {
        data._integer = reader.readInt();
        data._kind = PlutusDataKind.Integer;
        break;
      }
      case CborReaderState.StartIndefiniteLengthByteString:
      case CborReaderState.ByteString: {
        data._bytes = reader.readByteString();
        data._kind = PlutusDataKind.Bytes;
        break;
      }
      case CborReaderState.StartArray: {
        data._list = PlutusList.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        data._kind = PlutusDataKind.List;
        break;
      }
      case CborReaderState.StartMap: {
        data._map = PlutusMap.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        data._kind = PlutusDataKind.Map;
        break;
      }
      default: {
        throw new Error('Invalid Plutus Data');
      }
    }

    data._originalBytes = cbor;

    return data;
  }

  /**
   * Creates a Core Tx object from the current PlutusData object.
   *
   * @returns The PlutusData object.
   */
  toCore(): Cardano.PlutusData {
    switch (this._kind) {
      case PlutusDataKind.Bytes:
        return this._bytes!;
      case PlutusDataKind.ConstrPlutusData: {
        const constrPlutusData = this._constr;
        return {
          cbor: this.toCbor(),
          constructor: constrPlutusData!.getAlternative(),
          fields: PlutusData.mapToCorePlutusList(constrPlutusData!.getData())
        } as Cardano.ConstrPlutusData;
      }
      case PlutusDataKind.Integer:
        return this._integer!;
      case PlutusDataKind.List:
        return PlutusData.mapToCorePlutusList(this._list!);
      case PlutusDataKind.Map: {
        const plutusMap = this._map!;
        const coreMap = new Map<Cardano.PlutusData, Cardano.PlutusData>();
        const keys = plutusMap.getKeys();
        for (let i = 0; i < keys.getLength(); i++) {
          const key = keys.get(i);
          coreMap.set(key.toCore(), plutusMap.get(key)!.toCore());
        }
        return { cbor: this.toCbor(), data: coreMap } as Cardano.PlutusMap;
      }
      default:
        throw new NotImplementedError(`PlutusData mapping for kind ${this._kind}`); // Probably can't happen
    }
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

    data._constr = constrPlutusData;
    data._kind = PlutusDataKind.ConstrPlutusData;

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

    data._map = map;
    data._kind = PlutusDataKind.Map;

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

    data._list = list;
    data._kind = PlutusDataKind.List;

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

    data._integer = integer;
    data._kind = PlutusDataKind.Integer;

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

    data._bytes = bytes;
    data._kind = PlutusDataKind.Bytes;

    return data;
  }

  /**
   * Gets the underlying type of this PlutusData instance.
   *
   * @returns The underlying type.
   */
  getKind(): PlutusDataKind {
    return this._kind;
  }

  /**
   * Down casts this PlutusData instance as a ConstrPlutusData instance.
   *
   * @returns The ConstrPlutusData instance or undefined if it can not be 'down cast'.
   */
  asConstrPlutusData(): ConstrPlutusData | undefined {
    return this._constr;
  }

  /**
   * Down casts this PlutusData instance as a PlutusMap instance.
   *
   * @returns The PlutusMap instance or undefined if it can not be 'down cast'.
   */
  asMap(): PlutusMap | undefined {
    return this._map;
  }

  /**
   * Down casts this PlutusData instance as a PlutusList instance.
   *
   * @returns The PlutusList instance or undefined if it can not be 'down cast'.
   */
  asList(): PlutusList | undefined {
    return this._list;
  }

  /**
   * Down casts this PlutusData instance as a bigint instance.
   *
   * @returns The bigint value or undefined if it can not be 'down cast'.
   */
  asInteger(): bigint | undefined {
    return this._integer;
  }

  /**
   * Down casts this PlutusData instance as a Uint8Array instance.
   *
   * @returns The Uint8Array or undefined if it can not be 'down cast'.
   */
  asBoundedBytes(): Uint8Array | undefined {
    return this._bytes;
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
