import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';

/**
 * Represents a multi-signature transaction for the Cardano blockchain.
 * This transaction can be serialized and transfer between participants of the multisig wallet.
 * The transaction carries a bit of extra context, such as the expected signers and the signatures
 * of the signers who have already signed. this way the participants will know if the transaction is ready to be sent,
 * or they need to relay the transaction to additional participants (and to whom) for additional signing.
 */
export class MultiSigTx {
  #transaction: Cardano.Tx;
  #expectedSigners: Array<Crypto.Ed25519PublicKeyHex> = [];

  /**
   * Initializes a new instance of the MultiSigTx class.
   *
   * @param {Cardano.Tx} transaction - The underlying Cardano transaction.
   * @param {Array<Crypto.Ed25519PublicKeyHex>} expectedSigners - An array of expected signers' public keys.
   */
  constructor(transaction: Cardano.Tx, expectedSigners: Array<Crypto.Ed25519PublicKeyHex>) {
    this.#transaction = transaction;
    this.#expectedSigners = expectedSigners;
  }

  /**
   * Serializes the multi-signature transaction to a CBOR hex blob.
   *
   * @returns {HexBlob} The serialized transaction as a hex-encoded string.
   */
  toCbor(): HexBlob {
    const writer = new Serialization.CborWriter();

    writer.writeStartArray(2);
    writer.writeStartArray(this.#expectedSigners.length);

    for (const signer of this.#expectedSigners) {
      writer.writeByteString(Buffer.from(signer, 'hex'));
    }

    writer.writeEncodedValue(Buffer.from(Serialization.Transaction.fromCore(this.#transaction).toCbor(), 'hex'));
    return writer.encodeAsHex();
  }

  /**
   * Deserializes a CBOR hex blob into a MultiSigTx instance.
   *
   * @param {HexBlob} cbor - The CBOR hex blob representing the transaction.
   * @returns {MultiSigTx} The deserialized MultiSigTx instance.
   */
  static fromCbor(cbor: HexBlob): MultiSigTx {
    const reader = new Serialization.CborReader(cbor);

    reader.readStartArray();
    const length = reader.readStartArray();
    const expectedSigners: Array<Crypto.Ed25519PublicKeyHex> = [];

    if (length === null || length <= 0) throw new Error('Expected at least one signer');

    for (let i = 0; i < length; i++)
      expectedSigners.push(Crypto.Ed25519PublicKeyHex(Buffer.from(reader.readByteString()).toString('hex')));

    reader.readEndArray();

    const transaction = Serialization.deserializeTx(reader.readEncodedValue());
    reader.readEndArray();

    return new MultiSigTx(transaction, expectedSigners);
  }

  /**
   * Checks whether the transaction has been fully signed.
   *
   * @returns {boolean} True if the transaction is fully signed, otherwise false.
   */
  isFullySigned(): boolean {
    return this.#expectedSigners.every((signer) => this.#transaction.witness.signatures.has(signer));
  }

  /**
   * Retrieves the original Cardano transaction.
   *
   * @returns {Cardano.Tx} The Cardano transaction.
   */
  getTransaction(): Cardano.Tx {
    return this.#transaction;
  }

  /**
   * Identifies and returns the public keys of signers who have not yet signed the transaction.
   *
   * @returns {Array<Crypto.Ed25519PublicKeyHex>} An array of public keys of the missing signers.
   */
  getMissingSigners(): Array<Crypto.Ed25519PublicKeyHex> {
    const missingSigners: Array<Crypto.Ed25519PublicKeyHex> = [];

    for (const signer of this.#expectedSigners)
      if (!this.#transaction.witness.signatures.has(signer)) missingSigners.push(signer);

    return missingSigners;
  }

  /**
   * Identifies and returns the public keys of signers who have signed the transaction.
   *
   * @returns {Array<Crypto.Ed25519PublicKeyHex>} An array of public keys of the signers who have already signed.
   */
  getAccountedForSigners(): Array<Crypto.Ed25519PublicKeyHex> {
    const accountedSigners: Array<Crypto.Ed25519PublicKeyHex> = [];

    for (const signer of this.#expectedSigners)
      if (this.#transaction.witness.signatures.has(signer)) accountedSigners.push(signer);

    return accountedSigners;
  }
}
