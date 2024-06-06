import { ProviderError, ProviderUtil } from '../../src/index.js';
import type { Cardano } from '../../src/index.js';

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

  describe('jsonToMetadatum', () => {
    it('converts metadata json to core metadatum', () => {
      expect(ProviderUtil.jsonToMetadatum(1)).toBe(1n);
      expect(ProviderUtil.jsonToMetadatum('a')).toBe('a');
      expect(() => ProviderUtil.jsonToMetadatum(null)).toThrowError(ProviderError);
      // eslint-disable-next-line unicorn/no-useless-undefined
      expect(() => ProviderUtil.jsonToMetadatum(undefined)).toThrowError(ProviderError);
      expect(ProviderUtil.jsonToMetadatum(['a', 1, [2]])).toEqual(['a', 1n, [2n]]);
      expect(ProviderUtil.jsonToMetadatum({ 123: '1234', a: 'a', b: 1, c: { d: 2 } })).toEqual(
        new Map<Cardano.Metadatum, Cardano.Metadatum>([
          [123n, '1234'],
          ['a', 'a'],
          ['b', 1n],
          ['c', new Map([['d', 2n]])]
        ])
      );
    });
  });
});
