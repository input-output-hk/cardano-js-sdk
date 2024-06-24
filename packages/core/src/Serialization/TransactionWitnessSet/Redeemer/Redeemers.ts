import { Cardano, inConwayEra } from '../../..';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { ExUnits } from '../../Common';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { PlutusData } from '../../PlutusData';
import { Redeemer } from './Redeemer';
import { RedeemerTag } from './RedeemerTag';
import { hexToBytes } from '../../../util/misc';

const MAP_INDEX_EMBEDDED_GROUP_SIZE = 2;
const MAP_VALUE_EMBEDDED_GROUP_SIZE = 2;

export class Redeemers {
  #values: Redeemer[];

  private constructor(redeemers: Redeemer[]) {
    this.#values = [...redeemers];
  }

  /**
   * Serializes Redeemers into CBOR format.
   * Redeemers are encoded as array when {@link inConwayEra} is false, and as map when
   * {@link inConwayEra} is true.
   *
   * @returns The Redeemers in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();
    // Encoding `redeemers` as `Map`:
    // https://github.com/IntersectMBO/cardano-ledger/blob/master/eras/conway/impl/cddl-files/conway.cddl#L480
    if (inConwayEra) {
      // { + [ tag: redeemer_tag, index: uint ] => [ data: plutus_data, ex_units: ex_units ] }
      const redeemersMap = new Map(this.#values.map((redeemer) => [`${redeemer.tag()}:${redeemer.index()}`, redeemer]));

      writer.writeStartMap(redeemersMap.size);
      for (const redeemer of redeemersMap.values()) {
        // Map key cbor
        writer.writeStartArray(2);
        writer.writeInt(redeemer.tag());
        writer.writeInt(redeemer.index());

        // Map value cbor
        writer.writeStartArray(2);
        writer.writeEncodedValue(hexToBytes(redeemer.data().toCbor()));
        writer.writeEncodedValue(hexToBytes(redeemer.exUnits().toCbor()));
      }
    } else {
      // [ + [ tag: redeemer_tag, index: uint, data: plutus_data, ex_units: ex_units ] ]
      writer.writeStartArray(this.#values.length);

      for (const data of this.#values) {
        writer.writeEncodedValue(Buffer.from(data.toCbor(), 'hex'));
      }
    }
    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Redeemers from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Redeemers array or map.
   * @returns The new Redeemers instance.
   */
  static fromCbor(cbor: HexBlob): Redeemers {
    const redeemers: Redeemer[] = [];
    const reader = new CborReader(cbor);
    if (reader.peekState() === CborReaderState.StartMap) {
      // { + [ tag: redeemer_tag, index: uint ] => [ data: plutus_data, ex_units: ex_units ] }
      reader.readStartMap();
      while (reader.peekState() !== CborReaderState.EndMap) {
        // Read key cbor
        const indexLength = reader.readStartArray();
        if (indexLength !== MAP_INDEX_EMBEDDED_GROUP_SIZE)
          throw new InvalidArgumentError(
            'cbor',
            `Redeemers map index should be an array of ${MAP_INDEX_EMBEDDED_GROUP_SIZE} elements, but got an array of ${indexLength} elements`
          );
        const tag: RedeemerTag = Number(reader.readUInt()) as RedeemerTag;
        const index = reader.readUInt();
        reader.readEndArray();

        // Read value cbor
        const valueLength = reader.readStartArray();
        if (valueLength !== MAP_VALUE_EMBEDDED_GROUP_SIZE)
          throw new InvalidArgumentError(
            'cbor',
            `Redeemers map value should be an array of ${MAP_VALUE_EMBEDDED_GROUP_SIZE} elements, but got an array of ${valueLength} elements`
          );
        const data = PlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        const exUnits = ExUnits.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        reader.readEndArray();

        redeemers.push(new Redeemer(tag, index, data, exUnits));
      }
      reader.readEndMap();
    } else {
      // [ + [ tag: redeemer_tag, index: uint, data: plutus_data, ex_units: ex_units ] ]
      reader.readStartArray();

      while (reader.peekState() !== CborReaderState.EndArray) {
        redeemers.push(Redeemer.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
      }

      reader.readEndArray();
    }
    return new Redeemers(redeemers);
  }

  /**
   * Creates a Core Redeemers array from the current Redeemer object.
   *
   * @returns The Core Redeemers array.
   */
  toCore(): Cardano.Redeemer[] {
    return this.#values.map((redeemer) => redeemer.toCore());
  }

  /**
   * Creates a Redeemers object from the given Core Redeemers array.
   *
   * @param redeemers core Redeemer array.
   */
  static fromCore(redeemers: Cardano.Redeemer[]): Redeemers {
    return new Redeemers(redeemers.map((redeemer) => Redeemer.fromCore(redeemer)));
  }

  /** @returns a copy of the underlying {@link Redeemer}[] */
  values(): readonly Redeemer[] {
    return this.#values;
  }

  /** @param redeemers replace the existing redeemers with the ones provided here  */
  setValues(redeemers: Redeemer[]) {
    this.#values = [...redeemers];
  }

  size() {
    return this.#values.length;
  }
}
