import { CACHE_TTL_LOWER_LIMIT, CACHE_TTL_UPPER_LIMIT } from '../InMemoryCache';
import { MissingProgramOption, ProgramOptionDescriptions, ServiceNames } from '../Program';

export const cacheTtlValidator = (ttl: string) => {
  const cacheTtl = Number.parseInt(ttl, 10);

  if (typeof cacheTtl === 'number' && cacheTtl >= CACHE_TTL_LOWER_LIMIT && cacheTtl <= CACHE_TTL_UPPER_LIMIT) {
    // The cli script accepts TTLs in minutes, but the underlying level express TTLs in seconds
    return cacheTtl * 60;
  }

  throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.DbCacheTtl);
};
