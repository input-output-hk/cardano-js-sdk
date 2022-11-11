import { ObservableProvider } from '@cardano-sdk/util-rxjs';
import { TxSubmitProvider } from '@cardano-sdk/core';
import { of } from 'rxjs';

/**
 * Provider stub for testing
 *
 * returns TxSubmitProvider-compatible object
 */
export const mockTxSubmitProvider = (): jest.Mocked<ObservableProvider<TxSubmitProvider>> => ({
  healthCheck: jest.fn().mockReturnValue(of(true)),
  submitTx: jest.fn().mockReturnValue(of())
});

export type TxSubmitProviderStub = ReturnType<typeof mockTxSubmitProvider>;
