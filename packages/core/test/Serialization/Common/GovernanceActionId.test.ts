/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano/index.js';
import { GovernanceActionId } from '../../../src/Serialization/index.js';
import { HexBlob } from '@cardano-sdk/util';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('825820000000000000000000000000000000000000000000000000000000000000000003');

const core = {
  actionIndex: 3,
  id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
};
describe('GovernanceActionId', () => {
  it('can decode GovernanceActionId from CBOR', () => {
    const actionId = GovernanceActionId.fromCbor(cbor);

    expect(actionId.index()).toEqual(3n);
    expect(actionId.transactionId()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
  });

  it('can decode GovernanceActionId from Core', () => {
    const actionId = GovernanceActionId.fromCore(core);

    expect(actionId.index()).toEqual(3n);
    expect(actionId.transactionId()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
  });

  it('can encode GovernanceActionId to CBOR', () => {
    const actionId = GovernanceActionId.fromCore(core);

    expect(actionId.toCbor()).toEqual(cbor);
  });

  it('can encode GovernanceActionId to Core', () => {
    const actionId = GovernanceActionId.fromCbor(cbor);

    expect(actionId.toCore()).toEqual(core);
  });
});
