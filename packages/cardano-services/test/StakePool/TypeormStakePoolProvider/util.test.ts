import { DEFAULT_FUZZY_SEARCH_OPTIONS } from '../../../src';
import { validateFuzzyOptions, withTextFilter } from '../../../src/StakePool/TypeormStakePoolProvider/util';

describe('TypeormStakePoolProvider utils', () => {
  describe('validateFuzzyOptions', () => {
    it('throws if value is not a valid JSON encoded string', () =>
      expect(() => validateFuzzyOptions('test')).toThrow('Unexpected token e in JSON at position 1'));
    it('throws if value is not an object', () =>
      expect(() => validateFuzzyOptions('"test"')).toThrow('must be an object'));
    it('throws without threshold', () =>
      expect(() => validateFuzzyOptions('{}')).toThrow('threshold must be a number'));
    it('throws with not number threshold', () =>
      expect(() => validateFuzzyOptions('{"threshold":"test"}')).toThrow('threshold must be a number'));
    it('throws with negative threshold', () =>
      expect(() => validateFuzzyOptions('{"threshold":-1}')).toThrow('expected 0 <= threshold <= 1'));
    it('throws with high threshold', () =>
      expect(() => validateFuzzyOptions('{"threshold":10}')).toThrow('expected 0 <= threshold <= 1'));
    it('throws without weights', () =>
      expect(() => validateFuzzyOptions('{"threshold":0.4}')).toThrow('weights must be an object'));
    it('throws with no object weights', () =>
      expect(() => validateFuzzyOptions('{"threshold":0.4,"weights":"test"}')).toThrow('weights must be an object'));
    it('throws without a weight', () =>
      expect(() => validateFuzzyOptions('{"threshold":0.4,"weights":{}}')).toThrow(
        'weights.description must be a positive number'
      ));
    it('throws with not number weight', () =>
      expect(() => validateFuzzyOptions('{"threshold":0.4,"weights":{"description":"test"}}')).toThrowError(
        'weights.description must be a positive number'
      ));
    it('correctly parse a valid options object', () =>
      expect(
        validateFuzzyOptions(
          '{"distance":100,"fieldNormWeight":1,"ignoreFieldNorm":false,"ignoreLocation":false,"location":0,"minMatchCharLength":3,"threshold":0.4,"useExtendedSearch":false,"weights":{"description":1,"homepage":2,"name":3,"poolId":4,"ticker":4}}'
        )
      ).toStrictEqual(DEFAULT_FUZZY_SEARCH_OPTIONS));
  });

  describe('withTextFilter', () => {
    it('returns false without filters', () => expect(withTextFilter()).toBeFalsy());
    it('returns false without filters.text', () => expect(withTextFilter({})).toBeFalsy());
    it('returns false with filters.text.length === 0', () => expect(withTextFilter({ text: '' })).toBeFalsy());
    it('returns true with valid filters.text', () => expect(withTextFilter({ text: '123' })).toBeTruthy());
  });
});
