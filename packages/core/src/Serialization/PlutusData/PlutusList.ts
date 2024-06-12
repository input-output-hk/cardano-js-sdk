import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { PlutusData } from './PlutusData';
import { bytesToHex, hexToBytes } from '../../util/misc';

/** A list of plutus data. */
export class PlutusList {
  readonly #array = new Array<PlutusData>();

  /**
   * Serializes this PlutusList instance into its CBOR representation as a Uint8Array.
   *
   * @returns The CBOR representation of this instance as a Uint8Array.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();
    const shouldUseIndefinite = this.#array.length > 0;

    if (shouldUseIndefinite) {
      writer.writeStartArray();
    } else {
      writer.writeStartArray(this.#array.length);
    }

    for (const elem of this.#array) {
      writer.writeEncodedValue(hexToBytes(elem.toCbor()));
    }

    if (shouldUseIndefinite) writer.writeEndArray();

    return HexBlob.fromBytes(writer.encode());
  }

  /**
   * Deserializes a PlutusList instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a Uint8Array.
   * @returns A PlutusList instance.
   */
  static fromCbor(cbor: HexBlob): PlutusList {
    const list = new PlutusList();
    const reader = new CborReader(cbor);

    reader.readStartArray();

    while (reader.peekState() !== CborReaderState.EndArray) {
      list.add(PlutusData.fromCbor(bytesToHex(reader.readEncodedValue())));
    }

    reader.readEndArray();

    return list;
  }

  /**
   * Gets the length of the list.
   *
   * @returns the length of the list.
   */
  getLength(): number {
    return this.#array.length;
  }

  /**
   * Gets an element from the list.
   *
   * @param index The index in the list of the element to get.
   */
  get(index: number): PlutusData {
    return this.#array[index];
  }

  /**
   * Adds an element to the Plutus List.
   *
   * @param elem The element to be added.
   */
  add(elem: PlutusData): void {
    this.#array.push(elem);
  }

  /**
   * Indicates whether some other PlutusList is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: PlutusList): boolean {
    if (this.#array.length !== other.#array.length) return false;

    for (let i = 0; i < this.#array.length; ++i) {
      if (!this.#array[i].equals(other.#array[i])) return false;
    }

    return true;
  }
}
