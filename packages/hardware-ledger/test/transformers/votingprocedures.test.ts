import { Cardano } from '@cardano-sdk/core';
import { VoteOption, VoterType } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  constitutionalCommitteeKeyHashVoter,
  constitutionalCommitteeScriptHashVoter,
  constitutionalCommitteeVotingProcedure,
  drepKeyHashVoter,
  drepScriptHashVoter,
  stakePoolKeyHashVoter,
  votingProcedureVotes
} from '../testData';
import {
  mapVotingProcedures,
  toVoteOption,
  toVoter,
  toVotes,
  toVotingProcedure
} from '../../src/transformers/votingProcedures';

describe('votingProcedures', () => {
  const expectedVotingProcedureVote = {
    govActionId: {
      govActionIndex: 1,
      txHashHex: 'someActionId'
    },
    votingProcedure: {
      anchor: {
        hashHex: 'datahash',
        url: 'http://example.com'
      },
      vote: VoteOption.YES
    }
  };

  describe('toVoter', () => {
    it('can map a ConstitutionalCommitteeKeyHashVoter correctly', () => {
      expect(toVoter(constitutionalCommitteeKeyHashVoter)).toEqual({
        keyHashHex: 'somehash',
        type: VoterType.COMMITTEE_KEY_HASH
      });
    });

    it('can map a ConstitutionalCommitteeScriptHashVoter correctly', () => {
      expect(toVoter(constitutionalCommitteeScriptHashVoter)).toEqual({
        scriptHashHex: 'somehash',
        type: VoterType.COMMITTEE_SCRIPT_HASH
      });
    });

    it('can map a DrepKeyHashVoter correctly', () => {
      expect(toVoter(drepKeyHashVoter)).toEqual({
        keyHashHex: 'somehash',
        type: VoterType.DREP_KEY_HASH
      });
    });

    it('can map a DrepScriptHashVoter correctly', () => {
      expect(toVoter(drepScriptHashVoter)).toEqual({
        scriptHashHex: 'somehash',
        type: VoterType.DREP_SCRIPT_HASH
      });
    });

    it('can map a StakePoolKeyHashVoter correctly', () => {
      expect(toVoter(stakePoolKeyHashVoter)).toEqual({
        keyHashHex: 'somehash',
        type: VoterType.STAKE_POOL_KEY_HASH
      });
    });
  });

  describe('toVotes', () => {
    it('can map votes correctly', () => {
      expect(toVotes(votingProcedureVotes)).toEqual([expectedVotingProcedureVote]);
    });
  });

  describe('toVoteOption', () => {
    it('maps the vote option NO correctly', () => {
      expect(toVoteOption(Cardano.Vote.no)).toEqual(VoteOption.NO);
    });

    it('maps the vote option YES correctly', () => {
      expect(toVoteOption(Cardano.Vote.yes)).toEqual(VoteOption.YES);
    });

    it('maps the vote option ABSTAIN correctly', () => {
      expect(toVoteOption(Cardano.Vote.abstain)).toEqual(VoteOption.ABSTAIN);
    });

    it('throws on invalid vote options', () => {
      expect(() => toVoteOption(3)).toThrow('Unsupported vote type');
    });
  });

  describe('toVotingProcedure', () => {
    it('can map voting procedure correctly', () => {
      expect(toVotingProcedure(constitutionalCommitteeVotingProcedure)).toEqual({
        voter: {
          keyHashHex: 'somehash',
          type: VoterType.COMMITTEE_KEY_HASH
        },
        votes: [expectedVotingProcedureVote]
      });
    });
  });

  describe('mapVotingProcedures', () => {
    it('return null if given an undefined object as votingProcedures', async () => {
      const votingProcedure: Cardano.VotingProcedures[0] | undefined = undefined;
      const votingProcedures = mapVotingProcedures(votingProcedure);
      expect(votingProcedures).toEqual(null);
    });

    it('can map voting procedures correctly', () => {
      const votingProcedures = mapVotingProcedures([
        constitutionalCommitteeVotingProcedure,
        constitutionalCommitteeVotingProcedure
      ]);

      expect(votingProcedures!.length).toEqual(2);

      for (const votingProcedure of votingProcedures!) {
        expect(votingProcedure).toEqual({
          voter: {
            keyHashHex: 'somehash',
            type: VoterType.COMMITTEE_KEY_HASH
          },
          votes: [expectedVotingProcedureVote]
        });
      }
    });
  });
});
