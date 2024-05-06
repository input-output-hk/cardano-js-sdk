import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { VoteOption, VoterType, VoterVotes } from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { mapVoteOption, mapVoterToLedgerVoter, mapVotingProcedures } from '../../src/transformers/votingProcedures';

describe('mapVoterToLedgerVoter', () => {
  it('maps a ConstitutionalCommitteeKeyHashVoter correctly', () => {
    const coreVoter = {
      __typename: 'ccHotKeyHash',
      credential: {
        hash: 'somehash',
        type: Cardano.CredentialType.KeyHash
      }
    };
    const expected = {
      keyHashHex: 'somehash',
      type: VoterType.COMMITTEE_KEY_HASH
    };
    expect(mapVoterToLedgerVoter(coreVoter as Cardano.Voter)).toEqual(expected);
  });
});

describe('mapVoteOption', () => {
  it('maps the vote option NO correctly', () => {
    expect(mapVoteOption(0)).toEqual(VoteOption.NO);
  });

  it('maps the vote option YES correctly', () => {
    expect(mapVoteOption(1)).toEqual(VoteOption.YES);
  });

  it('maps the vote option ABSTAIN correctly', () => {
    expect(mapVoteOption(2)).toEqual(VoteOption.ABSTAIN);
  });

  it('throws on invalid vote options', () => {
    expect(() => mapVoteOption(3)).toThrow('Unsupported vote type');
  });
});

const toHash32ByteBase16 = (hash: string): Crypto.Hash32ByteBase16 => hash as unknown as Crypto.Hash32ByteBase16;
const toHash28ByteBase16 = (hash: string): Crypto.Hash28ByteBase16 => hash as unknown as Crypto.Hash28ByteBase16;
const toTransactionId = (id: string): Cardano.TransactionId => id as unknown as Cardano.TransactionId;

describe('mapVotingProcedures', () => {
  it('maps voting procedures correctly', () => {
    const votingProcedures: Cardano.VotingProcedures = [
      {
        voter: {
          __typename: Cardano.VoterType.ccHotKeyHash,
          credential: {
            hash: toHash28ByteBase16('keyhash'),
            type: Cardano.CredentialType.KeyHash
          }
        },
        votes: [
          {
            actionId: {
              actionIndex: 1,
              id: toTransactionId('actionId')
            },
            votingProcedure: {
              anchor: {
                dataHash: toHash32ByteBase16('datahash'),
                url: 'http://example.com'
              },
              vote: 1
            }
          }
        ]
      }
    ];

    const voterVotes: VoterVotes[] = [
      {
        voter: {
          keyHashHex: 'keyhash',
          type: VoterType.COMMITTEE_KEY_HASH
        },
        votes: [
          {
            govActionId: {
              govActionIndex: 1,
              txHashHex: 'actionId'
            },
            votingProcedure: {
              anchor: {
                hashHex: 'datahash',
                url: 'http://example.com'
              },
              vote: VoteOption.YES
            }
          }
        ]
      }
    ];
    expect(mapVotingProcedures(votingProcedures)).toEqual(voterVotes);
  });
});
