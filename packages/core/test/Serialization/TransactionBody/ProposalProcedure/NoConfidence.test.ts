/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { NoConfidence } from '../../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob('8203825820000000000000000000000000000000000000000000000000000000000000000003');
const core = {
  __typename: Cardano.GovernanceActionType.no_confidence,
  governanceActionId: { actionIndex: 3, id: '0000000000000000000000000000000000000000000000000000000000000000' }
} as Cardano.NoConfidence;

describe('NoConfidence', () => {
  it('can encode NoConfidence to CBOR', () => {
    const action = NoConfidence.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode NoConfidence to Core', () => {
    const action = NoConfidence.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });
});
