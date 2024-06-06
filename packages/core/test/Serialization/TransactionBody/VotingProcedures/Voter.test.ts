/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { Voter } from '../../../../src/Serialization/index.js';

const testVoter = (voterType: string, cbor: HexBlob, core: Cardano.Voter) => {
  describe(`Voter ${voterType}`, () => {
    it('can encode Voter to CBOR', () => {
      const voter = Voter.fromCore(core);

      expect(voter.toCbor()).toEqual(cbor);
    });

    it('can encode Voter to Core', () => {
      const voter = Voter.fromCbor(cbor);

      expect(voter.toCore()).toEqual(core);
    });
  });
};

// Test data used in the following tests was generated with the cardano-serialization-lib
testVoter(Cardano.VoterType.ccHotKeyHash, HexBlob('8200581c00000000000000000000000000000000000000000000000000000000'), {
  __typename: Cardano.VoterType.ccHotKeyHash,
  credential: {
    hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  }
});

testVoter(
  Cardano.VoterType.ccHotScriptHash,
  HexBlob('8201581c00000000000000000000000000000000000000000000000000000000'),
  {
    __typename: Cardano.VoterType.ccHotScriptHash,
    credential: {
      hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
      type: Cardano.CredentialType.ScriptHash
    }
  }
);

testVoter(Cardano.VoterType.dRepKeyHash, HexBlob('8202581c00000000000000000000000000000000000000000000000000000000'), {
  __typename: Cardano.VoterType.dRepKeyHash,
  credential: {
    hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
    type: Cardano.CredentialType.KeyHash
  }
});

testVoter(
  Cardano.VoterType.dRepScriptHash,
  HexBlob('8203581c00000000000000000000000000000000000000000000000000000000'),
  {
    __typename: Cardano.VoterType.dRepScriptHash,
    credential: {
      hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
      type: Cardano.CredentialType.ScriptHash
    }
  }
);

testVoter(
  Cardano.VoterType.stakePoolKeyHash,
  HexBlob('8204581c00000000000000000000000000000000000000000000000000000000'),
  {
    __typename: Cardano.VoterType.stakePoolKeyHash,
    credential: {
      hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
      type: Cardano.CredentialType.KeyHash
    }
  }
);
