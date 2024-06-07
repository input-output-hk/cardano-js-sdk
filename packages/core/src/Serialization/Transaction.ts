/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Cardano from '../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { AuxiliaryData } from './AuxiliaryData';
import { CborReader, CborReaderState, CborWriter } from './CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionBody } from './TransactionBody';
import { TransactionWitnessSet } from './TransactionWitnessSet';
import { hexToBytes } from '../util/misc';
import type { TxCBOR } from '../CBOR';

const ALONZO_ERA_TX_FRAME_SIZE = 4;

/**
 * A transaction is a record of value transfer between two or more addresses on the network. It represents a request
 * to modify the state of the blockchain, by transferring a certain amount of ADA or a native asset from one address
 * to another. Each transaction includes inputs and outputs, where the inputs represent the addresses that are sending
 * ADA or the native asset, and the outputs represent the addresses that are receiving ADA or the native asset.
 *
 * To ensure the security and integrity of the Cardano blockchain, each transaction is cryptographically signed using
 * the private key of the sender's address, which proves that the sender has authorized the transaction.
 *
 * Additionally, each transaction on the Cardano blockchain can also carry metadata, which can be used to include
 * additional information about the transaction, such as a description or a reference to a specific product or service.
 */
export class Transaction {
  #body: TransactionBody;
  #witnessSet: TransactionWitnessSet;
  #auxiliaryData: AuxiliaryData | undefined;
  #isValid = true;
  // If the transaction object is constructed from a CBOR byte array, we are going to remember it and use it
  // when the object is re-serialized again to avoid changing the transaction during a round trip serialization.
  // This cache will be invalidated if any of the transaction properties changes after the object has been deserialized.
  #originalBytes: TxCBOR | undefined = undefined;

  /**
   * Initializes a new instance of the Transaction class.
   *
   * @param body Data structure that contains all the elements of the transaction.
   * @param witnessSet Collection of digital signatures that are attached to a transaction to prove that it has been
   * authorized by the appropriate parties, the witness set also contain all required information to satisfy native or
   * plutus script execution requirements, such as Datums, Redeemers and the script itself.
   * @param auxiliaryData Additional information that can be attached to a transaction to provide more context or
   * information about the transaction.
   */
  constructor(body: TransactionBody, witnessSet: TransactionWitnessSet, auxiliaryData?: AuxiliaryData) {
    this.#body = body;
    this.#witnessSet = witnessSet;
    this.#auxiliaryData = auxiliaryData;
  }

  /**
   * Creates a transaction object from the given transaction body with an empty witness set and no
   * auxiliary data.
   *
   * @param body Data structure that contains all the elements of the transaction.
   */
  static fromBody(body: TransactionBody): Transaction {
    return new Transaction(body, TransactionWitnessSet.fromCore({ signatures: new Map() }));
  }

  /**
   * Creates a transaction object from the given transaction core body with an empty witness set and no
   * auxiliary data.
   *
   * @param body Data structure that contains all the elements of the transaction.
   */
  static fromCoreBody(body: Cardano.TxBody): Transaction {
    return new Transaction(TransactionBody.fromCore(body), TransactionWitnessSet.fromCore({ signatures: new Map() }));
  }

