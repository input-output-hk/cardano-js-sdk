import { UtxoProvider } from '@cardano-sdk/core';
import { utxo } from './mockWalletProvider';
import { utxo2 } from './mockWalletProvider2';
import delay from 'delay';

/**
 * Provider stub for testing
 *
 * returns UtxoProvider-compatible object
 */
export const mockUtxoProvider = (): UtxoProvider => ({
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  utxoByAddresses: jest.fn().mockResolvedValue(utxo)
});

export const mockUtxoProvider2 = (delayMs: number): UtxoProvider => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));
  return {
    healthCheck: delayedJestFn(true),
    utxoByAddresses: delayedJestFn(utxo2)
  };
};
export type UtxoProviderStub = ReturnType<typeof mockUtxoProvider>;
