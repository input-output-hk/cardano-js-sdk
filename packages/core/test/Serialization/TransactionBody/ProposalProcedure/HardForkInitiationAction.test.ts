/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { HardForkInitiationAction } from '../../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('8301825820000000000000000000000000000000000000000000000000000000000000000003820103');
const core = {
  __typename: Cardano.GovernanceActionType.hard_fork_initiation_action,
  governanceActionId: { actionIndex: 3, id: '0000000000000000000000000000000000000000000000000000000000000000' },
  protocolVersion: { major: 1, minor: 3 }
} as Cardano.HardForkInitiationAction;

describe('HardForkInitiationAction', () => {
  it('can encode HardForkInitiationAction to CBOR', () => {
    const action = HardForkInitiationAction.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode HardForkInitiationAction to Core', () => {
    const action = HardForkInitiationAction.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });
});
