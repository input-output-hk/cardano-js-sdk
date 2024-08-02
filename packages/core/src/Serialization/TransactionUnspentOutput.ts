import { CborReader, CborWriter } from './CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { TransactionInput, TransactionOutput } from './TransactionBody';
import { hexToBytes } from '../util/misc';
import type * as Cardano from '../Cardano';

const TRANSACTION_UNSPENT_OUTPUT_ARRAY_SIZE = 2;

/** Represents a unspent output (UTxO). */
export class TransactionUnspentOutput {
  #input: TransactionInput;
  #output: TransactionOutput;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the TransactionUnspentOutput class.
   *
   * @param input The input that created this UTxO.
   * @param output The output created by the UTxO.
   */
  constructor(input: TransactionInput, output: TransactionOutput) {
    this.#input = input;
    this.#output = output;
  }

  /**
   * Serializes a TransactionUnspentOutput into CBOR format.
   *
   * @returns The TransactionUnspentOutput in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // transaction_unspent_output =
    //   [  input : transaction_input
    //    , output : transaction_output
    //   ]
    const writer = new CborWriter();

    writer.writeStartArray(TRANSACTION_UNSPENT_OUTPUT_ARRAY_SIZE);
    writer.writeEncodedValue(hexToBytes(this.#input.toCbor()));
    writer.writeEncodedValue(hexToBytes(this.#output.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TransactionUnspentOutput from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TransactionUnspentOutput object.
   * @returns The new TransactionUnspentOutput instance.
   */
  static fromCbor(cbor: HexBlob): TransactionUnspentOutput {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== TRANSACTION_UNSPENT_OUTPUT_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${TRANSACTION_UNSPENT_OUTPUT_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );
    const input = TransactionInput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const output = TransactionOutput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    const result = new TransactionUnspentOutput(input, output);
    result.#originalBytes = cbor;

    return result;
  }

  /**
   * Creates a Core TransactionUnspentOutput object from the current TransactionUnspentOutput object.
   *
   * @returns The Core TransactionUnspentOutput object.
   */
  toCore(): [Cardano.TxIn, Cardano.TxOut] {
    return [this.#input.toCore(), this.#output.toCore()];
  }

  /**
   * Creates a TransactionUnspentOutput object from the given Core TransactionUnspentOutput object.
   *
   * @param core The core TransactionUnspentOutput object.
   */
  static fromCore(core: [Cardano.TxIn, Cardano.TxOut]): TransactionUnspentOutput {
    return new TransactionUnspentOutput(TransactionInput.fromCore(core[0]), TransactionOutput.fromCore(core[1]));
  }

  /**
   * Gets the transaction input.
   *
   * @returns The transaction input.
   */
  input(): TransactionInput {
    return this.#input;
  }

  /**
   * Sets the transaction input.
   *
   * @param input The transaction input.
   */
  setInput(input: TransactionInput) {
    this.#input = input;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the transaction output.
   *
   * @returns The UTxO.
   */
  output(): TransactionOutput {
    return this.#output;
  }

  /**
   * Sets the transaction output.
   *
   * @param output The UTxO.
   */
  setOutput(output: TransactionOutput) {
    this.#output = output;
    this.#originalBytes = undefined;
  }
}
