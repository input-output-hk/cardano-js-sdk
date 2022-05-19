/* eslint-disable max-len */
import { genesisParameters, ledgerTip, protocolParameters } from './mockData';

/**
 * Provider stub for testing
 *
 * returns WalletProvider-compatible object
 */
export const mockWalletProvider = () => ({
  currentWalletProtocolParameters: jest.fn().mockResolvedValue(protocolParameters),
  genesisParameters: jest.fn().mockResolvedValue(genesisParameters),
  ledgerTip: jest.fn().mockResolvedValue(ledgerTip)
});

export type WalletProviderStub = ReturnType<typeof mockWalletProvider>;
