import { NoConfidence as CardanoNoConfidence, GovernanceActionType } from '../../../Cardano/types/Governance';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { GovernanceActionId } from '../../Common/GovernanceActionId';
import { GovernanceActionKind } from './GovernanceActionKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../../util/misc';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * Propose a state of no-confidence in the current constitutional committee.
 * Allows Ada holders to challenge the authority granted to the existing committee.
 */
export class NoConfidence {
  #govActionId: GovernanceActionId | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new NoConfidence instance.
   *
   * @param govActionId The optional unique identifier for this governance action.
   */
  constructor(govActionId?: GovernanceActionId) {
    this.#govActionId = govActionId;
  }

  /**
   * Serializes a NoConfidence into CBOR format.
   *
   * @returns The NoConfidence in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // no_confidence = (3, gov_action_id / null)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(GovernanceActionKind.NoConfidence);
    this.#govActionId ? writer.writeEncodedValue(hexToBytes(this.#govActionId.toCbor())) : writer.writeNull();

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the NoConfidence from a CBOR byte array.
   *
   * @param cbor The CBOR encoded NoConfidence object.
   * @returns The new NoConfidence instance.
   */
  static fromCbor(cbor: HexBlob): NoConfidence {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.NoConfidence)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.NoConfidence}  but got ${kind}`
      );

    let govActionId;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      govActionId = GovernanceActionId.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    const action = new NoConfidence(govActionId);
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core NoConfidence object from the current NoConfidence object.
   *
   * @returns The Core NoConfidence object.
   */
  toCore(): CardanoNoConfidence {
    return {
      __typename: GovernanceActionType.no_confidence,
      governanceActionId: this.#govActionId ? this.#govActionId.toCore() : null
    };
  }

  /**
   * Creates a NoConfidence object from the given Core NoConfidence object.
   *
   * @param noConfidence core NoConfidence object.
   */
  static fromCore(noConfidence: CardanoNoConfidence) {
    return new NoConfidence(
      noConfidence.governanceActionId !== null
        ? GovernanceActionId.fromCore(noConfidence.governanceActionId)
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
}
