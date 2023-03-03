import * as cip19TestVectors from './Cip19TestVectors';
import { Cardano } from '../../../src';

describe('Cardano/Address/EnterpriseAddress', () => {
  it('fromCredentials can build the correct EnterpriseAddress instance', () => {
    const address = Cardano.EnterpriseAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      cip19TestVectors.KEY_PAYMENT_CREDENTIAL
    );
    expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.enterpriseKey);
  });
});
