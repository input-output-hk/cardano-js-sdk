import * as Cardano from '../../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR';
import { ExUnits } from '../../Common';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { PlutusData } from '../../PlutusData';
import { RedeemerTag } from './RedeemerTag';
import { hexToBytes } from '../../../util/misc';

const REDEEMER_ARRAY_SIZE = 4;
const HASH_LENGTH_IN_BYTES = 32;

/**
 * The Redeemer is an argument provided to a Plutus smart contract (script) when
 * you are attempting to redeem a UTxO that's protected by that script.
 */
export class Redeemer {
  #tag: RedeemerTag;
  #index: bigint;
  #data: PlutusData;
  #exUnits: ExUnits;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Redeemer class.
   *
   * @param tag a tag that specifies the purpose of the redeemer in the transaction.
   * @param index The index of the transaction input this redeemer is intended for. The transaction inputs
   * are indexed in the map order by their transaction id.
   * @param data The data that will be provided as an argument to the plutus script.
   * @param exUnits The computational resources required to execute the Plutus script on the UTxO this redeemer is intended for.
   */
  constructor(tag: RedeemerTag, index: bigint, data: PlutusData, exUnits: ExUnits) {
    this.#tag = tag;
    this.#index = index;
    this.#data = data;
    this.#exUnits = exUnits;
  }

  /**
   * Serializes a Redeemer into CBOR format.
   *
   * @returns The Redeemer in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // redeemer = [ tag: redeemer_tag, index: uint, data: plutus_data, ex_units: ex_units ]
    writer.writeStartArray(REDEEMER_ARRAY_SIZE);
    writer.writeInt(this.#tag);
    writer.writeInt(this.#index);
    writer.writeEncodedValue(hexToBytes(this.#data.toCbor()));
    writer.writeEncodedValue(hexToBytes(this.#exUnits.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Redeemer from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Redeemer object.
   * @returns The new Redeemer instance.
   */
  static fromCbor(cbor: HexBlob): Redeemer {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== REDEEMER_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${REDEEMER_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const tag = Number(reader.readUInt()) as RedeemerTag;
    const index = reader.readUInt();
    const data = PlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const exUnits = ExUnits.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    reader.readEndArray();

    const redeemer = new Redeemer(tag, index, data, exUnits);
    redeemer.#originalBytes = cbor;

    return redeemer;
  }

  /**
   * Creates a Core Redeemer object from the current Redeemer object.
   *
   * @returns The Core Redeemer object.
   */
  toCore(): Cardano.Redeemer {
    let purpose: Cardano.RedeemerPurpose;

    switch (this.#tag) {
      case RedeemerTag.Spend:
        purpose = Cardano.RedeemerPurpose.spend;
        break;
      case RedeemerTag.Mint:
        purpose = Cardano.RedeemerPurpose.mint;
        break;
      case RedeemerTag.Cert:
        purpose = Cardano.RedeemerPurpose.certificate;
        break;
      case RedeemerTag.Reward:
        purpose = Cardano.RedeemerPurpose.withdrawal;
        break;
      case RedeemerTag.Voting:
        purpose = Cardano.RedeemerPurpose.vote;
        break;
      case RedeemerTag.Proposing:
        purpose = Cardano.RedeemerPurpose.propose;
        break;
      default:
        throw new InvalidStateError(`Invalid redeemer type ${this.#tag}`);
    }

    return {
      data: this.#data.toCore(),
      executionUnits: this.#exUnits.toCore(),
      index: Number(this.#index),
      purpose
    };
  }

  /**
   * Creates a Redeemer object from the given Core Redeemer object.
   *
   * @param redeemer core Redeemer object.
   */
  static fromCore(redeemer: Cardano.Redeemer) {
    let tag: RedeemerTag;

    switch (redeemer.purpose) {
      case Cardano.RedeemerPurpose.spend:
        tag = RedeemerTag.Spend;
        break;
      case Cardano.RedeemerPurpose.mint:
        tag = RedeemerTag.Mint;
        break;
      case Cardano.RedeemerPurpose.certificate:
        tag = RedeemerTag.Cert;
        break;
      case Cardano.RedeemerPurpose.withdrawal:
        tag = RedeemerTag.Reward;
        break;
      case Cardano.RedeemerPurpose.vote:
        tag = RedeemerTag.Voting;
        break;
      case Cardano.RedeemerPurpose.propose:
        tag = RedeemerTag.Proposing;
        break;
      default:
        throw new InvalidStateError(`Invalid redeemer type ${redeemer.purpose}`);
    }

    return new Redeemer(
      tag,
      BigInt(redeemer.index),
      PlutusData.fromCore(redeemer.data),
      ExUnits.fromCore(redeemer.executionUnits)
    );
  }

  /**
   * Gets the tag that specifies the purpose of the redeemer in the transaction.
   *
   * @returns The tag with the purpose.
   */
  tag(): RedeemerTag {
    return this.#tag;
  }

  /**
   * Sets the tag that specifies the purpose of the redeemer in the transaction.
   *
   * @param tag The tag with the purpose.
   */
  setTag(tag: RedeemerTag) {
    this.#tag = tag;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the index of the transaction input this redeemer is intended for.
   *
   * @returns The index of the transaction input (the transaction inputs are indexed in the map order
   * by their transaction id)
   */
  index(): bigint {
    return this.#index;
  }

  /**
   * Sets the index of the transaction input this redeemer is intended for.
   *
   * @param index The index of the transaction input (the transaction inputs are indexed in the map order
   * by their transaction id)
   */
  setIndex(index: bigint) {
    this.#index = index;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the data that will be provided as an argument to the plutus script.
   *
   * @returns The plutus data.
   */
  data(): PlutusData {
    return this.#data;
  }

  /**
   * Sets the data that will be provided as an argument to the plutus script.
   *
   * @param data The plutus data.
   */
  setData(data: PlutusData) {
    this.#data = data;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the computational resources required to execute a Plutus script on the
   * UTxO this redeemer is intended for.
   *
   * @returns The computational resources required to execute the Plutus script.
   */
  exUnits(): ExUnits {
    return this.#exUnits;
  }

  /**
   * Sets the computational resources required to execute a Plutus script on the
   * UTxO this redeemer is intended for.
   *
   * @param exUnits The computational resources required to execute the Plutus script.
   */
  setExUnits(exUnits: ExUnits) {
    this.#exUnits = exUnits;
    this.#originalBytes = undefined;
  }

  /**
   * Computes the redeemer hash.
   *
   * @returns the redeemer hash.
   */
  hash(): Crypto.Hash32ByteBase16 {
    const hash = Crypto.blake2b(HASH_LENGTH_IN_BYTES).update(Buffer.from(this.toCbor(), 'hex')).digest();

    return Crypto.Hash32ByteBase16(HexBlob.fromBytes(hash));
  }
}
