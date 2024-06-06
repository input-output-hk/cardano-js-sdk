import { CborReader, CborWriter } from '../CBOR/index.js';
import { InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../Cardano/index.js';
import type { HexBlob } from '@cardano-sdk/util';

const EX_UNITS_ARRAY_SIZE = 2;

/**
 * Represent a measure of computational resources, specifically, how much memory
 * and CPU a Plutus script will use when executed. It's an essential component to
 * estimate the cost of running a Plutus script on the Cardano blockchain.
 *
 * The two resources measured by ExUnits are memory and CPU. When a Plutus script
 * is executed, it consumes both these resources. The ExUnits system quantifies
 * this consumption, helping to ensure that scripts don't overrun the system and
 * that they terminate in a reasonable amount of time.
 */
export class ExUnits {
  #mem: bigint;
  #steps: bigint;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ExUnits class.
   *
   * @param mem The amount of memory the script execution will consume.
   * @param steps The number of CPU steps that running ths script will take.
   */
  constructor(mem: bigint, steps: bigint) {
    this.#mem = mem;
    this.#steps = steps;
  }

  /**
   * Serializes a ExUnits into CBOR format.
   *
   * @returns The ExUnits in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // ex_units = [mem: uint, steps: uint]
    writer.writeStartArray(EX_UNITS_ARRAY_SIZE);
    writer.writeInt(this.#mem);
    writer.writeInt(this.#steps);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ExUnits from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ExUnits object.
   * @returns The new ExUnits instance.
   */
  static fromCbor(cbor: HexBlob): ExUnits {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EX_UNITS_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EX_UNITS_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const mem = reader.readUInt();
    const steps = reader.readUInt();

    reader.readEndArray();

    const exUnit = new ExUnits(mem, steps);
    exUnit.#originalBytes = cbor;

    return exUnit;
  }

  /**
   * Creates a Core ExUnits object from the current ExUnits object.
   *
   * @returns The Core ExUnits object.
   */
  toCore(): Cardano.ExUnits {
    return {
      memory: Number(this.#mem),
      steps: Number(this.#steps)
    };
  }

  /**
   * Creates a ExUnits object from the given Core ExUnits object.
   *
   * @param exUnits core ExUnits object.
   */
  static fromCore(exUnits: Cardano.ExUnits) {
    return new ExUnits(BigInt(exUnits.memory), BigInt(exUnits.steps));
  }

  /**
   * Gets the amount of memory the script execution will consume.
   *
   * @returns The amount of memory (in bytes).
   */
  mem(): bigint {
    return this.#mem;
  }

  /**
   * Sets the amount of memory the script execution will consume.
   *
   * @param mem The amount of memory (in bytes).
   */
  setMem(mem: bigint): void {
    this.#mem = mem;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the number of CPU steps that running ths script will take.
   *
   * @returns The number of CPU steps.
   */
  steps(): bigint {
    return this.#steps;
  }

  /**
   * Sets the number of CPU steps that running ths script will take.
   *
   * @param steps The number of CPU steps.
   */
  setSteps(steps: bigint): void {
    this.#steps = steps;
    this.#originalBytes = undefined;
  }

  /**
   * Adds the memory and cpu steps of the current ExUnits and the given ExUnits and returns the result.
   *
   * @param other The other ExUnits to be added with this ExUnits.
   */
  add(other: ExUnits): ExUnits {
    const mem = this.#mem + other.#mem;
    const steps = this.#steps + other.#steps;

    return new ExUnits(mem, steps);
  }
}
