import * as cip19TestVectors from './Cip19TestVectors';
import { Cardano } from '../../../src';

describe('Cardano/Address/EnterpriseAddress', () => {
  describe('fromCredentials', () => {
    it('can build the correct EnterpriseAddress instance with key hash type', () => {
      const address = Cardano.EnterpriseAddress.fromCredentials(
        Cardano.NetworkId.Mainnet,
        cip19TestVectors.KEY_PAYMENT_CREDENTIAL
      );
      expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.enterpriseKey);
    });

    it('can build the correct EnterpriseAddress instance with script hash type', () => {
      const address = Cardano.EnterpriseAddress.fromCredentials(
        Cardano.NetworkId.Mainnet,
        cip19TestVectors.SCRIPT_CREDENTIAL
      );
      expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.enterpriseScript);
    });
  });
});
