/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { VotingProcedure } from '../../../../src/Serialization';

const testVotingProcedure = (procedureType: string, cbor: HexBlob, core: Cardano.VotingProcedure) => {
  describe(`VotingProcedure ${procedureType}`, () => {
    it('can encode VotingProcedure to CBOR', () => {
      const procedure = VotingProcedure.fromCore(core);

      expect(procedure.toCbor()).toEqual(cbor);
    });

    it('can encode VotingProcedure to Core', () => {
      const procedure = VotingProcedure.fromCbor(cbor);

      expect(procedure.toCore()).toEqual(core);
    });
  });
};

// Test data used in the following tests was generated with the cardano-serialization-lib
testVotingProcedure('vote no with null anchor', HexBlob('8200f6'), { anchor: null, vote: Cardano.Vote.no });
testVotingProcedure('vote yes with null anchor', HexBlob('8201f6'), { anchor: null, vote: Cardano.Vote.yes });
testVotingProcedure('vote abstain with null anchor', HexBlob('8202f6'), {
  anchor: null,
  vote: Cardano.Vote.abstain
});
testVotingProcedure(
  'vote no with anchor',
  HexBlob(
    '8200827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
  ),
  {
    anchor: {
      dataHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000'),
      url: 'https://www.someurl.io'
    },
    vote: Cardano.Vote.no
  }
);
testVotingProcedure(
  'vote yes with anchor',
  HexBlob(
    '8201827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
  ),
  {
    anchor: {
      dataHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000'),
      url: 'https://www.someurl.io'
    },
    vote: Cardano.Vote.yes
  }
);
testVotingProcedure(
  'vote abstain with anchor',
  HexBlob(
    '8202827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
  ),
  {
    anchor: {
      dataHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000'),
      url: 'https://www.someurl.io'
    },
    vote: Cardano.Vote.abstain
  }
);
