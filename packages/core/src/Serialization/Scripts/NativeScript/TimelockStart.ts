import { CborReader, CborWriter } from '../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScriptKind, ScriptType } from '../../../Cardano/types/Script';
import { Slot } from '../../../Cardano/types/Block';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This script evaluates to true if the lower bound of the transaction validity interval is a
 * slot number Y, and Y <= X.
 *
 * This condition guarantees that the actual slot number in which the transaction is included
 * is greater than or equal to slot number X.
 */
export class TimelockStart {
  #slot: Cardano.Slot;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the class TimelockStart.
   *
   * @param slot The slot number specifying the lower bound of the validity interval.
   */
  constructor(slot: Cardano.Slot) {
    this.#slot = slot;
  }

  /**
   * Serializes a TimelockStart into CBOR format.
   *
   * @returns The TimelockStart in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();

    // CDDL
    // invalid_before = (4, uint)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(NativeScriptKind.RequireTimeAfter);
    writer.writeInt(this.#slot);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TimelockStart from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TimelockStart object.
   * @returns The new TimelockStart instance.
   */
  static fromCbor(cbor: HexBlob): TimelockStart {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== NativeScriptKind.RequireTimeAfter)
      throw new InvalidArgumentError(
        'cbor',
        `Expected kind ${NativeScriptKind.RequireTimeAfter}, but got kind ${kind}`
      );

    const slot = Slot(Number(reader.readInt()));

    const script = new TimelockStart(slot);

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core RequireTimeAfterScript object from the current TimelockStart object.
   *
   * @returns The Core RequireTimeAfterScript object.
   */
  toCore(): Cardano.RequireTimeAfterScript {
    return {
      __type: ScriptType.Native,
      kind: NativeScriptKind.RequireTimeAfter,
      slot: this.#slot
    };
  }

  /**
   * Creates a TimelockStart object from the given Core RequireTimeAfterScript object.
   *
   * @param script The core RequireTimeAfterScript object.
   */
  static fromCore(script: Cardano.RequireTimeAfterScript) {
    return new TimelockStart(script.slot);
  }

  /**
   * Gets the slot number specified in this native script.
   *
   * @returns The slot number specifying the lower bound of the validity interval.
   */
  slot(): Cardano.Slot {
    return this.#slot;
  }

  /**
   * Sets the slot number specified in this native script.
   *
   * @param slot The slot number specifying the lower bound of the validity interval.
   */
  setSlot(slot: Cardano.Slot): void {
    this.#slot = slot;
    this.#originalBytes = undefined;
  }
}