  /**
   * Serializes a transaction into CBOR format.
   *
   * @returns The transaction in CBOR format.
   */
  toCbor(): TxCBOR {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // transaction =
    //   [ transaction_body
    //   , transaction_witness_set
    //   , bool
    //   , auxiliary_data / null
    //   ]
    writer.writeStartArray(ALONZO_ERA_TX_FRAME_SIZE);
    writer.writeEncodedValue(hexToBytes(this.#body.toCbor()));
    writer.writeEncodedValue(hexToBytes(this.#witnessSet.toCbor()));
    writer.writeBoolean(this.#isValid);

    if (this.#auxiliaryData) {
      writer.writeEncodedValue(hexToBytes(this.#auxiliaryData.toCbor()));
    } else {
      writer.writeNull();
    }

    return writer.encodeAsHex() as unknown as TxCBOR;
  }

  /**
   * Deserializes the transaction from a CBOR byte array.
   *
   * @param cbor The CBOR encoded transaction object.
   * @returns The new transaction instance.
   */
  static fromCbor(cbor: TxCBOR): Transaction {
    const reader = new CborReader(cbor as unknown as HexBlob);

    const length = reader.readStartArray();

    const bodyBytes = reader.readEncodedValue();
    const body = TransactionBody.fromCbor(HexBlob.fromBytes(bodyBytes));

    const witnessSet = TransactionWitnessSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    let isValid = true;

    // The isValid flag was added in Alonzo era (onwards), mary era transactions only have three fields.
    if (length === ALONZO_ERA_TX_FRAME_SIZE) {
      isValid = reader.readBoolean();
    }

    let auxData;
    if (reader.peekState() !== CborReaderState.Null)
      auxData = AuxiliaryData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    const tx = new Transaction(body, witnessSet, auxData);

    tx.#isValid = isValid;
    tx.#originalBytes = cbor;

    return tx;
  }

  /**
   * Creates a Core Tx object from the current Transaction object.
   *
   * @returns The Core Tx object.
   */
  toCore(): Cardano.Tx {
    return {
      auxiliaryData: this.#auxiliaryData ? this.#auxiliaryData.toCore() : undefined,
      body: this.#body.toCore(),
      id: this.getId(),
      isValid: this.#isValid,
      witness: this.#witnessSet.toCore()
    };
  }

  /**
   * Creates a transaction object from the given Core Tx object.
   *
   * @param tx The core TX object.
   */
  static fromCore(tx: Cardano.Tx) {
    const transaction = new Transaction(
      TransactionBody.fromCore(tx.body),
      TransactionWitnessSet.fromCore(tx.witness),
      tx.auxiliaryData ? AuxiliaryData.fromCore(tx.auxiliaryData) : undefined
    );

    if (typeof tx.isValid !== 'undefined') transaction.setIsValid(tx.isValid);

    return transaction;
  }

  /**
   * Data structure that contains all key elements of the transaction.
   *
   * @returns A deep clone of the transaction body.
   */
  body(): TransactionBody {
    return TransactionBody.fromCbor(this.#body.toCbor());
  }

  /**
   * Sets the transaction body.
   *
   * @param body The transaction body.
   */
  setBody(body: TransactionBody) {
    this.#body = body;
    this.#originalBytes = undefined;
  }

  /**
   * Collection of digital signatures that are attached to a transaction to prove that it has been authorized by the
   * appropriate parties, the witness set also contain all required information to satisfy native or plutus script
   * execution requirements, such as Datums, Redeemers and the script itself.
   *
   * @returns A deep clone of the transaction witness set.
   */
  witnessSet(): TransactionWitnessSet {
    return TransactionWitnessSet.fromCbor(this.#witnessSet.toCbor());
  }

  /**
   * Sets the witness set of the transaction.
   *
   * @param witnessSet A deep clone of the witness set in this transaction.
   */
  setWitnessSet(witnessSet: TransactionWitnessSet) {
    this.#witnessSet = witnessSet;
    this.#originalBytes = undefined;
  }

  /**
   * Gets whether the Transaction is expected to fail Plutus scripts validations or not.
   *
   * A transaction with this flag on false, can still be submitted to the blockchain.
   *
   * @returns <tt>true</tt> if the transaction is expected to fail validation; otherwise, <tt>false</tt>.
   */
  isValid(): boolean {
    return this.#isValid;
  }

  /**
   * Sets the valid flag on the transaction.
   *
   * Transactions containing Plutus scripts that are expected to fail validation can still be submitted if
   * this value is set to false.
   *
   * Remark: Sending transactions with invalid scripts will cause the collateral of the transaction to be lost.
   */
  setIsValid(valid: boolean): void {
    this.#originalBytes = undefined;
    this.#isValid = valid;
  }

  /**
   * Gets the transaction Auxiliary data.
   *
   * @returns A clone of the transaction Auxiliary data (or undefined if the transaction doesnt have auxiliary data).
   */
  auxiliaryData(): AuxiliaryData | undefined {
    if (this.#auxiliaryData) {
      return AuxiliaryData.fromCbor(this.#auxiliaryData.toCbor());
    }

    return undefined;
  }

  /**
   * Sets the transaction auxiliary data.
   *
   * The auxiliary is additional information that can be attached to a transaction to provide more context or
   * information about the transaction.
   *
   * @param auxiliaryData The auxiliary data to be set.
   */
  setAuxiliaryData(auxiliaryData: AuxiliaryData | undefined) {
    this.#auxiliaryData = auxiliaryData;
    this.#originalBytes = undefined;
  }

  /** Computes the transaction id for this transaction. */
  getId(): Cardano.TransactionId {
    const hash = Crypto.blake2b(Crypto.blake2b.BYTES).update(hexToBytes(this.#body.toCbor())).digest();

    return Cardano.TransactionId.fromHexBlob(HexBlob.fromBytes(hash));
  }

  /** Performs a deep clone of the transaction object. */
  clone(): Transaction {
    const bytes = this.toCbor();
    return Transaction.fromCbor(bytes);
  }
}
