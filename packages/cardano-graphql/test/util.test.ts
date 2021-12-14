import { InvalidStringError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { createProvider, getExactlyOneObject } from '../src/util';

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

  describe('getExactlyOneObject', () => {
    it('throws ProviderError{NotFound} on empty response', async () => {
      expect(() => getExactlyOneObject(undefined, 'obj')).toThrow(ProviderFailure.NotFound);
      expect(() => getExactlyOneObject(null, 'obj')).toThrow(ProviderFailure.NotFound);
      expect(() => getExactlyOneObject([], 'obj')).toThrow(ProviderFailure.NotFound);
    });

    it('throws ProviderError{InvalidResponse} with multiple objects', async () => {
      expect(() => getExactlyOneObject([{}, {}], 'obj')).toThrow(ProviderFailure.InvalidResponse);
    });

    it('throws ProviderError{InvalidResponse} with null/undefined object', async () => {
      expect(() => getExactlyOneObject([null], 'obj')).toThrow(ProviderFailure.InvalidResponse);
      expect(() => getExactlyOneObject([undefined], 'obj')).toThrow(ProviderFailure.InvalidResponse);
    });
  });
});
