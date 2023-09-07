import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { MetadatumList } from './MetadatumList';
import { TransactionMetadatum } from './TransactionMetadatum';
import { bytesToHex, hexToBytes } from '../../../util/misc';

/**
 * Represents a Map of Metadatum.
 */
export class MetadatumMap {
  readonly #map = new Map<TransactionMetadatum, TransactionMetadatum>();
  #useIndefiniteEncoding = false;

  /**
   * Serializes this MetadatumMap instance into its CBOR representation as a HexBlob.
   *
   * @returns The CBOR representation of this instance as a HexBlob.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#useIndefiniteEncoding) {
      writer.writeStartMap();
    } else {
      writer.writeStartMap(this.#map.size);
    }

    for (const [key, value] of this.#map.entries()) {
      writer.writeEncodedValue(hexToBytes(key.toCbor()));
      writer.writeEncodedValue(hexToBytes(value.toCbor()));
    }

    if (this.#useIndefiniteEncoding) writer.writeEndMap();

    return HexBlob.fromBytes(writer.encode());
  }

  /**
   * Deserializes a MetadatumMap instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a HexBlob.
   * @returns A MetadatumMap instance.
   */
  static fromCbor(cbor: HexBlob): MetadatumMap {
    const map = new MetadatumMap();
    const reader = new CborReader(cbor);

    const size = reader.readStartMap();

    if (size === null) map.#useIndefiniteEncoding = true;

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = TransactionMetadatum.fromCbor(bytesToHex(reader.readEncodedValue()));
      const value = TransactionMetadatum.fromCbor(bytesToHex(reader.readEncodedValue()));

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
    return this.#map.size;
  }

  /**
   * Adds an element to the map.
   *
   * @param key The key of the element in the map.
   * @param value The value of the element.
   */
  insert(key: TransactionMetadatum, value: TransactionMetadatum) {
    this.#map.set(key, value);
  }

  /**
   * Returns the specified element from the map.
   *
   * @param key The key of the element to return from the map.
   * @returns The element associated with the specified key in the map, or undefined
   * if there is no element with the given key.
   */
  get(key: TransactionMetadatum): TransactionMetadatum | undefined {
    if (!this.#map) return undefined;

    const element = [...this.#map.entries()].find((entry) => entry[0].equals(key));

    if (!element) return undefined;

    return element[1];
  }

  /**
   * Gets all the keys from the map as a metadatum list.
   *
   * @returns The keys of the map as a metadatum list.
   */
  getKeys(): MetadatumList {
    const list = new MetadatumList();

    for (const elem of this.#map.keys()) {
      list.add(elem);
    }

    return list;
  }

  /**
   * Indicates whether some other PlutusMap is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: MetadatumMap): boolean {
    if (this.#useIndefiniteEncoding !== other.#useIndefiniteEncoding) return false;
    if (this.#map.size !== other.#map.size) return false;

    const thisEntries = [...this.#map.entries()];
    const otherEntries = [...other.#map.entries()];

    for (let i = 0; i < this.#map.size; ++i) {
      if (!thisEntries[i][0].equals(otherEntries[i][0])) return false;
      if (!thisEntries[i][1].equals(otherEntries[i][1])) return false;
    }

    return true;
  }
}
