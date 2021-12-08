/* eslint-disable max-len */
import { ProviderFailure, WalletProvider } from '@cardano-sdk/core';
import { Sdk } from '../../src/sdk';
import { createGraphQLWalletProviderFromSdk } from '../../src/WalletProvider/CardanoGraphQLWalletProvider';

describe('CardanoGraphQLWalletProvider', () => {
  let provider: WalletProvider;
  const sdk = {
    Tip: jest.fn()
  };

  beforeEach(() => {
    provider = createGraphQLWalletProviderFromSdk(sdk as unknown as Sdk);
  });

  afterEach(() => {
    sdk.Tip.mockReset();
  });

  describe('ledgerTip', () => {
    const tip = {
      blockNo: 1,
      hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
      slot: { number: 2 }
    };

    it('makes a graphql query and coerces result to core types', async () => {
      sdk.Tip.mockResolvedValueOnce({
        queryBlock: [tip]
      });
      expect(await provider.ledgerTip()).toEqual({
        blockNo: 1,
        hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
        slot: 2
      });
    });

    it('throws ProviderError{NotFound} on empty response', async () => {
      sdk.Tip.mockResolvedValueOnce({});
      await expect(provider.ledgerTip()).rejects.toThrow(ProviderFailure.NotFound);
      sdk.Tip.mockResolvedValueOnce({ queryBlock: [] });
      await expect(provider.ledgerTip()).rejects.toThrow(ProviderFailure.NotFound);
    });

    it('throws ProviderError{InvalidResponse} if provider returns multiple tips', async () => {
      sdk.Tip.mockResolvedValueOnce({ queryBlock: [tip, tip] });
      await expect(provider.ledgerTip()).rejects.toThrow(ProviderFailure.InvalidResponse);
    });
  });
});
