import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors.js';
import { Cardano } from '../../../src/index.js';

describe('Cardano/Address/PointerAddress', () => {
  it('fromCredentials can build the correct PointerAddress instance', () => {
    const address = Cardano.PointerAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      cip19TestVectors.KEY_PAYMENT_CREDENTIAL,
      cip19TestVectors.POINTER
    );
    expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.pointerKey);
  });
});
