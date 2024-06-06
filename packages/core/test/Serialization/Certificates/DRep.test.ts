/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import { DRep } from '../../../src/Serialization/index.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';

const testDRep = (DRepType: string, cbor: HexBlob, core: Cardano.DelegateRepresentative) => {
  describe(`DRep ${DRepType}`, () => {
    it('can encode DRep to CBOR', () => {
      const drep = DRep.fromCore(core);

      expect(drep.toCbor()).toEqual(cbor);
    });

    it('can encode DRep to Core', () => {
      const drep = DRep.fromCbor(cbor);

      expect(drep.toCore()).toEqual(core);
    });
  });
};

// Test data used in the following tests was generated with the cardano-serialization-lib
testDRep('Key Hash', HexBlob('8200581c00000000000000000000000000000000000000000000000000000000'), {
  hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
  type: Cardano.CredentialType.KeyHash
});

testDRep('Script Hash', HexBlob('8201581c00000000000000000000000000000000000000000000000000000000'), {
  hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
  type: Cardano.CredentialType.ScriptHash
});

testDRep('Always Abstain', HexBlob('8102'), {
  __typename: 'AlwaysAbstain'
});

testDRep('Always No Confidence', HexBlob('8103'), {
  __typename: 'AlwaysNoConfidence'
});
