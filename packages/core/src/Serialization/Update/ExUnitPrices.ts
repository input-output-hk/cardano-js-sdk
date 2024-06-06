import { CborReader, CborWriter } from '../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { UnitInterval } from '../Common/index.js';
import Fraction from 'fraction.js';
import type * as Cardano from '../../Cardano/index.js';

const EX_UNITS_PRICES_ARRAY_SIZE = 2;

/**
 * Specifies the cost (in Lovelace) of these ExUnits. In essence, they set the
 * "price" for the computational resources used by a smart contract.
 */
export class ExUnitPrices {
  #memPrice: UnitInterval;
  #stepsPrice: UnitInterval;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ExUnitPrices class.
   *
   * @param memPrices The price fo memory consumption.
   * @param stepsPrices The price of CPU steps.
   */
  constructor(memPrices: UnitInterval, stepsPrices: UnitInterval) {
    this.#memPrice = memPrices;
    this.#stepsPrice = stepsPrices;
  }

  /**
   * Serializes a ExUnitPrices into CBOR format.
   *
   * @returns The ExUnitPrices in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // ex_unit_prices =
    //   [ mem_price: unit_interval, step_price: unit_interval ]
    writer.writeStartArray(EX_UNITS_PRICES_ARRAY_SIZE);
    writer.writeEncodedValue(Buffer.from(this.#memPrice.toCbor(), 'hex'));
    writer.writeEncodedValue(Buffer.from(this.#stepsPrice.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ExUnitPrices from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ExUnitPrices object.
   * @returns The new ExUnitPrices instance.
   */
  static fromCbor(cbor: HexBlob): ExUnitPrices {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EX_UNITS_PRICES_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EX_UNITS_PRICES_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const memPrices = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const stepPrices = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    reader.readEndArray();

    const exUnit = new ExUnitPrices(memPrices, stepPrices);
    exUnit.#originalBytes = cbor;

    return exUnit;
  }

  /**
   * Creates a Core Prices object from the current ExUnitPrices object.
   *
   * @returns The Core Prices object.
   */
  toCore(): Cardano.Prices {
    return {
      memory: Number(this.#memPrice.numerator()) / Number(this.#memPrice.denominator()),
      steps: Number(this.#stepsPrice.numerator()) / Number(this.#stepsPrice.denominator())
    };
  }

  /**
   * Creates a ExUnitPrices object from the given Core Prices object.
   *
   * @param prices core Prices object.
   */
  static fromCore(prices: Cardano.Prices) {
    const mem = new Fraction(prices.memory);
    const steps = new Fraction(prices.steps);

    return new ExUnitPrices(
      new UnitInterval(BigInt(mem.n), BigInt(mem.d)),
      new UnitInterval(BigInt(steps.n), BigInt(steps.d))
    );
  }

  /**
   * Gets the price fo memory consumption.
   *
   * @returns The price fo memory consumption.
   */
  memPrice(): UnitInterval {
    return this.#memPrice;
  }

  /**
   * Sets the price fo memory consumption.
   *
   * @param memPrice The price fo memory consumption.
   */
  setMemPrice(memPrice: UnitInterval): void {
    this.#memPrice = memPrice;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the price of CPU steps.
   *
   * @returns The price of CPU steps.
   */
  stepsPrice(): UnitInterval {
    return this.#stepsPrice;
  }

  /**
   * Sets the price of CPU steps.
   *
   * @param stepsPrice The price of CPU steps.
   */
  setStepsPrice(stepsPrice: UnitInterval): void {
    this.#stepsPrice = stepsPrice;
    this.#originalBytes = undefined;
  }
}
