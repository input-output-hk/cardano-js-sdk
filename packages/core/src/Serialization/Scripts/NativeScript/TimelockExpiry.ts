import * as Cardano from '../../../Cardano';
import { CborReader, CborWriter } from '../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This script evaluates to true if the upper bound of the transaction validity interval is a
 * slot number Y, and X <= Y.
 *
 * This condition guarantees that the actual slot number in which the transaction is included is
 * (strictly) less than slot number X.
 */
export class TimelockExpiry {
  #slot: Cardano.Slot;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the class TimelockExpiry.
   *
   * @param slot The slot number specifying the upper bound of the validity interval.
   */
  constructor(slot: Cardano.Slot) {
    this.#slot = slot;
  }

  /**
   * Serializes a TimelockExpiry into CBOR format.
   *
   * @returns The TimelockExpiry in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // invalid_hereafter = (5, uint)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(Cardano.NativeScriptKind.RequireTimeBefore);
    writer.writeInt(this.#slot);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TimelockExpiry from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TimelockExpiry object.
   * @returns The new TimelockExpiry instance.
   */
  static fromCbor(cbor: HexBlob): TimelockExpiry {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== Cardano.NativeScriptKind.RequireTimeBefore)
      throw new InvalidArgumentError(
        'cbor',
        `Expected kind ${Cardano.NativeScriptKind.RequireTimeBefore}, but got kind ${kind}`
      );

    const slot = Cardano.Slot(Number(reader.readInt()));

    const script = new TimelockExpiry(slot);

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core RequireTimeBeforeScript object from the current TimelockExpiry object.
   *
   * @returns The Core RequireTimeBeforeScript object.
   */
  toCore(): Cardano.RequireTimeBeforeScript {
    return {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireTimeBefore,
      slot: this.#slot
    };
  }

  /**
   * Creates a TimelockExpiry object from the given Core RequireTimeBeforeScript object.
   *
   * @param script The core RequireTimeBeforeScript object.
   */
  static fromCore(script: Cardano.RequireTimeBeforeScript) {
    return new TimelockExpiry(script.slot);
  }

  /**
   * Gets the slot number specified in this native script.
   *
   * @returns The slot number specifying the upper bound of the validity interval.
   */
  slot(): Cardano.Slot {
    return this.#slot;
  }

  /**
   * Sets the slot number specified in this native script.
   *
   * @param slot The slot number specifying the upper bound of the validity interval.
   */
  setSlot(slot: Cardano.Slot): void {
    this.#slot = slot;
    this.#originalBytes = undefined;
  }
}
