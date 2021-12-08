import { ProviderUtil } from '../../src';

describe('ProviderUtil', () => {
  describe('withProviderErrors', () => {
    const providerError = new Error('provider-error');
    let toProviderError: jest.Mock;

    beforeEach(() => {
      toProviderError = jest.fn().mockRejectedValue(providerError);
    });

    it('adds a catch handler for every provider function', async () => {
      const provider = ProviderUtil.withProviderErrors(
        {
          a: jest.fn().mockRejectedValue(false),
          b: jest.fn().mockRejectedValue(false)
        },
        toProviderError
      );
      await expect(provider.a()).rejects.toThrow(providerError);
      await expect(provider.b()).rejects.toThrow(providerError);
    });

    it('passes through resolved value', async () => {
      const provider = ProviderUtil.withProviderErrors(
        {
          c: jest.fn().mockResolvedValue('value')
        },
        toProviderError
      );
      expect(await provider.c()).toBe('value');
    });

    it('ignores non-function properties', async () => {
      const provider = ProviderUtil.withProviderErrors({ some: 'prop' }, toProviderError);
      expect(typeof provider.some).toBe('string');
    });
  });
});
