import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { PlutusData } from './PlutusData';
import { bytesToHex, hexToBytes } from '../../util/misc';

/**
 * A list of plutus data.
 */
export class PlutusList {
  private readonly _array = new Array<PlutusData>();
  private _useIndefiniteEncoding = true;

  /**
   * Serializes this PlutusList instance into its CBOR representation as a Uint8Array.
   *
   * @returns The CBOR representation of this instance as a Uint8Array.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this._useIndefiniteEncoding) {
      writer.writeStartArray();
    } else {
      writer.writeStartArray(this._array.length);
    }

    for (const elem of this._array) {
      writer.writeEncodedValue(hexToBytes(elem.toCbor()));
    }

    if (this._useIndefiniteEncoding) writer.writeEndArray();

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

    const length = reader.readStartArray();

    if (length === null) list._useIndefiniteEncoding = true;

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
    return this._array.length;
  }

  /**
   * Gets an element from the list.
   *
   * @param index The index in the list of the element to get.
   */
  get(index: number): PlutusData {
    return this._array[index];
  }

  /**
   * Adds an element to the Plutus List.
   *
   * @param elem The element to be added.
   */
  add(elem: PlutusData): void {
    this._array.push(elem);
  }
}
