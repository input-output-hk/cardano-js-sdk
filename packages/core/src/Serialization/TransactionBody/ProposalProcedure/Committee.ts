import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { UnitInterval } from '../../Common/index.js';
import { hexToBytes } from '../../../util/misc/index.js';
import type * as Cardano from '../../../Cardano/index.js';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';

const COMMITTEE_ARRAY_SIZE = 2;
const CREDENTIAL_ARRAY_SIZE = 2;
const CREDENTIAL_INDEX = 0;
const EPOCH_INDEX = 1;

/**
 * The constitutional committee represents a set of individuals or entities (each associated with a pair of Ed25519 credentials)
 * that are collectively responsible for ensuring that the Constitution is respected.
 *
 * Though it cannot be enforced on-chain, the constitutional committee is only supposed to vote on the constitutionality
 * of governance actions (which should thus ensure the long-term sustainability of the blockchain) and should be replaced
 * (via the no confidence action) if they overstep this boundary.
 */
export class Committee {
  #quorumThreshold: UnitInterval;
  #committeeColdCredentials: [Cardano.Credential, number][] = [];
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initialize a new instance of the Committee class.
   *
   * @param quorumThreshold The minimum number (as percentage) of the Constitutional Committee members
   * that must participate in a vote for the outcome to be considered valid.
   */
  constructor(quorumThreshold: UnitInterval) {
    this.#quorumThreshold = quorumThreshold;
  }

  /**
   * Serializes a Committee into CBOR format.
   *
   * @returns The Committee in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();
    if (this.#originalBytes) return this.#originalBytes;

    if (this.#committeeColdCredentials.length === 0)
      throw new InvalidStateError('There must be at least one Committee member');

    // CDDL
    // committee = [{ committee_cold_credential => epoch }, unit_interval]
    writer.writeStartArray(COMMITTEE_ARRAY_SIZE);

    writer.writeStartMap(this.#committeeColdCredentials.length);
    for (const entry of this.#committeeColdCredentials) {
      writer.writeStartArray(CREDENTIAL_ARRAY_SIZE);
      writer.writeInt(entry[CREDENTIAL_INDEX].type);
      writer.writeByteString(hexToBytes(entry[CREDENTIAL_INDEX].hash as unknown as HexBlob));

      writer.writeInt(entry[EPOCH_INDEX]);
    }

    writer.writeEncodedValue(hexToBytes(this.#quorumThreshold.toCbor()));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Committee from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Committee object.
   * @returns The new Committee instance.
   */
  static fromCbor(cbor: HexBlob): Committee {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== COMMITTEE_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${COMMITTEE_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    reader.readStartMap();

    const members: [Cardano.Credential, number][] = [];
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

      members.push([{ hash, type }, epoch]);
    }

    reader.readEndMap();

    const quorumThreshold = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const committee = new Committee(quorumThreshold);

    for (const member of members) committee.addMember(member[CREDENTIAL_INDEX], member[EPOCH_INDEX]);

    committee.#originalBytes = cbor;

    return committee;
  }

  /**
   * Creates a Core Committee object from the current Committee object.
   *
   * @returns The Core Committee object.
   */
  toCore(): Cardano.Committee {
    if (this.#committeeColdCredentials.length === 0)
      throw new InvalidStateError('There must be at least one Committee member');

    const members = this.#committeeColdCredentials.map((entry) => ({
      coldCredential: entry[CREDENTIAL_INDEX],
      epoch: entry[EPOCH_INDEX]
    }));

    return {
      members: members as [Cardano.CommitteeMember],
      quorumThreshold: this.#quorumThreshold.toCore()
    };
  }

  /**
   * Creates a Committee object from the given Core Committee object.
   *
   * @param coreCommittee core Committee object.
   */
  static fromCore(coreCommittee: Cardano.Committee) {
    const committee = new Committee(UnitInterval.fromCore(coreCommittee.quorumThreshold));

    for (const member of coreCommittee.members) committee.addMember(member.coldCredential, member.epoch);

    return committee;
  }

  /**
   * Gets the credential of all the members of this committee.
   *
   * @returns The credentials.
   */
  membersKeys(): Cardano.Credential[] {
    return this.#committeeColdCredentials.map((entry) => entry[0]);
  }

  /**
   * Gets the minimum number (as percentage) of the Constitutional Committee members
   * that must participate in a vote for the outcome to be considered valid.
   *
   * @returns The minimum number or percentage of the Constitutional Committee members.
   */
  quorumThreshold(): UnitInterval {
    return this.#quorumThreshold;
  }

  /**
   * Adds a new member to the committe.
   *
   * @param committeeColdCredential The committee credential.
   * @param epoch The epoch at which this committee member term will end.
   */
  addMember(committeeColdCredential: Cardano.Credential, epoch: number) {
    const member = this.#committeeColdCredentials.find(
      (entry) =>
        entry[CREDENTIAL_INDEX].type === committeeColdCredential.type &&
        entry[CREDENTIAL_INDEX].hash === committeeColdCredential.hash
    );

    if (member) throw new InvalidArgumentError('committeeColdCredential', 'The given credential is already present');

    this.#committeeColdCredentials.push([committeeColdCredential, epoch]);
  }

  /**
   * Gets the epoch at which the given committee member term will end.
   *
   * @param committeeColdCredential The credential of the committee member we wish to get the term for.
   */
  getMemberEpoch(committeeColdCredential: Cardano.Credential): number | undefined {
    const member = this.#committeeColdCredentials.find(
      (entry) =>
        entry[CREDENTIAL_INDEX].type === committeeColdCredential.type &&
        entry[CREDENTIAL_INDEX].hash === committeeColdCredential.hash
    );

    if (member) return member[EPOCH_INDEX];

    return undefined;
  }
}
