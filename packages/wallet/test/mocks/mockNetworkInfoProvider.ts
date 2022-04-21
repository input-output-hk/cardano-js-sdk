/* eslint-disable max-len */
import { testnetTimeSettings } from '@cardano-sdk/core';

export const networkInfo = {
  lovelaceSupply: {
    circulating: 42_064_399_450_423_723n,
    max: 45_000_000_000_000_000n,
    total: 40_267_211_394_073_980n
  },
  network: {
    magic: 123,
    timeSettings: testnetTimeSettings
  },
  stake: {
    active: 1_060_378_314_781_343n,
    live: 15_001_884_895_856_815n
  }
};

/**
 * Provider stub for testing
 *
 * returns WalletProvider-compatible object
 */
export const mockNetworkInfoProvider = () => ({
  networkInfo: jest.fn().mockResolvedValue(networkInfo)
});

export type WalletInfoProviderStub = ReturnType<typeof mockNetworkInfoProvider>;
