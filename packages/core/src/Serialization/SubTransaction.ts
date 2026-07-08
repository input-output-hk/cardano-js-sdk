import * as Crypto from '@cardano-sdk/crypto';
import { AuxiliaryData } from './AuxiliaryData';
import { CborReader, CborReaderState, CborWriter } from './CBOR';
import { DeserializationOptions } from './Common';
import { HexBlob } from '@cardano-sdk/util';
import { SerializationError, SerializationFailure } from '../errors';
import { SubTransactionBody } from './TransactionBody/SubTransactionBody';
import { TransactionWitnessSet } from './TransactionWitnessSet';
import { hexToBytes } from '../util/misc';
import type * as Cardano from '../Cardano';

const SUB_TX_FRAME_SIZE = 3;

/**
 * A Dijkstra sub transaction (CIP-0118 nested transactions).
 *
 * A sub transaction is carried inside the enclosing top level transaction (body key 23) and is
 * serialized as exactly three elements: its body, its witness set and its nullable auxiliary
 * data. Unlike top level transactions there is no is_valid flag, not even the grace-period
 * 4-element mempool form - the enclosing transaction's flag covers the whole batch.
 *
 * Sub transactions are identified by their own transaction id, derived exactly like a top level
 * transaction id: the blake2b-256 hash of the body bytes.
 */
export class SubTransaction {
  #body: SubTransactionBody;
  #witnessSet: TransactionWitnessSet;
  #auxiliaryData: AuxiliaryData | undefined;
  // If the sub transaction object is constructed from a CBOR byte array, we are going to remember it and use it
  // when the object is re-serialized again to avoid changing the sub transaction during a round trip serialization.
  // This cache will be invalidated if any of the properties changes after the object has been deserialized.
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the SubTransaction class.
   *
   * @param body Data structure that contains all the elements of the sub transaction.
   * @param witnessSet Collection of digital signatures that are attached to the sub transaction to prove that it has
   * been authorized by the appropriate parties, the witness set also contain all required information to satisfy
   * native or plutus script execution requirements, such as Datums, Redeemers and the script itself.
   * @param auxiliaryData Additional information that can be attached to the sub transaction to provide more context
   * or information about it.
   */
  constructor(body: SubTransactionBody, witnessSet: TransactionWitnessSet, auxiliaryData?: AuxiliaryData) {
    this.#body = body;
    this.#witnessSet = witnessSet;
    this.#auxiliaryData = auxiliaryData;
  }

  /**
   * Serializes a SubTransaction into CBOR format.
   *
   * @returns The SubTransaction in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();

    // CDDL
    // sub_transaction =
    //   [ sub_transaction_body
    //   , transaction_witness_set
    //   , auxiliary_data / nil
    //   ]
    writer.writeStartArray(SUB_TX_FRAME_SIZE);
    writer.writeEncodedValue(hexToBytes(this.#body.toCbor()));
    writer.writeEncodedValue(hexToBytes(this.#witnessSet.toCbor()));

    if (this.#auxiliaryData) {
      writer.writeEncodedValue(hexToBytes(this.#auxiliaryData.toCbor()));
    } else {
      writer.writeNull();
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the SubTransaction from a CBOR byte array.
   *
   * The frame must be exactly 3 elements. In particular the 4-element is_valid mempool form is
   * rejected: the ledger only tolerates that grace-period frame for top level transactions,
   * never for sub transactions.
   *
   * @param cbor The CBOR encoded SubTransaction object.
   * @param options Deserialization options. When `strict` is true, throws on unknown map keys
   * instead of skipping them.
   * @returns The new SubTransaction instance.
   */
  static fromCbor(cbor: HexBlob, options?: DeserializationOptions): SubTransaction {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== null && length !== SUB_TX_FRAME_SIZE)
      throw new SerializationError(
        SerializationFailure.InvalidType,
        `Sub transaction frame must be exactly ${SUB_TX_FRAME_SIZE} elements (there is no is_valid flag), found ${length}`
      );

