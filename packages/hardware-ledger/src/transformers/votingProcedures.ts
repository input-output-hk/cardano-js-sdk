import { Cardano } from '@cardano-sdk/core';
import {
  CommitteeKeyHashVoter,
  CommitteeScriptHashVoter,
  DRepKeyHashVoter,
  DRepScriptHashVoter,
  StakePoolKeyHashVoter,
  Vote,
  VoteOption,
  Voter,
  VoterType,
  VoterVotes
} from '@cardano-foundation/ledgerjs-hw-app-cardano';

/**
 * Maps a Voter to a Voter from the LedgerJS public types.
 *
 * @param {Cardano.Voter} voter - The voter object defined in Core types.
 * @returns {Voter} Corresponding Voter object for use with LedgerJS.
 */
export const mapVoterToLedgerVoter = (voter: Cardano.Voter): Voter => {
  switch (voter.__typename) {
    case 'ccHotKeyHash':
      return {
        keyHashHex: voter.credential.hash,
        type: VoterType.COMMITTEE_KEY_HASH
      } as CommitteeKeyHashVoter;

    case 'ccHotScriptHash':
      return {
        scriptHashHex: voter.credential.hash,
        type: VoterType.COMMITTEE_SCRIPT_HASH
      } as CommitteeScriptHashVoter;

    case 'dRepKeyHash':
      return {
        keyHashHex: voter.credential.hash,
        type: VoterType.DREP_KEY_HASH
      } as DRepKeyHashVoter;

    case 'dRepScriptHash':
      return {
        scriptHashHex: voter.credential.hash,
        type: VoterType.DREP_SCRIPT_HASH
      } as DRepScriptHashVoter;

    case 'stakePoolKeyHash':
      return {
        keyHashHex: voter.credential.hash,
        type: VoterType.STAKE_POOL_KEY_HASH
      } as StakePoolKeyHashVoter;

    default:
      throw new Error('Unsupported voter type');
  }
};

/**
 * Maps Vote to a LedgerJS VoteOption.
 *
 * @param {Cardano.Vote} vote - The vote integer representing a voting decision.
 * @returns {VoteOption} The corresponding LedgerJS VoteOption.
 */
export const mapVoteOption = (vote: Cardano.Vote): VoteOption => {
  // Implement this based on how the raw data translates to VoteOption
  switch (vote) {
    case 0:
      return VoteOption.NO;
    case 1:
      return VoteOption.YES;
    case 2:
      return VoteOption.ABSTAIN;
    default:
      throw new Error('Unsupported vote type');
  }
};

/**
 * Maps voting procedures from Core to LedgerJS.
 *
 * Converts a list of Core voting procedures into a format compatible with LedgerJS. This includes converting voters,
 * votes, and anchoring data.
 *
 * @param {VotingProcedures | undefined} votingProcedures - Array of voting procedures from Core.
 * @returns {VoterVotes[] | null} Array of LedgerJS-compatible voting records or null if input is undefined.
 */
export const mapVotingProcedures = (votingProcedures: Cardano.VotingProcedures | undefined): VoterVotes[] | null => {
  if (!votingProcedures) {
    return null;
  }

  return votingProcedures.map(
    (procedure): VoterVotes => ({
      voter: mapVoterToLedgerVoter(procedure.voter),
      votes: procedure.votes.map(
        (vote): Vote => ({
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
            vote: mapVoteOption(vote.votingProcedure.vote)
          }
        })
      )
    })
  );
};
