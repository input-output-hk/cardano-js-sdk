import { AsyncKeyAgent, KeyRole } from '@cardano-sdk/key-management';
import { SingleAddressDiscovery } from '../../../src';
import { prepareMockKeyAgentWithData } from './mockData';

describe('SingleAddressDiscovery', () => {
  let mockKeyAgent: AsyncKeyAgent;

  beforeEach(() => {
    mockKeyAgent = prepareMockKeyAgentWithData();
  });

  it('return the first derived address', async () => {
    const discovery = new SingleAddressDiscovery();

    const addresses = await discovery.discover(mockKeyAgent);

    expect(addresses.length).toEqual(1);
    expect(addresses[0]).toEqual({
      accountIndex: 0,
      address: 'testAddress_0_0',
      index: 0,
      networkId: 0,
      rewardAccount: 'testStakeAddress_0',
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: 0
    });
  });
});
