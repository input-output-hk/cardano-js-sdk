import { CborReader, CborReaderState, CborTag, CborWriter } from '../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { inConwayEra } from '../../util';

/** Represents a cbor serialization wrapper for a Core type <{@link C}> */
interface CborSerializable<C> {
  toCbor(): HexBlob;
  toCore(): C;
}

/**
 * CborSet encapsulates a [Mathematical finite set](https://github.com/input-output-hk/cbor-sets-spec/blob/master/CBOR_SETS.md).
 *
 * In the Cardano CDDL, sets have been represented as simple arrays, so the implementation supports both
 * the array, and the `258` tag representation.
 */
export class CborSet<C, T extends CborSerializable<C>> {
  #values: T[];

  // Prevent users from directly creating an instance. Only allow creating via fromCore or fromCbor.
  private constructor(values: T[]) {
    this.#values = [...values];
  }

  /**
   * Deserializes a `set` from a CBOR byte array represented as either an array or a `258` tag
   *
   * @param cbor The CBOR encoded set.
   * @param fromCbor The function to use when deserializing each set element.
   * @returns a new CborSet<S>, where S is the type of items in the set.
   */
  static fromCbor<C, S extends CborSerializable<C>>(cbor: HexBlob, fromCbor: (cbor: HexBlob) => S): CborSet<C, S> {
    const reader = new CborReader(cbor);
    const cborSet = new CborSet<C, S>([]);

    // If it is a `set`, it must start with the 6.258 `set` tag
    if (reader.peekState() === CborReaderState.Tag && reader.peekTag() === CborTag.Set) {
      reader.readTag();
    }

    reader.readStartArray();
    while (reader.peekState() !== CborReaderState.EndArray) {
      cborSet.#values.push(fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
    }

    return cborSet;
  }

  /**
   * Serializes a CborSet<T> into CBOR format.
   *
   * @returns The CborSet in CBOR format, using the `258` tag representation if {@link inConwayEra} flag is set,
   * or as an the array.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (inConwayEra) writer.writeTag(CborTag.Set);

    writer.writeStartArray(this.size());

    for (const input of this.values()) {
      writer.writeEncodedValue(Buffer.from(input.toCbor(), 'hex'));
    }

    return writer.encodeAsHex();
  }

  /**
   * @returns the set as an array of Core objects
   */
  toCore(): C[] {
    return this.#values.map((v) => v.toCore());
  }

  /**
   * Creates a CborSet object from the given array of Core objects.
   *
   * @param coreValues An array of Core type objects
   * @param fromCore method that coverts the core object into a CborSerializable object
   * @returns a CborSet
   */
  static fromCore<C, S extends CborSerializable<C>>(coreValues: C[], fromCore: (coreValue: C) => S): CborSet<C, S> {
    return new CborSet(coreValues.map((v) => fromCore(v)));
  }

  /** Returns the values of the set as an array */
  values(): readonly T[] {
    return this.#values;
  }

  /** Returns the values of the set as an array */
  setValues(values: T[]): void {
    this.#values = [...values];
  }

  size() {
    return this.#values.length;
  }
}
