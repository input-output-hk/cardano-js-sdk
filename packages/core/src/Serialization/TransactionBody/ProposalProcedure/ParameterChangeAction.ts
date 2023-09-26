import * as Cardano from '../../../Cardano';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { GovernanceActionId } from '../../Common/GovernanceActionId';
import { GovernanceActionKind } from './GovernanceActionKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { ProtocolParamUpdate } from '../../Update';
import { hexToBytes } from '../../../util/misc';

const EMBEDDED_GROUP_SIZE = 3;

/**
 * Updates one or more updatable protocol parameters,
 * excluding changes to major protocol versions (i.e., "hard forks").
 */
export class ParameterChangeAction {
  #protocolParamUpdate: ProtocolParamUpdate;
  #govActionId: GovernanceActionId | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new ParameterChangeAction instance.
   *
   * @param protocolParamUpdate The protocol parameter updates.
   * @param govActionId The optional unique identifier for this governance action.
   */
  constructor(protocolParamUpdate: ProtocolParamUpdate, govActionId?: GovernanceActionId) {
    this.#protocolParamUpdate = protocolParamUpdate;
    this.#govActionId = govActionId;
  }

  /**
   * Serializes a ParameterChangeAction into CBOR format.
   *
   * @returns The ParameterChangeAction in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // parameter_change_action = (0, gov_action_id / null, protocol_param_update)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(GovernanceActionKind.ParameterChange);
    this.#govActionId ? writer.writeEncodedValue(hexToBytes(this.#govActionId.toCbor())) : writer.writeNull();
    writer.writeEncodedValue(hexToBytes(this.#protocolParamUpdate.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ParameterChangeAction from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ParameterChangeAction object.
   * @returns The new ParameterChangeAction instance.
   */
  static fromCbor(cbor: HexBlob): ParameterChangeAction {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.ParameterChange)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.ParameterChange} but got ${kind}`
      );

    let govActionId;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      govActionId = GovernanceActionId.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    const parameterUpdate = ProtocolParamUpdate.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    const action = new ParameterChangeAction(parameterUpdate, govActionId);
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core ParameterChangeAction object from the current ParameterChangeAction object.
   *
   * @returns The Core ParameterChangeAction object.
   */
  toCore(): Cardano.ParameterChangeAction {
    return {
      __typename: Cardano.GovernanceActionType.parameter_change_action,
      governanceActionId: this.#govActionId ? this.#govActionId.toCore() : null,
      protocolParamUpdate: this.#protocolParamUpdate.toCore()
    };
  }

  /**
   * Creates a ParameterChangeAction object from the given Core ParameterChangeAction object.
   *
   * @param parameterChangeAction core ParameterChangeAction object.
   */
  static fromCore(parameterChangeAction: Cardano.ParameterChangeAction) {
    return new ParameterChangeAction(
      ProtocolParamUpdate.fromCore(parameterChangeAction.protocolParamUpdate),
      parameterChangeAction.governanceActionId !== null
        ? GovernanceActionId.fromCore(parameterChangeAction.governanceActionId)
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
   * Retrieves the protocol parameter update associated with the action.
   *
   * @returns The protocol parameter update.
   */
  protocolParamUpdate(): ProtocolParamUpdate {
    return this.#protocolParamUpdate;
  }
}
