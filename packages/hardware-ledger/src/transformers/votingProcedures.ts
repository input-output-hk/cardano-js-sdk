import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { InvalidArgumentError, Transform } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '..';
import { util } from '@cardano-sdk/key-management';

/**
 * Maps a Voter to a Voter from the LedgerJS public types.
 *
 * @param {Cardano.Voter} voter - The voter object defined in Core types.
 * @returns {Ledger.Voter} Corresponding Voter object for use with LedgerJS.
 */

export const toVoter: Transform<Cardano.Voter, Ledger.Voter, LedgerTxTransformerContext> = (voter, context) => {
  if (!context) throw new InvalidArgumentError('LedgerTxTransformerContext', 'values was not provided');
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

    case 'dRepKeyHash': {
      if (!context.dRepKeyHashHex || context.dRepKeyHashHex !== Crypto.Ed25519KeyHashHex(voter.credential.hash)) {
        throw new Error('Foreign voter drepKeyHash');
      }
      return {
        keyPath: util.accountKeyDerivationPathToBip32Path(context.accountIndex, util.DREP_KEY_DERIVATION_PATH),
        type: Ledger.VoterType.DREP_KEY_PATH
      } as Ledger.DRepKeyPathVoter;
    }
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
export const toVotingProcedure: Transform<
  Cardano.VotingProcedures[0],
  Ledger.VoterVotes,
  LedgerTxTransformerContext
> = (votingProcedure, context) => ({
  voter: toVoter(votingProcedure.voter, context),
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
  votingProcedures: Cardano.VotingProcedures | undefined,
  context: LedgerTxTransformerContext
): Ledger.VoterVotes[] | null =>
  votingProcedures ? votingProcedures.map((votingProcedure) => toVotingProcedure(votingProcedure, context)) : null;
