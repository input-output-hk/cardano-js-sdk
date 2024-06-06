/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { Committee } from '../../../../src/Serialization/index.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '82a48200581c00000000000000000000000000000000000000000000000000000000008200581c10000000000000000000000000000000000000000000000000000000018200581c20000000000000000000000000000000000000000000000000000000028200581c3000000000000000000000000000000000000000000000000000000003d81e820502'
);
const core = {
  members: [
    {
      coldCredential: {
        hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
        type: Cardano.CredentialType.KeyHash
      },
      epoch: 0
    },
    {
      coldCredential: {
        hash: Hash28ByteBase16('10000000000000000000000000000000000000000000000000000000'),
        type: Cardano.CredentialType.KeyHash
      },
      epoch: 1
    },
    {
      coldCredential: {
        hash: Hash28ByteBase16('20000000000000000000000000000000000000000000000000000000'),
        type: Cardano.CredentialType.KeyHash
      },
      epoch: 2
    },
    {
      coldCredential: {
        hash: Hash28ByteBase16('30000000000000000000000000000000000000000000000000000000'),
        type: Cardano.CredentialType.KeyHash
      },
      epoch: 3
    }
  ],
  quorumThreshold: { denominator: 2, numerator: 5 }
} as Cardano.Committee;

describe('Committee', () => {
  it('can encode Committee to CBOR', () => {
    const committee = Committee.fromCore(core);

    expect(committee.toCbor()).toEqual(cbor);
  });

  it('can encode Committee to Core', () => {
    const committee = Committee.fromCbor(cbor);

    expect(committee.toCore()).toEqual(core);
  });
});
