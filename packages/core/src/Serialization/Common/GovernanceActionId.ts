import { GovernanceActionId as CardanoGovernanceActionId, TransactionId } from '../../Cardano/types';
import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * Each governance action that is accepted on the chain will be assigned a unique
 * identifier, consisting of the transaction hash that created it and the index within
 * the transaction body that points to it.
 */
export class GovernanceActionId {
  #id: TransactionId;
  #index: bigint;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the GovernanceActionId class.
   *
   * @param id transaction hash that created it this governance action.
   * @param index index within the transaction body that points to it.
   */
  constructor(id: TransactionId, index: bigint) {
    this.#id = id;
    this.#index = index;
  }

  /**
   * Serializes a GovernanceActionId into CBOR format.
   *
   * @returns The GovernanceActionId in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // gov_action_id =
    //   [ transaction_id   : $hash32
    //   , gov_action_index : uint
    //   ]
    const writer = new CborWriter();

    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeByteString(Buffer.from(this.#id, 'hex'));
    writer.writeInt(this.#index);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the GovernanceActionId from a CBOR byte array.
   *
   * @param cbor The CBOR encoded GovernanceActionId object.
   * @returns The new GovernanceActionId instance.
   */
  static fromCbor(cbor: HexBlob): GovernanceActionId {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );
    const txId = reader.readByteString();
    const index = reader.readInt();

    const input = new GovernanceActionId(HexBlob.fromBytes(txId) as unknown as TransactionId, index);
    input.#originalBytes = cbor;

    return input;
  }

  /**
   * Creates a Core GovernanceActionId object from the current GovernanceActionId object.
   *
   * @returns The Core GovernanceActionId object.
   */
  toCore(): CardanoGovernanceActionId {
    return {
      actionIndex: Number(this.#index),
      id: this.#id
    };
  }

  /**
   * Creates a GovernanceActionId object from the given Core GovernanceActionId object.
   *
   * @param coreGovernanceActionId The core GovernanceActionId object.
   */
  static fromCore(coreGovernanceActionId: CardanoGovernanceActionId): GovernanceActionId {
    return new GovernanceActionId(coreGovernanceActionId.id, BigInt(coreGovernanceActionId.actionIndex));
  }

  /**
   * This is an identifier of a previous transaction. It points to the transaction where the UTxO being
   * spent was created.
   *
   * @returns The identifier of the previous transaction where the UTxO being
   * spent was created.
   */
  transactionId(): TransactionId {
    return this.#id;
  }

  /**
   * Sets the identifier of the previous transaction where the UTxO being
   * spent was created.
   *
   * @param id The identifier of the previous transaction.
   */
  setTransactionId(id: TransactionId) {
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

  /**
   * Indicates whether some other GovernanceActionId is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: GovernanceActionId): boolean {
    return this.#index === other.#index && this.#id === other.#id;
  }
}
