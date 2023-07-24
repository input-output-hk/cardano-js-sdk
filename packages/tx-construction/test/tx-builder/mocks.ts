import { Cardano } from '@cardano-sdk/core';
import { ChangeAddressResolver, Selection } from '@cardano-sdk/input-selection';

export class MockChangeAddressResolver implements ChangeAddressResolver {
  async resolve(selection: Selection) {
    return selection.change.map((txOut) => ({
      ...txOut,
      address:
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9' as Cardano.PaymentAddress
    }));
  }
}
