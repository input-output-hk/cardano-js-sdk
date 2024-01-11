import { Bip32Account, KeyRole } from '@cardano-sdk/key-management';
import { SingleAddressDiscovery } from '../../../src';
import { createAsyncKeyAgent } from '../../util';

describe('SingleAddressDiscovery', () => {
  it('return the first derived address', async () => {
    const bip32Account = await Bip32Account.fromAsyncKeyAgent(await createAsyncKeyAgent());
    const discovery = new SingleAddressDiscovery();

    const addresses = await discovery.discover(bip32Account);

    expect(addresses.length).toEqual(1);
    expect(addresses[0]).toEqual({
      accountIndex: 0,
      address: expect.stringContaining('addr'),
      index: 0,
      networkId: 0,
      rewardAccount: expect.stringContaining('stake'),
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: 0
    });
  });
});
