/* eslint-disable complexity, sonarjs/cognitive-complexity, max-statements, max-depth */
import * as Crypto from '@cardano-sdk/crypto';
import { Address } from '../../Cardano/Address';
import { CborReader, CborReaderState, CborTag, CborWriter } from '../CBOR';
import { Datum, DatumKind } from '../Common/Datum';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { PlutusData } from '../PlutusData';
import { Script } from '../Scripts';
import { Value } from './Value';
import type * as Cardano from '../../Cardano';

export const REQUIRED_FIELDS_COUNT = 2;

/**
 * A TransactionOutput object includes the address which represents a public key
 * hash or a script hash that can unlock the output, and the funds that are held
 * inside.
 */
export class TransactionOutput {
  #address: Cardano.Address;
  #amount: Value;
  #datum: Datum | undefined;
  #scriptRef: Script | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the TransactionOutput class.
   *
   * @param address The destination address where the ADA (and possibly other native tokens) is being sent.
   * @param amount The amount of ADA and any other native tokens being sent to the address.
   */
  constructor(address: Cardano.Address, amount: Value) {
    this.#address = address;
    this.#amount = amount;
  }

  /**
   * Serializes a TransactionOutput into CBOR format.
   *
   * @returns The TransactionOutput in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // transaction_output = legacy_transaction_output / post_alonzo_transaction_output ; New
    const writer = new CborWriter();

    const elementsSize = this.#getMapSize();

    // if possible, we encode as the more compact format.
    if (
      elementsSize === REQUIRED_FIELDS_COUNT ||
      (elementsSize === 3 && this.#datum !== undefined && this.#datum.kind() === DatumKind.DataHash)
    ) {
      writer.writeStartArray(elementsSize);
      writer.writeByteString(Buffer.from(this.#address.toBytes(), 'hex'));
      writer.writeEncodedValue(Buffer.from(this.#amount.toCbor(), 'hex'));

      if (this.#datum !== undefined) {
        writer.writeByteString(Buffer.from(this.#datum.asDataHash()!, 'hex'));
      }
    } else {
      writer.writeStartMap(elementsSize);

      writer.writeInt(0n);
      writer.writeByteString(Buffer.from(this.#address.toBytes(), 'hex'));

      writer.writeInt(1n);
      writer.writeEncodedValue(Buffer.from(this.#amount.toCbor(), 'hex'));

      if (this.#datum !== undefined) {
        writer.writeInt(2n);

        writer.writeStartArray(2);
        writer.writeInt(this.#datum.kind());

        switch (this.#datum.kind()) {
          case DatumKind.DataHash:
            writer.writeByteString(Buffer.from(this.#datum.asDataHash()!, 'hex'));
            break;
          case DatumKind.InlineData:
            writer.writeTag(CborTag.EncodedCborDataItem);
            writer.writeByteString(Buffer.from(this.#datum.asInlineData()!.toCbor(), 'hex'));
            break;
        }
      }

      if (this.#scriptRef !== undefined) {
        writer.writeInt(3n);
        writer.writeTag(CborTag.EncodedCborDataItem);
        writer.writeByteString(Buffer.from(this.#scriptRef.toCbor(), 'hex'));
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TransactionOutput from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TransactionOutput object.
   * @returns The new TransactionOutput instance.
   */
  static fromCbor(cbor: HexBlob): TransactionOutput {
    const reader = new CborReader(cbor);

    let address;
    let value;
    let datum;
    let scriptRef;

    if (reader.peekState() === CborReaderState.StartMap) {
      // CDDL
      // post_alonzo_transaction_output =
      //   { 0 : address
      //   , 1 : value
      //   , ? 2 : datum_option ; New; datum option
      //   , ? 3 : script_ref   ; New; script reference
      //   }
      reader.readStartMap();

      while (reader.peekState() !== CborReaderState.EndMap) {
        const key = reader.readInt();

        switch (key) {
          case 0n:
            address = Address.fromBytes(HexBlob.fromBytes(reader.readByteString()));
            break;
          case 1n:
            value = Value.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
            break;
          case 2n: {
            const datumReader = new CborReader(HexBlob.fromBytes(reader.readEncodedValue()));

            datumReader.readStartArray();

            const datumKind = Number(datumReader.readInt());

            if (datumKind === DatumKind.InlineData) {
              const tag = datumReader.readTag();

              if (tag !== CborTag.EncodedCborDataItem)
                throw new InvalidArgumentError('cbor', `Expected tag ${CborTag.EncodedCborDataItem} but got ${tag}`);
            }

            const encodedDatum = datumReader.readByteString();
            let dataHash;
            let inlineDatum;

            if (datumKind === DatumKind.DataHash)
              dataHash = HexBlob.fromBytes(encodedDatum) as unknown as Crypto.Hash32ByteBase16;

            if (datumKind === DatumKind.InlineData) inlineDatum = PlutusData.fromCbor(HexBlob.fromBytes(encodedDatum));

            datum = new Datum(dataHash, inlineDatum);
            break;
          }
          case 3n: {
            const scriptReader = new CborReader(HexBlob.fromBytes(reader.readEncodedValue()));

            const tag = scriptReader.readTag();

            if (tag !== CborTag.EncodedCborDataItem)
              throw new InvalidArgumentError('cbor', `Expected tag ${CborTag.EncodedCborDataItem} but got ${tag}`);

            const encodedDatum = scriptReader.readByteString();

            scriptRef = Script.fromCbor(HexBlob.fromBytes(encodedDatum));
            break;
          }
        }
      }

      reader.readEndMap();
    } else {
      // legacy_transaction_output =
      //   [ address
      //   , amount : value
      //   , ? datum_hash : $hash32
      //   ]
      const length = reader.readStartArray();

      address = Address.fromBytes(HexBlob.fromBytes(reader.readByteString()));
      value = Value.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

      if (length === 3) {
        const datumHash = reader.readByteString();
        datum = Datum.newDataHash(HexBlob.fromBytes(datumHash) as unknown as Crypto.Hash32ByteBase16);
      }
    }

    if (!address) throw new InvalidArgumentError('cbor', 'Transaction output does not contain an address.');
    if (!value) throw new InvalidArgumentError('cbor', 'Transaction output does not contain a value.');

    const output = new TransactionOutput(address, value);

    if (datum) output.setDatum(datum);
    if (scriptRef) output.setScriptRef(scriptRef);

    output.#originalBytes = cbor;

    return output;
  }

