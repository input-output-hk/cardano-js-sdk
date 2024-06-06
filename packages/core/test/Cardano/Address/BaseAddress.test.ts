import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors.js';
import { Cardano } from '../../../src/index.js';

describe('Cardano/Address/BaseAddress', () => {
  it('fromCredentials can build the correct BaseAddress instance when given a key hash', () => {
    const address = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      cip19TestVectors.KEY_PAYMENT_CREDENTIAL,
      cip19TestVectors.KEY_STAKE_CREDENTIAL
    );
    expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.basePaymentKeyStakeKey);
  });

  it('fromCredentials can build the correct BaseAddress instance when given a script hash', () => {
    const address = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      cip19TestVectors.SCRIPT_CREDENTIAL,
      cip19TestVectors.SCRIPT_CREDENTIAL
    );
    expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.basePaymentScriptStakeScript);
  });
});
