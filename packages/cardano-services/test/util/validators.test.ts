import {
  CACHE_TTL_LOWER_LIMIT,
  CACHE_TTL_UPPER_LIMIT,
  MissingProgramOption,
  ProgramOptionDescriptions,
  ServiceNames
} from '../../src';
import { cacheTtlValidator } from '../../src/util/validators';

describe('utils/validators', () => {
  describe('cacheTtlValidator', () => {
    it('returns TTL in seconds with a valid value within the range', async () => {
      const ttl = '240';
      expect(cacheTtlValidator(ttl)).toEqual(Number.parseInt(ttl, 10));
    });

    it('throws a validation error if TTL is not a valid number', async () => {
      expect(() => cacheTtlValidator('not a number')).toThrowError(
        new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.DbCacheTtl)
      );
    });

    it('throws a validation error if TTL is lower than the lower limit', async () => {
      const ttl = (CACHE_TTL_LOWER_LIMIT - 1).toString();
      expect(() => cacheTtlValidator(ttl)).toThrowError(
        new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.DbCacheTtl)
      );
    });

    it('throws a validation error if TTL is higher than the upper limit', async () => {
      const ttl = (CACHE_TTL_UPPER_LIMIT + 1).toString();
      expect(() => cacheTtlValidator(ttl)).toThrowError(
        new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.DbCacheTtl)
      );
    });
  });
});
