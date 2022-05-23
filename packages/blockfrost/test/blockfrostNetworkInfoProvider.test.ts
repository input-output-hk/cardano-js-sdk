import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';
import { Cardano, NetworkInfo, testnetTimeSettings } from '@cardano-sdk/core';
import { blockfrostNetworkInfoProvider } from '../src';
jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostNetworkInfoProvider', () => {
  const apiKey = 'someapikey';

  test('networkInfo', async () => {
    const mockedNetworkResponse = {
      stake: {
        active: '1060378314781343',
        live: '15001884895856815'
      },
      supply: {
        circulating: '42064399450423723',
        locked: '6161981104458',
        max: '45000000000000000',
        total: '40267211394073980'
      }
    } as Responses['network'];

    BlockFrostAPI.prototype.network = jest.fn().mockResolvedValue(mockedNetworkResponse);
    BlockFrostAPI.prototype.apiUrl = 'http://testnet.endpoint';

    const blockfrost = new BlockFrostAPI({ isTestnet: true, projectId: apiKey });
    const client = blockfrostNetworkInfoProvider(blockfrost);
    const response = await client.networkInfo();

    expect(response).toMatchObject<NetworkInfo>({
      lovelaceSupply: {
        circulating: 42_064_399_450_423_723n,
        max: 45_000_000_000_000_000n,
        total: 40_267_211_394_073_980n
      },
      network: {
        id: Cardano.NetworkId.testnet,
        magic: 1_097_911_063,
        timeSettings: testnetTimeSettings
      },
      stake: {
        active: 1_060_378_314_781_343n,
        live: 15_001_884_895_856_815n
      }
    });
  });
});
