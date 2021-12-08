import { InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { createProvider } from '../src/util';

describe('util', () => {
  describe('createProvider', () => {
    const providerFunctions = { fn: jest.fn() };
    let provider: typeof providerFunctions;

    beforeEach(() => {
      providerFunctions.fn.mockReset();
      provider = createProvider(() => providerFunctions)('some://url');
    });

    it('returns provider with functions from provided implementation', async () => {
      providerFunctions.fn.mockResolvedValueOnce('result');
      expect(await provider.fn()).toBe('result');
    });

    it('maps InvalidStringError to ProviderError{InvalidResponse}', async () => {
      const error = new InvalidStringError('error');
      providerFunctions.fn.mockRejectedValueOnce(error);
      await expect(provider.fn()).rejects.toThrowError(new ProviderError(ProviderFailure.InvalidResponse, error));
    });

    it('maps other errors to ProviderError{Unknown}', async () => {
      const error = new Error('other error');
      providerFunctions.fn.mockRejectedValueOnce(error);
      await expect(provider.fn()).rejects.toThrowError(new ProviderError(ProviderFailure.Unknown, error));
    });
  });
});
