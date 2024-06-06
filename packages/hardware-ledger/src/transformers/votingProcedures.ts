import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import type { Cardano } from '@cardano-sdk/core';
import type { Transform } from '@cardano-sdk/util';

/**
 * Maps a Voter to a Voter from the LedgerJS public types.
 *
 * @param {Cardano.Voter} voter - The voter object defined in Core types.
 * @returns {Ledger.Voter} Corresponding Voter object for use with LedgerJS.
 */

export const toVoter: Transform<Cardano.Voter, Ledger.Voter> = (voter) => {
  switch (voter.__typename) {
    case 'ccHotKeyHash':
      return {
        keyHashHex: voter.credential.hash,
        type: Ledger.VoterType.COMMITTEE_KEY_HASH
      } as Ledger.CommitteeKeyHashVoter;

    case 'ccHotScriptHash':
      return {
        scriptHashHex: voter.credential.hash,
        type: Ledger.VoterType.COMMITTEE_SCRIPT_HASH
      } as Ledger.CommitteeScriptHashVoter;

    case 'dRepKeyHash':
      return {
        keyHashHex: voter.credential.hash,
        type: Ledger.VoterType.DREP_KEY_HASH
      } as Ledger.DRepKeyHashVoter;

    case 'dRepScriptHash':
      return {
        scriptHashHex: voter.credential.hash,
        type: Ledger.VoterType.DREP_SCRIPT_HASH
      } as Ledger.DRepScriptHashVoter;

    case 'stakePoolKeyHash':
      return {
        keyHashHex: voter.credential.hash,
        type: Ledger.VoterType.STAKE_POOL_KEY_HASH
      } as Ledger.StakePoolKeyHashVoter;

    default:
      throw new Error('Unsupported voter type');
  }
};

/**
 * Maps Vote to a LedgerJS VoteOption.
 *
 * @param {Cardano.Vote} vote - The vote integer representing a voting decision.
 * @returns {Ledger.VoteOption} The corresponding LedgerJS VoteOption.
 */

export const toVoteOption: Transform<Cardano.Vote, Ledger.VoteOption> = (vote) => {
  // Implement this based on how the raw data translates to VoteOption
  switch (vote) {
    case 0:
      return Ledger.VoteOption.NO;
    case 1:
      return Ledger.VoteOption.YES;
    case 2:
      return Ledger.VoteOption.ABSTAIN;
    default:
      throw new Error('Unsupported vote type');
  }
};

/**
 * Maps voting procedure votes to a LedgerJS voting procedure votes.
 *
 * @param {Cardano.VotingProcedureVote[]} voting procedure votes from Core
 * @returns {Ledger.Vote[]} The corresponding LedgerJS voting procedure votes.
 */

export const toVotes: Transform<Cardano.VotingProcedureVote[], Ledger.Vote[]> = (votes) =>
  votes.map((vote) => ({
    govActionId: {
      govActionIndex: vote.actionId.actionIndex,
      txHashHex: vote.actionId.id
    },
    votingProcedure: {
      ...(vote.votingProcedure.anchor && {
        anchor: {
          hashHex: vote.votingProcedure.anchor.dataHash,
          url: vote.votingProcedure.anchor.url
        }
      }),
      vote: toVoteOption(vote.votingProcedure.vote)
    }
  }));

/**
 * Maps voting procedure from Core to LedgerJS.
 *
 * @param votingProcedure A single voting procedure obj from Core.
 * @returns {Ledger.VoterVotes} LedgerJS-compatible voting records
 */
export const toVotingProcedure: Transform<Cardano.VotingProcedures[0], Ledger.VoterVotes> = (votingProcedure) => ({
  voter: toVoter(votingProcedure.voter),
  votes: toVotes(votingProcedure.votes)
});

/**
 * Maps voting procedures from Core to LedgerJS.
 *
 * Converts a list of Core voting procedures into a format compatible with LedgerJS. This includes converting voters,
 * votes, and anchoring data.
 *
 * @param {Cardano.VotingProcedures | undefined} votingProcedures - Array of voting procedures from Core.
 * @returns {Ledger.VoterVotes[] | null} Array of LedgerJS-compatible voting records or null if input is undefined.
 */

export const mapVotingProcedures = (
  votingProcedures: Cardano.VotingProcedures | undefined
): Ledger.VoterVotes[] | null =>
  votingProcedures ? votingProcedures.map((votingProcedure) => toVotingProcedure(votingProcedure)) : null;