    const body = SubTransactionBody.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), options);
    const witnessSet = TransactionWitnessSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), options);

    let auxData;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      auxData = AuxiliaryData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    reader.readEndArray();

    const subTx = new SubTransaction(body, witnessSet, auxData);

    subTx.#originalBytes = cbor;

    return subTx;
  }

  /**
   * Creates a Core SubTransaction object from the current SubTransaction object.
   *
   * @returns The Core SubTransaction object.
   */
  toCore(): Cardano.SubTransaction {
    const subTx: Cardano.SubTransaction = {
      body: this.#body.toCore(),
      witness: this.#witnessSet.toCore()
    };

    if (this.#auxiliaryData) {
      subTx.auxiliaryData = this.#auxiliaryData.toCore();
    }

    return subTx;
  }

  /**
   * Creates a SubTransaction object from the given Core SubTransaction object.
   *
   * @param subTx The core SubTransaction object.
   */
  static fromCore(subTx: Cardano.SubTransaction): SubTransaction {
    return new SubTransaction(
      SubTransactionBody.fromCore(subTx.body),
      TransactionWitnessSet.fromCore(subTx.witness),
      subTx.auxiliaryData ? AuxiliaryData.fromCore(subTx.auxiliaryData) : undefined
    );
  }

  /**
   * Data structure that contains all key elements of the sub transaction.
   *
   * @returns A deep clone of the sub transaction body.
   */
  body(): SubTransactionBody {
    return SubTransactionBody.fromCbor(this.#body.toCbor());
  }

  /**
   * Sets the sub transaction body.
   *
   * @param body The sub transaction body.
   */
  setBody(body: SubTransactionBody) {
    this.#body = body;
    this.#originalBytes = undefined;
  }

  /**
   * Collection of digital signatures that are attached to the sub transaction to prove that it has been authorized
   * by the appropriate parties, the witness set also contain all required information to satisfy native or plutus
   * script execution requirements, such as Datums, Redeemers and the script itself.
   *
   * @returns A deep clone of the sub transaction witness set.
   */
  witnessSet(): TransactionWitnessSet {
    return TransactionWitnessSet.fromCbor(this.#witnessSet.toCbor());
  }

  /**
   * Sets the witness set of the sub transaction.
   *
   * @param witnessSet A deep clone of the witness set in this sub transaction.
   */
  setWitnessSet(witnessSet: TransactionWitnessSet) {
    this.#witnessSet = witnessSet;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the sub transaction Auxiliary data.
   *
   * @returns A clone of the sub transaction Auxiliary data (or undefined if the sub transaction doesnt have
   * auxiliary data).
   */
  auxiliaryData(): AuxiliaryData | undefined {
    if (this.#auxiliaryData) {
      return AuxiliaryData.fromCbor(this.#auxiliaryData.toCbor());
    }

    return undefined;
  }

  /**
   * Sets the sub transaction auxiliary data.
   *
   * The auxiliary is additional information that can be attached to the sub transaction to provide more context or
   * information about it.
   *
   * @param auxiliaryData The auxiliary data to be set.
   */
  setAuxiliaryData(auxiliaryData?: AuxiliaryData) {
    this.#auxiliaryData = auxiliaryData;
    this.#originalBytes = undefined;
  }

  /**
   * Computes the transaction id for this sub transaction.
   *
   * Sub transaction ids follow the top level transaction id convention: the blake2b-256 hash of
   * the body bytes.
   */
  getId(): Cardano.TransactionId {
    return Crypto.blake2b.hash<Cardano.TransactionId>(this.#body.toCbor(), 32);
  }

  /** Performs a deep clone of the sub transaction object. */
  clone(): SubTransaction {
    const bytes = this.toCbor();
    return SubTransaction.fromCbor(bytes);
  }
}
