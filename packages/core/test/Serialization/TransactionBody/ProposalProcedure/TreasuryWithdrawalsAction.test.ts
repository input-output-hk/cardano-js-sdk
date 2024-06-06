/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { TreasuryWithdrawalsAction } from '../../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '8302a1581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f01581c8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
);

const core = {
  __typename: Cardano.GovernanceActionType.treasury_withdrawals_action,
  policyHash: Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'),
  withdrawals: new Set([
    {
      coin: 1n,
      rewardAccount: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')
    }
  ])
} as Cardano.TreasuryWithdrawalsAction;

describe('TreasuryWithdrawalsAction', () => {
  it('can encode TreasuryWithdrawalsAction to CBOR', () => {
    const action = TreasuryWithdrawalsAction.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode TreasuryWithdrawalsAction to Core', () => {
    const action = TreasuryWithdrawalsAction.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });
});
