/* eslint-disable complexity,max-statements,sonarjs/cognitive-complexity */
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionMetadatum } from './TransactionMetadatum.js';
import { hexToBytes } from '../../../util/misc/index.js';
import type * as Cardano from '../../../Cardano/index.js';

/** General Transaction Metadata. */
export class GeneralTransactionMetadata {
  #metadata: Map<bigint, TransactionMetadatum>;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the GeneralTransactionMetadata class.
   *
   * @param metadata The general transaction metadata.
   */
  constructor(metadata: Map<bigint, TransactionMetadatum>) {
    this.#metadata = metadata;
  }

  /**
   * Serializes a GeneralTransactionMetadata into CBOR format.
   *
   * @returns The GeneralTransactionMetadata in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // metadata = { * transaction_metadatum_label => transaction_metadatum }
    const writer = new CborWriter();
    writer.writeStartMap(this.#metadata.size);

    for (const [key, val] of this.#metadata.entries()) {
      writer.writeInt(key);
      writer.writeEncodedValue(hexToBytes(val.toCbor()));
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the GeneralTransactionMetadata from a CBOR byte array.
   *
   * @param cbor The CBOR encoded GeneralTransactionMetadata object.
   * @returns The new GeneralTransactionMetadata instance.
   */
  static fromCbor(cbor: HexBlob): GeneralTransactionMetadata {
    const generalTransactionMetadata = new Map();

    const reader = new CborReader(cbor);
    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const label = reader.readInt();
      const metadatum = TransactionMetadatum.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
      generalTransactionMetadata.set(label, metadatum);
    }

    reader.readEndMap();

    return new GeneralTransactionMetadata(generalTransactionMetadata);
  }

  /**
   * Creates a Core GeneralTransactionMetadata object from the current GeneralTransactionMetadata object.
   *
   * @returns The Core GeneralTransactionMetadata object.
   */
  toCore(): Cardano.TxMetadata {
    return new Map([...this.#metadata.entries()].map((metadata) => [metadata[0], metadata[1].toCore()]));
  }

  /**
   * Creates a GeneralTransactionMetadata object from the given Core GeneralTransactionMetadata object.
   *
   * @param metadata The core GeneralTransactionMetadata object.
   */
  static fromCore(metadata: Cardano.TxMetadata): GeneralTransactionMetadata {
    return new GeneralTransactionMetadata(
      new Map([...metadata.entries()].map((entry) => [entry[0], TransactionMetadatum.fromCore(entry[1])]))
    );
  }

  /**
   * Gets the transaction metadata. this is supplementary information that can be
   * attached to a transaction. It's not essential for transaction validation but
   * can be used for various purposes, including record-keeping, identity solutions, and more.
   *
   * @returns The transaction metadata.
   */
  metadata(): Map<bigint, TransactionMetadatum> | undefined {
    return this.#metadata;
  }

  /**
   * Sets the transaction metadata. this is supplementary information that can be
   * attached to a transaction. It's not essential for transaction validation but
   * can be used for various purposes, including record-keeping, identity solutions, and more.
   *
   * @param metadata The transaction metadata.
   */
  setMetadata(metadata: Map<bigint, TransactionMetadatum>) {
    this.#metadata = metadata;
    this.#originalBytes = undefined;
  }

  /**
   * Indicates whether some other PlutusMap is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: GeneralTransactionMetadata): boolean {
    if (this.#originalBytes === other.#originalBytes) return true;
    if (this.#metadata.size !== other.#metadata.size) return false;

    const thisEntries = [...this.#metadata.entries()];
    const otherEntries = [...other.#metadata.entries()];

    for (let i = 0; i < this.#metadata.size; ++i) {
      if (thisEntries[i][0] !== otherEntries[i][0]) return false;
      if (!thisEntries[i][1].equals(otherEntries[i][1])) return false;
    }

    return true;
  }
}