  /**
   * Creates a Core TransactionOutput object from the current TransactionOutput object.
   *
   * @returns The Core TransactionOutput object.
   */
  toCore(): Cardano.TxOut {
    const value = this.#amount.toCore();
    if (!value.assets) delete value.assets;

    const txOut: Cardano.TxOut = {
      address: this.#address.asByron()
        ? this.#address.toBase58()
        : (this.#address.toBech32() as unknown as Cardano.PaymentAddress),
      value
    };

    if (this.#datum && this.#datum.kind() === DatumKind.InlineData) txOut.datum = this.#datum.asInlineData()?.toCore();
    if (this.#datum && this.#datum.kind() === DatumKind.DataHash) txOut.datumHash = this.#datum.asDataHash();
    if (this.#scriptRef) txOut.scriptReference = this.#scriptRef.toCore();

    return txOut;
  }

  /**
   * Creates a TransactionOutput object from the given Core TransactionOutput object.
   *
   * @param coreTransactionOutput The core TransactionOutput object.
   */
  static fromCore(coreTransactionOutput: Cardano.TxOut): TransactionOutput {
    const address = Address.fromString(coreTransactionOutput.address);

    if (!address) throw new InvalidArgumentError('coreTransactionOutput', `Invalid address ${address}`);

    const out = new TransactionOutput(address, Value.fromCore(coreTransactionOutput.value));

    if (coreTransactionOutput.datum) out.setDatum(Datum.fromCore(coreTransactionOutput.datum));
    if (coreTransactionOutput.datumHash) out.setDatum(Datum.fromCore(coreTransactionOutput.datumHash));
    if (coreTransactionOutput.scriptReference) out.setScriptRef(Script.fromCore(coreTransactionOutput.scriptReference));

    return out;
  }

  /**
   * Gets the destination address where the ADA (and possibly other native tokens) is being sent.
   *
   * @returns the address where the ADA is being sent.
   */
  address(): Cardano.Address {
    return this.#address;
  }

  /**
   * Gets the amount of ADA and any other native tokens being sent to the address.
   *
   * @returns The amount of ADA and native tokens being sent.
   */
  amount(): Value {
    return this.#amount;
  }

  /**
   * Gets the datum (if any) associated with this output. The Datum acts as a piece of
   * state for the UTxO, and Plutus scripts can use this state to determine their behavior.
   *
   * @returns the datum associated with this output or undefined if none.
   */
  datum(): Datum | undefined {
    return this.#datum;
  }

  /**
   * Sets the datum associated with this output. The Datum acts as a piece of
   * state for the UTxO, and Plutus scripts can use this state to determine their behavior.
   *
   * @param data the datum that we want to associate with this output.
   */
  setDatum(data: Datum): void {
    this.#datum = data;
  }

  /**
   * The key idea is to use reference inputs and modified outputs which carry actual scripts ("reference scripts"), and
   * allow such reference scripts to satisfy the script witnessing requirement for a transaction.
   *
   * This means that the transaction which uses the script will not need to provide it at all, so long as it referenced
   * an output which contained the script.
   *
   * @returns The script reference.
   */
  scriptRef(): Script | undefined {
    return this.#scriptRef;
  }

  /**
   * Sets the script reference for this output.
   *
   * @param script The script reference.
   */
  setScriptRef(script: Script): void {
    this.#scriptRef = script;
  }

  /**
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = REQUIRED_FIELDS_COUNT;

    if (this.#datum) ++mapSize;
    if (this.#scriptRef) ++mapSize;

    return mapSize;
  }
}
