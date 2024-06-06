/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { NewConstitution } from '../../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '830582582000000000000000000000000000000000000000000000000000000000000000000382827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000f6'
);
const core = {
  __typename: Cardano.GovernanceActionType.new_constitution,
  constitution: {
    anchor: {
      dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
      url: 'https://www.someurl.io'
    },
    scriptHash: null
  },
  governanceActionId: { actionIndex: 3, id: '0000000000000000000000000000000000000000000000000000000000000000' }
} as Cardano.NewConstitution;

describe('NewConstitution', () => {
  it('can encode NewConstitution to CBOR', () => {
    const action = NewConstitution.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode NewConstitution to Core', () => {
    const action = NewConstitution.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });
});
