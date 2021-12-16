import { ProviderFailure } from '@cardano-sdk/core';
import { currentWalletProtocolParametersProvider } from '../../src/WalletProvider/currentWalletProtocolParameters';
import { getExactlyOneObject } from '../../src/util';

describe('CardanoGraphQLWalletProvider.currentWalletProtocolParameters', () => {
  let sdk: any;
  const protocolParameters = {
    __typename: 'ProtocolParametersAlonzo',
    coinsPerUtxoWord: 34_482,
    maxCollateralInputs: 3,
    maxTxSize: 16_384,
    maxValueSize: 5000,
    minFeeCoefficient: 44,
    minFeeConstant: 155_381,
    minPoolCost: 340_000_000,
    poolDeposit: 500_000_000,
    protocolVersion: {
      major: 4,
      minor: 0,
      patch: 1
    },
    stakeKeyDeposit: 2_000_000
  };

  beforeEach(() => {
    sdk = { CurrentProtocolParameters: jest.fn() };
  });

  it('makes a graphql query and coerces result to core types', async () => {
    sdk.CurrentProtocolParameters.mockResolvedValueOnce({
      queryProtocolVersion: [{ protocolParameters }]
    });
    const getCurrentWalletProtocolParameters = currentWalletProtocolParametersProvider({
      getExactlyOneObject,
      sdk
    });
    expect(await getCurrentWalletProtocolParameters()).toEqual({
      coinsPerUtxoWord: protocolParameters.coinsPerUtxoWord,
      maxCollateralInputs: protocolParameters.maxCollateralInputs,
      maxTxSize: protocolParameters.maxTxSize,
      maxValueSize: protocolParameters.maxValueSize,
      minFeeCoefficient: protocolParameters.minFeeCoefficient,
      minFeeConstant: protocolParameters.minFeeConstant,
      minPoolCost: protocolParameters.minPoolCost,
      poolDeposit: protocolParameters.poolDeposit,
      protocolVersion: protocolParameters.protocolVersion,
      stakeKeyDeposit: protocolParameters.stakeKeyDeposit
    });
  });

  it('uses util.getExactlyOneObject to validate response', async () => {
    sdk.CurrentProtocolParameters.mockResolvedValueOnce({});
    const getExactlyOneObjectMock = jest.fn().mockImplementation(getExactlyOneObject);
    const getCurrentWalletProtocolParameters = currentWalletProtocolParametersProvider({
      getExactlyOneObject: getExactlyOneObjectMock,
      sdk
    });
    await expect(getCurrentWalletProtocolParameters()).rejects.toThrow(ProviderFailure.NotFound);
    expect(getExactlyOneObjectMock).toBeCalledTimes(1);
  });

  it('throws if latest parameters are not Alonzo', async () => {
    sdk.CurrentProtocolParameters.mockResolvedValueOnce({
      queryProtocolVersion: [{ protocolParameters: { ...protocolParameters, __typename: 'ProtocolParametersShelley' } }]
    });
    const getCurrentWalletProtocolParameters = currentWalletProtocolParametersProvider({
      getExactlyOneObject,
      sdk
    });
    await expect(getCurrentWalletProtocolParameters()).rejects.toThrow(ProviderFailure.NotFound);
  });
});
