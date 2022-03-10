import { TxSubmitProvider } from '@cardano-sdk/core';

/**
 * Provider stub for testing
 *
 * returns TxSubmitProvider-compatible object
 */
export const mockTxSubmitProvider = (): TxSubmitProvider => ({
  submitTx: jest.fn().mockResolvedValue(void 0)
});

export type TxSubmitProviderStub = ReturnType<typeof mockTxSubmitProvider>;
