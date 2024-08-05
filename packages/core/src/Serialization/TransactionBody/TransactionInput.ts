import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import type * as Cardano from '../../Cardano';

const TRANSACTION_INPUT_ARRAY_SIZE = 2;

/**
 * Represents a reference to an unspent transaction output (UTxO) from a previous
 * transaction, which the current transaction intends to spend.
 */
export class TransactionInput {
  #id: Cardano.TransactionId;
  #index: bigint;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the TransactionInput class.
   *
   * @param id Points to the transaction where the UTxO being spent was created.
   * @param index Indicates which specific output of the referenced transaction is being spent.
   */
  constructor(id: Cardano.TransactionId, index: bigint) {
    this.#id = id;
    this.#index = index;
  }

  /**
   * Serializes a TransactionInput into CBOR format.
   *
   * @returns The TransactionInput in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // transaction_input = [ transaction_id : $hash32
    //                     , index : uint
    //                     ]
    const writer = new CborWriter();

    writer.writeStartArray(TRANSACTION_INPUT_ARRAY_SIZE);
    writer.writeByteString(Buffer.from(this.#id, 'hex'));
    writer.writeInt(this.#index);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TransactionInput from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TransactionInput object.
   * @returns The new TransactionInput instance.
   */
  static fromCbor(cbor: HexBlob): TransactionInput {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== TRANSACTION_INPUT_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${TRANSACTION_INPUT_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );
    const txId = reader.readByteString();
    const index = reader.readInt();

    const input = new TransactionInput(HexBlob.fromBytes(txId) as unknown as Cardano.TransactionId, index);
    input.#originalBytes = cbor;

    return input;
  }

  /**
   * Creates a Core TransactionInput object from the current TransactionInput object.
   *
   * @returns The Core TransactionInput object.
   */
  toCore(): Cardano.TxIn {
    return {
      index: Number(this.#index),
      txId: this.#id
    };
  }

  /**
   * Creates a TransactionInput object from the given Core TransactionInput object.
   *
   * @param coreTransactionInput The core TransactionInput object.
   */
  static fromCore(coreTransactionInput: Cardano.TxIn): TransactionInput {
    return new TransactionInput(coreTransactionInput.txId, BigInt(coreTransactionInput.index));
  }

  /**
   * This is an identifier of a previous transaction. It points to the transaction where the UTxO being
   * spent was created.
   *
   * @returns The identifier of the previous transaction where the UTxO being
   * spent was created.
   */
  transactionId(): Cardano.TransactionId {
    return this.#id;
  }

  /**
   * Sets the identifier of the previous transaction where the UTxO being
   * spent was created.
   *
   * @param id The identifier of the previous transaction.
   */
  setTransactionId(id: Cardano.TransactionId) {
    this.#id = id;
    this.#originalBytes = undefined;
  }

  /**
   * Given that a single transaction can have multiple outputs, this index indicates which specific output
   * of the referenced transaction is being spent. It is an integer starting from 0 for the first output.
   *
   * @returns The index of the specific output of the referenced transaction being spent.
   */
  index(): bigint {
    return this.#index;
  }

  /**
   * Sets the index of the specific output of the referenced transaction being spent.
   *
   * @param index The index of the specific output being spent.
   */
  setIndex(index: bigint) {
    this.#index = index;
    this.#originalBytes = undefined;
  }
}
