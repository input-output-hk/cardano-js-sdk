/* eslint-disable max-statements */
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { CborSet, Credential, UnitInterval } from '../../Common';
import { CommitteeMember, GovernanceActionType } from '../../../Cardano/types/Governance';
import { EpochNo } from '../../../Cardano/types/Block';
import { GovernanceActionId } from '../../Common/GovernanceActionId';
import { GovernanceActionKind } from './GovernanceActionKind';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../../util/misc';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 5;
const CREDENTIAL_ARRAY_SIZE = 2;
const CREDENTIAL_INDEX = 0;
const EPOCH_INDEX = 1;

type CredentialSet = CborSet<ReturnType<Credential['toCore']>, Credential>;

/** Modifies the composition of the constitutional committee, its signature threshold, or its terms of operation. */
export class UpdateCommittee {
  #govActionId: GovernanceActionId | undefined;
  #membersToBeRemoved: CredentialSet;
  #membersToBeAdded: [Cardano.Credential, number][];
  #newQuorum: UnitInterval;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Creates a new UpdateCommittee instance.
   *
   * @param membersToBeRemoved Constitutional committee members to be removed.
   * @param membersToBeAdded Constitutional committee members to be added.
   * @param newQuorum The new quorum threshold.
   * @param govActionId Previous governance action id of `UpdateCommittee`.
   */
  constructor(
    membersToBeRemoved: CredentialSet,
    membersToBeAdded: [Cardano.Credential, number][],
    newQuorum: UnitInterval,
    govActionId?: GovernanceActionId
  ) {
    this.#membersToBeRemoved = membersToBeRemoved;
    this.#membersToBeAdded = membersToBeAdded;
    this.#newQuorum = newQuorum;
    this.#govActionId = govActionId;
  }

  /**
   * Serializes a UpdateCommittee into CBOR format.
   *
   * @returns The UpdateCommittee in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // update_committee = (4, gov_action_id / null, set<committee_cold_credential>, { committee_cold_credential => epoch }, unit_interval)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(GovernanceActionKind.UpdateCommittee);
    this.#govActionId ? writer.writeEncodedValue(hexToBytes(this.#govActionId.toCbor())) : writer.writeNull();

    writer.writeEncodedValue(hexToBytes(this.#membersToBeRemoved.toCbor()));

    writer.writeStartMap(this.#membersToBeAdded.length);
    for (const entry of this.#membersToBeAdded) {
      writer.writeStartArray(CREDENTIAL_ARRAY_SIZE);
      writer.writeInt(entry[CREDENTIAL_INDEX].type);
      writer.writeByteString(hexToBytes(entry[CREDENTIAL_INDEX].hash as unknown as HexBlob));

      writer.writeInt(entry[EPOCH_INDEX]);
    }

    writer.writeEncodedValue(hexToBytes(this.#newQuorum.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the UpdateCommittee from a CBOR byte array.
   *
   * @param cbor The CBOR encoded UpdateCommittee object.
   * @returns The new UpdateCommittee instance.
   */
  static fromCbor(cbor: HexBlob): UpdateCommittee {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readUInt());

    if (kind !== GovernanceActionKind.UpdateCommittee)
      throw new InvalidArgumentError(
        'cbor',
        `Expected action kind, expected ${GovernanceActionKind.UpdateCommittee} but got ${kind}`
      );

    let govActionId;
    if (reader.peekState() === CborReaderState.Null) {
      reader.readNull();
    } else {
      govActionId = GovernanceActionId.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    }

    const membersToRemove: CredentialSet = CborSet.fromCbor(
      HexBlob.fromBytes(reader.readEncodedValue()),
      Credential.fromCbor
    );

    reader.readStartMap();

    const membersToAdd: [Cardano.Credential, number][] = [];
    while (reader.peekState() !== CborReaderState.EndMap) {
      if (reader.readStartArray() !== CREDENTIAL_ARRAY_SIZE)
        throw new InvalidArgumentError(
          'cbor',
          `Expected an array of ${CREDENTIAL_ARRAY_SIZE} elements, but got an array of ${length} elements`
        );

      const type = Number(reader.readUInt());
      const hash = HexBlob.fromBytes(reader.readByteString()) as unknown as Hash28ByteBase16;

      reader.readEndArray();
      const epoch = Number(reader.readUInt());

      membersToAdd.push([{ hash, type }, epoch]);
    }

    reader.readEndMap();

    const quorumThreshold = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const action = new UpdateCommittee(membersToRemove, membersToAdd, quorumThreshold, govActionId);
    action.#originalBytes = cbor;

    return action;
  }

  /**
   * Creates a Core UpdateCommittee object from the current UpdateCommittee object.
   *
   * @returns The Core UpdateCommittee object.
   */
  toCore(): Cardano.UpdateCommittee {
    return {
      __typename: GovernanceActionType.update_committee,
      governanceActionId: this.#govActionId ? this.#govActionId.toCore() : null,
      membersToBeAdded: new Set<CommitteeMember>(
        this.#membersToBeAdded.map((entry) => ({
          coldCredential: entry[CREDENTIAL_INDEX],
          epoch: EpochNo(entry[EPOCH_INDEX])
        }))
      ),
      membersToBeRemoved: new Set<Cardano.Credential>(this.#membersToBeRemoved.toCore()),
      newQuorumThreshold: this.#newQuorum.toCore()
    };
  }

  /**
   * Creates a UpdateCommittee object from the given Core UpdateCommittee object.
   *
   * @param updateCommittee core UpdateCommittee object.
   */
  static fromCore(updateCommittee: Cardano.UpdateCommittee) {
    return new UpdateCommittee(
      CborSet.fromCore([...updateCommittee.membersToBeRemoved], Credential.fromCore),
      [...updateCommittee.membersToBeAdded].map((entry) => [entry.coldCredential, entry.epoch]),
      UnitInterval.fromCore(updateCommittee.newQuorumThreshold),
      updateCommittee.governanceActionId !== null
        ? GovernanceActionId.fromCore(updateCommittee.governanceActionId)
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
   * Gets the committee members to be removed by this update.
   *
   * @returns the committee members to be removed.
   */
  membersToBeRemoved(): Cardano.Credential[] {
    return this.#membersToBeRemoved.toCore();
  }

  /**
   * Gets the committee members to be added by this update.
   *
   * @returns the committee members to be added.
   */
  membersToBeAdded(): [Cardano.Credential, number][] {
    return this.#membersToBeAdded;
  }

  /**
   * Gets the new minimum number (as percentage) of the Constitutional Committee members
   * that must participate in a vote for the outcome to be considered valid.
   *
   * @returns the new quorum threshold.
   */
  newQuorum(): UnitInterval {
    return this.#newQuorum;
  }
}
