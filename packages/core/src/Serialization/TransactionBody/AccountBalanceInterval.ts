import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { SerializationError, SerializationFailure } from '../../errors';
import type * as Cardano from '../../Cardano';

const INTERVAL_ARRAY_SIZE = 2;
const BOTH_NIL_MESSAGE = 'Both interval bounds cannot be nil.';

/**
 * A half-open account balance range asserting that an account balance b satisfies
 * inclusiveLowerBound <= b < exclusiveUpperBound at validation time (Dijkstra
 * account_balance_interval).
 *
 * On the wire this is a fixed 2-element array [inclusive_lower_bound, exclusive_upper_bound]
 * where an absent bound encodes as CBOR null (nil). At most one bound may be nil; a bound of 0
 * is a valid coin value distinct from nil.
 */
export class AccountBalanceInterval {
  #inclusiveLowerBound: Cardano.Lovelace | undefined;
  #exclusiveUpperBound: Cardano.Lovelace | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the AccountBalanceInterval class.
   *
   * @param inclusiveLowerBound The inclusive lower bound in lovelace, or undefined for no lower bound.
   * @param exclusiveUpperBound The exclusive upper bound in lovelace, or undefined for no upper bound.
   */
  constructor(inclusiveLowerBound?: Cardano.Lovelace, exclusiveUpperBound?: Cardano.Lovelace) {
    this.#inclusiveLowerBound = inclusiveLowerBound;
    this.#exclusiveUpperBound = exclusiveUpperBound;
  }

  /**
   * Serializes an AccountBalanceInterval into CBOR format.
   *
   * @returns The AccountBalanceInterval in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    if (this.#inclusiveLowerBound === undefined && this.#exclusiveUpperBound === undefined)
      throw new InvalidStateError(BOTH_NIL_MESSAGE);

    const writer = new CborWriter();

    // CDDL
    // account_balance_interval =
    //   [  inclusive_lower_bound : coin, exclusive_upper_bound : coin/ nil
    //   // inclusive_lower_bound : coin/ nil, exclusive_upper_bound : coin
    //   ]
    writer.writeStartArray(INTERVAL_ARRAY_SIZE);

    if (this.#inclusiveLowerBound === undefined) {
      writer.writeNull();
    } else {
      writer.writeInt(this.#inclusiveLowerBound);
    }

    if (this.#exclusiveUpperBound === undefined) {
      writer.writeNull();
    } else {
      writer.writeInt(this.#exclusiveUpperBound);
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes an AccountBalanceInterval from a CBOR byte array.
   *
   * @param cbor The CBOR encoded AccountBalanceInterval object.
   * @returns The new AccountBalanceInterval instance.
   */
  static fromCbor(cbor: HexBlob): AccountBalanceInterval {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();
    if (length !== INTERVAL_ARRAY_SIZE)
      throw new SerializationError(
        SerializationFailure.InvalidType,
        `account_balance_interval must be an array of ${INTERVAL_ARRAY_SIZE} elements, but got ${length}`
      );

    let inclusiveLowerBound;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      inclusiveLowerBound = reader.readInt();
    }

    let exclusiveUpperBound;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      exclusiveUpperBound = reader.readInt();
    }

    reader.readEndArray();

    if (inclusiveLowerBound === undefined && exclusiveUpperBound === undefined)
      throw new SerializationError(SerializationFailure.InvalidType, BOTH_NIL_MESSAGE);

    const interval = new AccountBalanceInterval(inclusiveLowerBound, exclusiveUpperBound);
    interval.#originalBytes = cbor;

    return interval;
  }

  /**
   * Creates a Core AccountBalanceInterval object from the current AccountBalanceInterval object.
   *
   * @returns The Core AccountBalanceInterval object.
   */
  toCore(): Cardano.AccountBalanceInterval {
    return {
      ...(this.#inclusiveLowerBound !== undefined && { inclusiveLowerBound: this.#inclusiveLowerBound }),
      ...(this.#exclusiveUpperBound !== undefined && { exclusiveUpperBound: this.#exclusiveUpperBound })
    };
  }

  /**
   * Creates an AccountBalanceInterval object from the given Core AccountBalanceInterval object.
   *
   * @param interval The core AccountBalanceInterval object.
   * @returns The new AccountBalanceInterval instance.
   */
  static fromCore(interval: Cardano.AccountBalanceInterval): AccountBalanceInterval {
    if (interval.inclusiveLowerBound === undefined && interval.exclusiveUpperBound === undefined)
      throw new InvalidArgumentError('interval', BOTH_NIL_MESSAGE);

    return new AccountBalanceInterval(interval.inclusiveLowerBound, interval.exclusiveUpperBound);
  }

  /**
   * Sets the inclusive lower bound of this interval.
   *
   * @param inclusiveLowerBound The inclusive lower bound in lovelace, or undefined for no lower bound.
   */
  setInclusiveLowerBound(inclusiveLowerBound: Cardano.Lovelace | undefined): void {
    this.#inclusiveLowerBound = inclusiveLowerBound;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the inclusive lower bound of this interval.
   *
   * @returns The inclusive lower bound in lovelace, or undefined when the bound is nil.
   */
  inclusiveLowerBound(): Cardano.Lovelace | undefined {
    return this.#inclusiveLowerBound;
  }

  /**
   * Sets the exclusive upper bound of this interval.
   *
   * @param exclusiveUpperBound The exclusive upper bound in lovelace, or undefined for no upper bound.
   */
  setExclusiveUpperBound(exclusiveUpperBound: Cardano.Lovelace | undefined): void {
    this.#exclusiveUpperBound = exclusiveUpperBound;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the exclusive upper bound of this interval.
   *
   * @returns The exclusive upper bound in lovelace, or undefined when the bound is nil.
   */
  exclusiveUpperBound(): Cardano.Lovelace | undefined {
    return this.#exclusiveUpperBound;
  }
}
