/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { TreasuryWithdrawalsAction } from '../../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('8202a1581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f01');

const core = {
  __typename: Cardano.GovernanceActionType.treasury_withdrawals_action,
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
