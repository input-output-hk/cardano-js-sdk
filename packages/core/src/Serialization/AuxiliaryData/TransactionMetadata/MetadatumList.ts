import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionMetadatum } from './TransactionMetadatum.js';
import { bytesToHex, hexToBytes } from '../../../util/misc/index.js';

/** A list of metadatum. */
export class MetadatumList {
  readonly #array = new Array<TransactionMetadatum>();
  #useIndefiniteEncoding = false;

  /**
   * Serializes this MetadatumList instance into its CBOR representation as a HexBlob.
   *
   * @returns The CBOR representation of this instance as a HexBlob.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#useIndefiniteEncoding) {
      writer.writeStartArray();
    } else {
      writer.writeStartArray(this.#array.length);
    }

    for (const elem of this.#array) {
      writer.writeEncodedValue(hexToBytes(elem.toCbor()));
    }

    if (this.#useIndefiniteEncoding) writer.writeEndArray();

    return HexBlob.fromBytes(writer.encode());
  }

  /**
   * Deserializes a MetadatumList instance from its CBOR representation.
   *
   * @param cbor The CBOR representation of this instance as a HexBlob.
   * @returns A MetadatumList instance.
   */
  static fromCbor(cbor: HexBlob): MetadatumList {
    const list = new MetadatumList();
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length === null) list.#useIndefiniteEncoding = true;

    while (reader.peekState() !== CborReaderState.EndArray) {
      list.add(TransactionMetadatum.fromCbor(bytesToHex(reader.readEncodedValue())));
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
  get(index: number): TransactionMetadatum {
    return this.#array[index];
  }

  /**
   * Adds an element to the Metadata List.
   *
   * @param elem The element to be added.
   */
  add(elem: TransactionMetadatum): void {
    this.#array.push(elem);
  }

  /**
   * Indicates whether some other PlutusList is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: MetadatumList): boolean {
    if (this.#array.length !== other.#array.length) return false;

    for (let i = 0; i < this.#array.length; ++i) {
      if (!this.#array[i].equals(other.#array[i])) return false;
    }

    return true;
  }
}
