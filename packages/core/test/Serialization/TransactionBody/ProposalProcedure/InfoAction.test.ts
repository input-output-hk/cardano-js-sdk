/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { InfoAction } from '../../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('8106');
const core = {
  __typename: Cardano.GovernanceActionType.info_action
} as Cardano.InfoAction;

describe('InfoAction', () => {
  it('can encode InfoAction to CBOR', () => {
    const action = InfoAction.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode InfoAction to Core', () => {
    const action = InfoAction.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });
});
