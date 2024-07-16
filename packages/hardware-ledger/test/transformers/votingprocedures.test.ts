import * as Crypto from '@cardano-sdk/crypto';
import {
  CONTEXT_WITH_KNOWN_ADDRESSES,
  ccHotKeyHashVoter,
  ccHotScriptHashVoter,
  constitutionalCommitteeVotingProcedure,
  dRepKeyHashVoter,
  dRepScriptHashVoter,
  stakePoolKeyHashVoter,
  votingProcedureVotes
} from '../testData';
import { Cardano } from '@cardano-sdk/core';
import { LedgerTxTransformerContext } from '../../src';
import { VoteOption, VoterType } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import {
  mapVotingProcedures,
  toVoteOption,
  toVoter,
  toVotes,
  toVotingProcedure
} from '../../src/transformers/votingProcedures';
import { util } from '@cardano-sdk/key-management';

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
    it('can map a ccHotKeyHashVoter correctly', () => {
      expect(toVoter(ccHotKeyHashVoter, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual({
        keyHashHex: '7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8',
        type: VoterType.COMMITTEE_KEY_HASH
      });
    });

    it('can map a ccHotScriptHashVoter correctly', () => {
      expect(toVoter(ccHotScriptHashVoter, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual({
        scriptHashHex: '7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8',
        type: VoterType.COMMITTEE_SCRIPT_HASH
      });
    });

    it('can map a dRepKeyHashVoter correctly', () => {
      expect(toVoter(dRepKeyHashVoter, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual({
        keyPath: util.accountKeyDerivationPathToBip32Path(
          CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex,
          util.DREP_KEY_DERIVATION_PATH
        ),
        type: VoterType.DREP_KEY_PATH
      });
    });

    it('can map a dRepScriptHashVoter correctly', () => {
      expect(toVoter(dRepScriptHashVoter, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual({
        scriptHashHex: '7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8',
        type: VoterType.DREP_SCRIPT_HASH
      });
    });

    it('can map a stakePoolKeyHashVoter correctly', () => {
      expect(toVoter(stakePoolKeyHashVoter, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual({
        keyHashHex: '7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8',
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
      expect(toVotingProcedure(constitutionalCommitteeVotingProcedure, CONTEXT_WITH_KNOWN_ADDRESSES)).toEqual({
        voter: {
          keyHashHex: '7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8',
          type: VoterType.COMMITTEE_KEY_HASH
        },
        votes: [expectedVotingProcedureVote]
      });
    });
  });

  describe('mapVotingProcedures', () => {
    it('return null if given an undefined object as votingProcedures', async () => {
      const votingProcedure: Cardano.VotingProcedures[0] | undefined = undefined;
      const votingProcedures = mapVotingProcedures(votingProcedure, {
        accountIndex: 0,
        dRepKeyHashHex: Crypto.Ed25519KeyHashHex('7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8')
      } as LedgerTxTransformerContext);
      expect(votingProcedures).toEqual(null);
    });

    it('can map voting procedures correctly', () => {
      const votingProcedures = mapVotingProcedures(
        [constitutionalCommitteeVotingProcedure, constitutionalCommitteeVotingProcedure],
        {
          accountIndex: 0,
          dRepKeyHashHex: Crypto.Ed25519KeyHashHex('7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8')
        } as LedgerTxTransformerContext
      );

      expect(votingProcedures!.length).toEqual(2);

      for (const votingProcedure of votingProcedures!) {
        expect(votingProcedure).toEqual({
          voter: {
            keyHashHex: '7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8',
            type: VoterType.COMMITTEE_KEY_HASH
          },
          votes: [expectedVotingProcedureVote]
        });
      }
    });
  });
});
