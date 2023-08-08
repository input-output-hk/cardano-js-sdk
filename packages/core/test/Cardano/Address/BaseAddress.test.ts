import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors';
import { Cardano } from '../../../src';

describe('Cardano/Address/BaseAddress', () => {
  it('fromCredentials can build the correct BaseAddress instance', () => {
    const address = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      cip19TestVectors.KEY_PAYMENT_CREDENTIAL,
      cip19TestVectors.KEY_STAKE_CREDENTIAL
    );
    expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.basePaymentKeyStakeKey);
  });
});
