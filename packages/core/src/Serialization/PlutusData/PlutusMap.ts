import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { PlutusData } from './PlutusData';
import { PlutusList } from './PlutusList';
import { bytesToHex, hexToBytes } from '../../util/misc';

/**
 * Represents a Map of Plutus data.
 */
export class PlutusMap {
  private readonly _map = new Map<PlutusData, PlutusData>();
  private _useIndefiniteEncoding = false;

  /**
   * Serializes this PlutusMap instance into its CBOR representation as a Uint8Array.
   *
   * @returns The CBOR representation of this instance as a Uint8Array.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this._useIndefiniteEncoding) {
      writer.writeStartMap();
    } else {
      writer.writeStartMap(this._map.size);
    }

    for (const [key, value] of this._map.entries()) {
      writer.writeEncodedValue(hexToBytes(key.toCbor()));
      writer.writeEncodedValue(hexToBytes(value.toCbor()));
    }

    if (this._useIndefiniteEncoding) writer.writeEndMap();

    return HexBlob.fromBytes(writer.encode());
  }

  /**
   * Deserializes a PlutusMap instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a Uint8Array.
   * @returns A PlutusMap instance.
   */
  static fromCbor(cbor: HexBlob): PlutusMap {
    const map = new PlutusMap();
    const reader = new CborReader(cbor);

    const size = reader.readStartMap();

    if (size === null) map._useIndefiniteEncoding = true;

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = PlutusData.fromCbor(bytesToHex(reader.readEncodedValue()));
      const value = PlutusData.fromCbor(bytesToHex(reader.readEncodedValue()));

      map.insert(key, value);
    }

    reader.readEndMap();

    return map;
  }

  /**
   * Gets the length of the map.
   *
   * @returns the length of the map.
   */
  getLength(): number {
    return this._map.size;
  }

  /**
   * Adds an element to the map.
   *
   * @param key The key of the element in the map.
   * @param value The value of the element.
   */
  insert(key: PlutusData, value: PlutusData) {
    this._map.set(key, value);
  }

  /**
   * Returns the specified element from the map.
   *
   * @param key The key of the element to return from the map.
   * @returns The element associated with the specified key in the map, or undefined
   * if there is no element with the given key.
   */
  get(key: PlutusData): PlutusData | undefined {
    return this._map.get(key);
  }

  /**
   * Gets all the keys from the map as a plutus list.
   *
   * @returns The keys of the map as a plutus list.
   */
  getKeys(): PlutusList {
    const list = new PlutusList();

    for (const elem of this._map.keys()) {
      list.add(elem);
    }

    return list;
  }
}
