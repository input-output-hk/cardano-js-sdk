import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { GovernanceActionId } from '../../Common/GovernanceActionId.js';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { Voter } from './Voter.js';
import { VotingProcedure } from './VotingProcedure.js';
import { hexToBytes } from '../../../util/misc/index.js';
import type * as Cardano from '../../../Cardano/index.js';

/** A map of Voter + GovernanceActionId to VotingProcedure; */
export class VotingProcedures {
  #procedures: Array<{
    voter: Voter;
    votes: Array<{
      actionId: GovernanceActionId;
      votingProcedure: VotingProcedure;
    }>;
  }> = [];
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a VotingProcedures into CBOR format.
   *
   * @returns The VotingProcedures in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();

    // CDDL
    // voting_procedures = { + voter => { + gov_action_id => voting_procedure } }
    const voters = this.getVoters();

    if (voters.length === 0)
      throw new InvalidStateError('Empty VotingProcedures. There must be at least one VotingProcedure in the map');

    writer.writeStartMap(voters.length);

    for (const voter of voters) {
      const governanceActionIds = this.getGovernanceActionIdsByVoter(voter);

      if (governanceActionIds.length === 0)
        throw new InvalidStateError('Each voter must at least be associated to a GovernanceActionId');

      writer.writeEncodedValue(hexToBytes(voter.toCbor()));
      writer.writeStartMap(governanceActionIds.length);

      for (const actionIds of governanceActionIds) {
        writer.writeEncodedValue(hexToBytes(actionIds.toCbor()));
        const vote = this.get(voter, actionIds);

        if (!vote) throw new InvalidStateError('Each governanceActionIds must at least be associated to a vote');

        writer.writeEncodedValue(hexToBytes(vote.toCbor()));
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the VotingProcedures from a CBOR byte array.
   *
   * @param cbor The CBOR encoded VotingProcedures object.
   * @returns The new VotingProcedures instance.
   */
  static fromCbor(cbor: HexBlob): VotingProcedures {
    const reader = new CborReader(cbor);
    const votingProcedures = new VotingProcedures();

    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const voter = Voter.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

      reader.readStartMap();

      while (reader.peekState() !== CborReaderState.EndMap) {
        const actionId = GovernanceActionId.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
        const vote = VotingProcedure.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

        votingProcedures.insert(voter, actionId, vote);
      }

      reader.readEndMap();
    }

    reader.readEndMap();
    votingProcedures.#originalBytes = cbor;

    return votingProcedures;
  }

  /**
   * Creates a Core VotingProcedures object from the current VotingProcedures object.
   *
   * @returns The Core VotingProcedures object.
   */
  toCore(): Cardano.VotingProcedures {
    return this.#procedures.map((value) => {
      const voter = value.voter.toCore();
      const votes = value.votes.map((vote) => ({
        actionId: vote.actionId.toCore(),
        votingProcedure: vote.votingProcedure.toCore()
      }));

      return { voter, votes };
    });
  }

  /**
   * Creates a VotingProcedures object from the given Core VotingProcedures object.
   *
   * @param votingProcedures The core VotingProcedures object.
   */
  static fromCore(votingProcedures: Cardano.VotingProcedures): VotingProcedures {
    const procedures = new VotingProcedures();

    procedures.#procedures = votingProcedures.map((value) => {
      const voter = Voter.fromCore(value.voter);
      const votes = value.votes.map((vote) => ({
        actionId: GovernanceActionId.fromCore(vote.actionId),
        votingProcedure: VotingProcedure.fromCore(vote.votingProcedure)
      }));

      return { voter, votes };
    });

    return procedures;
  }

  /**
   * Inserts a new VotingProcedure into the map.
   *
   * @param voter The voter key.
   * @param actionId The governance action id key.
   * @param votingProcedure The voting procedure to be inserted.
   */
  insert(voter: Voter, actionId: GovernanceActionId, votingProcedure: VotingProcedure) {
    const foundVoter = this.#procedures.find((value) => value.voter.equals(voter));

    if (!foundVoter) {
      this.#procedures.push({
        voter,
        votes: [{ actionId, votingProcedure }]
      });

      return;
    }

    const foundVote = foundVoter.votes.find((vote) => vote.actionId.equals(actionId));

    if (foundVote)
      throw new InvalidArgumentError('actionId', 'Voter already has a voting procedure for the given actionId');

    foundVoter.votes.push({ actionId, votingProcedure });

    this.#originalBytes = undefined;
  }

  /**
   * Gets a voting procedure given its voter and governanceActionId.
   *
   * @param voter The voter key.
   * @param governanceActionId The governance action id key.
   * @returns The VotingProcedure or undefined of none found.
   */
  get(voter: Voter, governanceActionId: GovernanceActionId): VotingProcedure | undefined {
    const foundVoter = this.#procedures.find((value) => value.voter.equals(voter));

    if (!foundVoter) return undefined;

    const foundVote = foundVoter.votes.find((vote) => vote.actionId.equals(governanceActionId));

    if (!foundVote) return undefined;

    return foundVote.votingProcedure;
  }

  /**
   * Gets all the voters present in the voting procedures
   *
   * @returns An array with all the voters, if none found, this returns an empty array.
   */
  getVoters(): Array<Voter> {
    return this.#procedures.map((procedure) => procedure.voter);
  }

  /**
   * Gets all the GovernanceActionId present in the voting procedures given its voter.
   *
   * @returns An array with all the GovernanceActionId, if none found, this returns an empty array.
   */
  getGovernanceActionIdsByVoter(voter: Voter): Array<GovernanceActionId> {
    const foundVoter = this.#procedures.find((procedure) => procedure.voter.equals(voter));

    if (!foundVoter) return [];

    return foundVoter.votes.map((votes) => votes.actionId);
  }
}
