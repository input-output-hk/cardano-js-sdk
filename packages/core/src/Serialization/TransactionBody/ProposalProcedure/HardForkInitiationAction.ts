import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { GovernanceActionId } from '../../Common/GovernanceActionId';
import { GovernanceActionKind } from './GovernanceActionKind';
import { GovernanceActionType } from '../../../Cardano/types/Governance';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { ProtocolVersion } from '../../Common';
import { hexToBytes } from '../../../util/misc';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 3;

/** Represents the initiation action for a hard fork in the Cardano network. */
export class HardForkInitiationAction {
  #protocolVersion: ProtocolVersion;
  #govActionId: GovernanceActionId | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new HardForkInitiationAction instance.
   *
   * @param protocolVersion The protocol version for the hard fork.
   * @param govActionId The optional unique identifier for this governance action.
   */
  constructor(protocolVersion: ProtocolVersion, govActionId?: GovernanceActionId) {
    this.#protocolVersion = protocolVersion;
    this.#govActionId = govActionId;
  }

  /**
   * Serializes a HardForkInitiationAction into CBOR format.
   *
   * @returns The HardForkInitiationAction in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // hard_fork_initiation_action = (1, gov_action_id / null, protocol_version)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(GovernanceActionKind.HardForkInitiation);
    this.#govActionId ? writer.writeEncodedValue(hexToBytes(this.#govActionId.toCbor())) : writer.writeNull();

    writer.writeEncodedValue(hexToBytes(this.#protocolVersion.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the HardForkInitiationAction from a CBOR byte array.
   *
   * @param cbor The CBOR encoded HardForkInitiationAction object.
   * @returns The new HardForkInitiationAction instance.
   */
  static fromCbor(cbor: HexBlob): HardForkInitiationAction {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.HardForkInitiation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.HardForkInitiation} but got ${kind}`
      );

    let govActionId;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      govActionId = GovernanceActionId.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    const protocolVersion = ProtocolVersion.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const action = new HardForkInitiationAction(protocolVersion, govActionId);
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core HardForkInitiationAction object from the current HardForkInitiationAction object.
   *
   * @returns The Core HardForkInitiationAction object.
   */
  toCore(): Cardano.HardForkInitiationAction {
    return {
      __typename: GovernanceActionType.hard_fork_initiation_action,
      governanceActionId: this.#govActionId ? this.#govActionId.toCore() : null,
      protocolVersion: this.#protocolVersion.toCore()
    };
  }

  /**
   * Creates a HardForkInitiationAction object from the given Core HardForkInitiationAction object.
   *
   * @param hardForkInitiationAction core HardForkInitiationAction object.
   */
  static fromCore(hardForkInitiationAction: Cardano.HardForkInitiationAction) {
    return new HardForkInitiationAction(
      ProtocolVersion.fromCore(hardForkInitiationAction.protocolVersion),
      hardForkInitiationAction.governanceActionId !== null
        ? GovernanceActionId.fromCore(hardForkInitiationAction.governanceActionId)
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
   * Retrieves the protocol version associated with the hard fork initiation action.
   *
   * @returns The protocol version for the hard fork.
   */
  protocolVersion(): ProtocolVersion {
    return this.#protocolVersion;
  }
}
