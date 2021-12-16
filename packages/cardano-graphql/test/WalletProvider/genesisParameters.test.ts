import { Cardano, ProviderFailure } from '@cardano-sdk/core';
import { genesisParametersProvider } from '../../src/WalletProvider/genesisParameters';
import { getExactlyOneObject } from '../../src/util';

describe('CardanoGraphQLWalletProvider.genesisParameters', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let sdk: any;

  const networkConstants = {
    activeSlotsCoefficient: 0.05,
    maxKESEvolutions: 62,
    networkMagic: 764_824_073,
    securityParameter: 2160,
    slotsPerKESPeriod: 129_600,
    systemStart: '2017-09-23T21:44:51.000Z',
    updateQuorum: 5
  };
  const timeSettings = {
    epochLength: 100_000,
    slotLength: 1
  };
  const ada = {
    supply: { max: 100_000_000n }
  };

  beforeEach(() => {
    sdk = { GenesisParameters: jest.fn() };
  });

  it('makes a graphql query and coerces result to core types', async () => {
    sdk.GenesisParameters.mockResolvedValueOnce({
      queryAda: [ada],
      queryNetworkConstants: [networkConstants],
      queryTimeSettings: [timeSettings]
    });
    const getGenesisParameters = genesisParametersProvider({
      getExactlyOneObject,
      sdk
    });
    expect(await getGenesisParameters()).toEqual({
      activeSlotsCoefficient: networkConstants.activeSlotsCoefficient,
      epochLength: timeSettings.epochLength,
      maxKesEvolutions: networkConstants.maxKESEvolutions,
      maxLovelaceSupply: BigInt(ada.supply.max),
      networkMagic: networkConstants.networkMagic,
      securityParameter: networkConstants.securityParameter,
      slotLength: timeSettings.slotLength,
      slotsPerKesPeriod: networkConstants.slotsPerKESPeriod,
      systemStart: new Date(networkConstants.systemStart),
      updateQuorum: networkConstants.updateQuorum
    } as Cardano.CompactGenesis);
  });

  it('uses util.getExactlyOneObject to validate response', async () => {
    const getExactlyOneObjectMock = jest.fn().mockImplementation(getExactlyOneObject);
    sdk.GenesisParameters.mockResolvedValueOnce({});
    const getGenesisParameters = genesisParametersProvider({
      getExactlyOneObject: getExactlyOneObjectMock,
      sdk
    });
    await expect(getGenesisParameters()).rejects.toThrow(ProviderFailure.NotFound);
    expect(getExactlyOneObjectMock).toBeCalledTimes(1);
  });
});
