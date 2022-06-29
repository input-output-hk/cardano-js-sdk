/* eslint-disable max-len */
import { genesisParameters, ledgerTip, protocolParameters } from './mockData';
import { testnetTimeSettings } from '@cardano-sdk/core';

export const networkInfo = {
  lovelaceSupply: {
    circulating: 42_064_399_450_423_723n,
    total: 40_267_211_394_073_980n
  },
  network: {
    magic: 1_097_911_063,
    timeSettings: testnetTimeSettings
  },
  stake: {
    active: 1_060_378_314_781_343n,
    live: 15_001_884_895_856_815n
  }
};

/**
 * Provider stub for testing
 */
export const mockNetworkInfoProvider = () => ({
  currentWalletProtocolParameters: jest.fn().mockResolvedValue(protocolParameters),
  genesisParameters: jest.fn().mockResolvedValue(genesisParameters),
  ledgerTip: jest.fn().mockResolvedValue(ledgerTip),
  lovelaceSupply: jest.fn().mockResolvedValue(networkInfo.lovelaceSupply),
  networkInfo: jest.fn().mockResolvedValue(networkInfo),
  stake: jest.fn().mockResolvedValue(networkInfo.stake),
  timeSettings: jest.fn().mockResolvedValue(networkInfo.network.timeSettings)
});

export type NetworkInfoProviderStub = ReturnType<typeof mockNetworkInfoProvider>;
