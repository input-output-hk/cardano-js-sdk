/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { UpdateCommittee } from '../../../../src/Serialization';

const cbor = HexBlob(
  '8504825820000000000000000000000000000000000000000000000000000000000000000003828200581c000000000000000000000000000000000000000000000000000000008200581c20000000000000000000000000000000000000000000000000000000a28200581c30000000000000000000000000000000000000000000000000000000018200581c4000000000000000000000000000000000000000000000000000000002d81e820105'
);

const core = {
  __typename: Cardano.GovernanceActionType.update_committee,
  governanceActionId: { actionIndex: 3, id: '0000000000000000000000000000000000000000000000000000000000000000' },
  membersToBeAdded: new Set([
    {
      coldCredential: {
        hash: Hash28ByteBase16('30000000000000000000000000000000000000000000000000000000'),
        type: Cardano.CredentialType.KeyHash
      },
      epoch: Cardano.EpochNo(1)
    },
    {
      coldCredential: {
        hash: Hash28ByteBase16('40000000000000000000000000000000000000000000000000000000'),
        type: Cardano.CredentialType.KeyHash
      },
      epoch: Cardano.EpochNo(2)
    }
  ]),
  membersToBeRemoved: new Set([
    {
      hash: Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
      type: Cardano.CredentialType.KeyHash
    },
    {
      hash: Hash28ByteBase16('20000000000000000000000000000000000000000000000000000000'),
      type: Cardano.CredentialType.KeyHash
    }
  ]),
  newQuorumThreshold: { denominator: 5, numerator: 1 }
} as Cardano.UpdateCommittee;

describe('UpdateCommittee', () => {
  it('can encode UpdateCommittee to CBOR', () => {
    const action = UpdateCommittee.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode UpdateCommittee to Core', () => {
    const action = UpdateCommittee.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });
});
