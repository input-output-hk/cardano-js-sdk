import { genesisParameters, ledgerTip, protocolParameters } from './mockData.js';
import { testnetEraSummaries } from '../eraSummaries.js';

export const networkInfo = {
  lovelaceSupply: {
    circulating: 42_064_399_450_423_723n,
    total: 40_267_211_394_073_980n
  },
  network: {
    eraSummaries: testnetEraSummaries,
    magic: 1_097_911_063
  },
  stake: {
    active: 1_060_378_314_781_343n,
    live: 15_001_884_895_856_815n
  }
};

/** Provider stub for testing */
export const mockNetworkInfoProvider = () => ({
  eraSummaries: jest.fn().mockResolvedValue(networkInfo.network.eraSummaries),
  genesisParameters: jest.fn().mockResolvedValue(genesisParameters),
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  ledgerTip: jest.fn().mockResolvedValue(ledgerTip),
  lovelaceSupply: jest.fn().mockResolvedValue(networkInfo.lovelaceSupply),
  protocolParameters: jest.fn().mockResolvedValue(protocolParameters),
  stake: jest.fn().mockResolvedValue(networkInfo.stake)
});

export type NetworkInfoProviderStub = ReturnType<typeof mockNetworkInfoProvider>;
