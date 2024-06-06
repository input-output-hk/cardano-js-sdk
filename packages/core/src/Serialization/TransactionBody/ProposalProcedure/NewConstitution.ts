import * as Cardano from '../../../Cardano/index.js';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { Constitution } from './Constitution.js';
import { GovernanceActionId } from '../../Common/GovernanceActionId.js';
import { GovernanceActionKind } from './GovernanceActionKind.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../../util/misc/index.js';

const EMBEDDED_GROUP_SIZE = 3;

/** Changes or amendments the Constitution. */
export class NewConstitution {
  #constitution: Constitution;
  #govActionId: GovernanceActionId | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the NewConstitution class.
   *
   * @param constitution The new constitution.
   * @param govActionId The optional unique identifier for this governance action.
   */
  constructor(constitution: Constitution, govActionId?: GovernanceActionId) {
    this.#constitution = constitution;
    this.#govActionId = govActionId;
  }

  /**
   * Serializes a NewConstitution into CBOR format.
   *
   * @returns The NewConstitution in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // new_constitution = (5, gov_action_id / null, constitution)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(GovernanceActionKind.NewConstitution);
    this.#govActionId ? writer.writeEncodedValue(hexToBytes(this.#govActionId.toCbor())) : writer.writeNull();
    writer.writeEncodedValue(hexToBytes(this.#constitution.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the NewConstitution from a CBOR byte array.
   *
   * @param cbor The CBOR encoded NewConstitution object.
   * @returns The new NewConstitution instance.
   */
  static fromCbor(cbor: HexBlob): NewConstitution {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.NewConstitution)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.NewConstitution} but got ${kind}`
      );

    let govActionId;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      govActionId = GovernanceActionId.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    const constitution = Constitution.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    const action = new NewConstitution(constitution, govActionId);
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core NewConstitution object from the current NewConstitution object.
   *
   * @returns The Core NewConstitution object.
   */
  toCore(): Cardano.NewConstitution {
    return {
      __typename: Cardano.GovernanceActionType.new_constitution,
      constitution: this.#constitution.toCore(),
      governanceActionId: this.#govActionId ? this.#govActionId.toCore() : null
    };
  }

  /**
   * Creates a NewConstitution object from the given Core NewConstitution object.
   *
   * @param newConstitution core NewConstitution object.
   */
  static fromCore(newConstitution: Cardano.NewConstitution) {
    return new NewConstitution(
      Constitution.fromCore(newConstitution.constitution),
      newConstitution.governanceActionId !== null
        ? GovernanceActionId.fromCore(newConstitution.governanceActionId)
        : undefined
    );
  }

  /**
   * Retrieves the governance action identifier.
   *
   * @returns The unique identifier for this governance action or undefined if not set.
   */
  govActionId(): GovernanceActionId | undefined {
    return this.#govActionId;
  }

  /**
   * Retrieves the constitution.
   *
   * @returns The constitution.
   */
  constitution(): Constitution {
    return this.#constitution;
  }
}
