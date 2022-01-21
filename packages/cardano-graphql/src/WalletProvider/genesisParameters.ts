import { WalletProvider } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';

export const genesisParametersProvider =
  ({ getExactlyOneObject, sdk }: WalletProviderFnProps): WalletProvider['genesisParameters'] =>
  async () => {
    const { queryTimeSettings, queryAda, queryNetworkConstants } = await sdk.GenesisParameters();
    const timeSettings = getExactlyOneObject(queryTimeSettings, 'TimeSettings');
    const ada = getExactlyOneObject(queryAda, 'ada');
    const networkConstants = getExactlyOneObject(queryNetworkConstants, 'NetworkConstants');
    return {
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
    };
  };
