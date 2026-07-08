import { AuxiliaryData } from './AuxiliaryData';
import { CborReader, CborReaderState, CborWriter } from './CBOR';
import { DeserializationOptions } from './Common';
import { HexBlob, OpaqueString } from '@cardano-sdk/util';
import { TransactionBody } from './TransactionBody';
import { TransactionWitnessSet } from './TransactionWitnessSet';
import { hexToBytes } from '../util/misc';
import type * as Cardano from '../Cardano';

const ALONZO_ERA_TX_FRAME_SIZE = 4;

/** Transaction serialized as CBOR, encoded as hex string */
export type TxCBOR = OpaqueString<'TxCbor'> & HexBlob;
/** Transaction body serialized as CBOR, encoded as hex string */
export type TxBodyCBOR = OpaqueString<'TxBodyCbor'> & HexBlob;

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
  // No public setter: authored transactions always carry true; decode and fromCore preserve it.
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
   * Serializes a transaction into CBOR format.
   *
   * @returns The transaction in CBOR format.
   */
  toCbor(): TxCBOR {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // transaction_mempool =
    //   transaction /
    //   [ transaction_body
    //   , transaction_witness_set
    //   , true
    //   , auxiliary_data / nil
    //   ]
    //
    // is_valid is deprecated in the Dijkstra era; the 4-element grace-period frame is only
    // legal with the literal value true, which stays byte-compatible with Conway consumers.
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
   * @param options Deserialization options. When `strict` is true, throws on unknown map keys
   * instead of skipping them.
   * @returns The new transaction instance.
   */
  static fromCbor(cbor: TxCBOR, options?: DeserializationOptions): Transaction {
    const reader = new CborReader(cbor as unknown as HexBlob);

    const length = reader.readStartArray();

    const bodyBytes = reader.readEncodedValue();
    const body = TransactionBody.fromCbor(HexBlob.fromBytes(bodyBytes), options);

    const witnessSet = TransactionWitnessSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), options);

    // The is_valid flag was added in Alonzo; Mary era transactions only have three fields.
    // Alonzo through Conway record false for phase-2 failed transactions, so decode is permissive.
    let isValid = true;
    if (length === ALONZO_ERA_TX_FRAME_SIZE) isValid = reader.readBoolean();

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
    const tx: Cardano.Tx = {
      body: this.#body.toCore(),
      id: this.getId(),
      isValid: this.#isValid,
      witness: this.#witnessSet.toCore()
    };

    if (this.#auxiliaryData) {
      tx.auxiliaryData = this.#auxiliaryData.toCore();
    }

    return tx;
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

    if (typeof tx.isValid !== 'undefined') transaction.#isValid = tx.isValid;

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
   * Gets the transaction is_valid flag.
   *
   * The flag is deprecated in the Dijkstra era; it has no setter and authored transactions
   * always carry true. Transactions decoded from chain data surface the on-chain value.
   *
   * @returns The is_valid flag.
   */
  isValid(): boolean {
    return this.#isValid;
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
    return this.#body.hash();
  }

  /** Performs a deep clone of the transaction object. */
  clone(): Transaction {
    const bytes = this.toCbor();
    return Transaction.fromCbor(bytes);
  }
}

/**
 * @param tx Serialized as CBOR, encoded as hex string
 * @throws InvalidStringError
 */
export const TxCBOR = (tx: string): TxCBOR => HexBlob(tx) as unknown as TxCBOR;

/** Serialize transaction to hex-encoded CBOR */
TxCBOR.serialize = (tx: Cardano.Tx): TxCBOR => Transaction.fromCore(tx).toCbor() as unknown as TxCBOR;

/**
 * @param tx Serialized as CBOR, encoded as hex string
 * @throws InvalidStringError
 */
export const TxBodyCBOR = (tx: string): TxBodyCBOR => HexBlob(tx) as unknown as TxBodyCBOR;

/** Extract transaction body CBOR without re-serializing */
TxBodyCBOR.fromTxCBOR = (txCbor: TxCBOR) => Transaction.fromCbor(txCbor).body().toCbor() as unknown as TxBodyCBOR;

export const deserializeTx = ((txBody: Buffer | Uint8Array | string) => {
  const hex =
    txBody instanceof Buffer
      ? txBody.toString('hex')
      : txBody instanceof Uint8Array
      ? Buffer.from(txBody).toString('hex')
      : txBody;

  const transaction = Transaction.fromCbor(TxCBOR(hex));
  return transaction.toCore();
}) as (txBody: HexBlob | Buffer | Uint8Array | string) => Cardano.Tx<Cardano.TxBody>;

/** Deserialize transaction from hex-encoded CBOR */
TxCBOR.deserialize = (tx: TxCBOR): Cardano.Tx => deserializeTx(tx);
