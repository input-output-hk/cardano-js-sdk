/* eslint-disable sonarjs/no-duplicate-string */
import { CredentialType, VoterType } from '../../../../src/Cardano/index.js';
import { GovernanceActionId, Voter, VotingProcedure, VotingProcedures } from '../../../../src/Serialization/index.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import type * as Cardano from '../../../../src/Cardano/index.js';

const cbor = HexBlob(
  'a28202581c10000000000000000000000000000000000000000000000000000000a38258201000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258202000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258203000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008203581c20000000000000000000000000000000000000000000000000000000a28258201000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258203000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
);

const core = [
  {
    voter: {
      __typename: 'dRepKeyHash',
      credential: {
        hash: '10000000000000000000000000000000000000000000000000000000',
        type: 0
      }
    },
    votes: [
      {
        actionId: {
          actionIndex: 3,
          id: '1000000000000000000000000000000000000000000000000000000000000000'
        },
        votingProcedure: {
          anchor: {
            dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
            url: 'https://www.someurl.io'
          },
          vote: 0
        }
      },
      {
        actionId: {
          actionIndex: 3,
          id: '2000000000000000000000000000000000000000000000000000000000000000'
        },
        votingProcedure: {
          anchor: {
            dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
            url: 'https://www.someurl.io'
          },
          vote: 0
        }
      },
      {
        actionId: {
          actionIndex: 3,
          id: '3000000000000000000000000000000000000000000000000000000000000000'
        },
        votingProcedure: {
          anchor: {
            dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
            url: 'https://www.someurl.io'
          },
          vote: 0
        }
      }
    ]
  },
  {
    voter: {
      __typename: 'dRepScriptHash',
      credential: {
        hash: '20000000000000000000000000000000000000000000000000000000',
        type: 1
      }
    },
    votes: [
      {
        actionId: {
          actionIndex: 3,
          id: '1000000000000000000000000000000000000000000000000000000000000000'
        },
        votingProcedure: {
          anchor: {
            dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
            url: 'https://www.someurl.io'
          },
          vote: 0
        }
      },
      {
        actionId: {
          actionIndex: 3,
          id: '3000000000000000000000000000000000000000000000000000000000000000'
        },
        votingProcedure: {
          anchor: {
            dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
            url: 'https://www.someurl.io'
          },
          vote: 0
        }
      }
    ]
  }
] as Cardano.VotingProcedures;

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('VotingProcedures', () => {
  it('can encode VotingProcedures to CBOR', () => {
    const procedures = VotingProcedures.fromCore(core);

    expect(procedures.toCbor()).toEqual(cbor);
  });

  it('can encode VotingProcedures to Core', () => {
    const procedures = VotingProcedures.fromCbor(cbor);

    expect(procedures.toCore()).toEqual(core);
  });

  it('can get all voters', () => {
    const procedures = VotingProcedures.fromCbor(cbor);
    const voters = procedures.getVoters();
    expect(voters.map((voter) => voter.toCore())).toEqual([
      {
        __typename: VoterType.dRepKeyHash,
        credential: {
          hash: '10000000000000000000000000000000000000000000000000000000',
          type: CredentialType.KeyHash
        }
      },
      {
        __typename: VoterType.dRepScriptHash,
        credential: {
          hash: '20000000000000000000000000000000000000000000000000000000',
          type: CredentialType.ScriptHash
        }
      }
    ]);
  });

  it('can get all actionIds for a given voter', () => {
    const procedures = VotingProcedures.fromCbor(cbor);
    const actionIds = procedures.getGovernanceActionIdsByVoter(
      Voter.fromCore({
        __typename: VoterType.dRepKeyHash,
        credential: {
          hash: Hash28ByteBase16('10000000000000000000000000000000000000000000000000000000'),
          type: CredentialType.KeyHash
        }
      })
    );
    expect(actionIds.map((id) => id.toCore())).toEqual([
      {
        actionIndex: 3,
        id: '1000000000000000000000000000000000000000000000000000000000000000'
      },
      {
        actionIndex: 3,
        id: '2000000000000000000000000000000000000000000000000000000000000000'
      },
      {
        actionIndex: 3,
        id: '3000000000000000000000000000000000000000000000000000000000000000'
      }
    ]);
  });

  it('can get a voting procedure given a voter and a governance action id', () => {
    const procedures = VotingProcedures.fromCbor(cbor);
    const procedure = procedures.get(
      Voter.fromCbor(HexBlob('8202581c10000000000000000000000000000000000000000000000000000000')),
      GovernanceActionId.fromCbor(HexBlob('825820300000000000000000000000000000000000000000000000000000000000000003'))
    );

    expect(procedure?.toCore()).toEqual({
      anchor: {
        dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
        url: 'https://www.someurl.io'
      },
      vote: 0
    });
  });

  it('can insert a new voting procedure', () => {
    const procedures = VotingProcedures.fromCbor(cbor);

    procedures.insert(
      Voter.fromCbor(HexBlob('8202581cffffffffffffffffffffffffffffffffffffffffffffffffffffffff')),
      GovernanceActionId.fromCbor(HexBlob('825820321000000000000000000000000000000000000000000000000000000000000003')),
      VotingProcedure.fromCbor(
        HexBlob(
          '8202827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
        )
      )
    );

    expect(procedures.toCbor()).toEqual(
      'a28202581c10000000000000000000000000000000000000000000000000000000a38258201000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258202000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258203000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008203581c20000000000000000000000000000000000000000000000000000000a28258201000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f582000000000000000000000000000000000000000000000000000000000000000008258203000000000000000000000000000000000000000000000000000000000000000038200827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
    );
  });
});
