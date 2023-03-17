import { BuildInfo } from '../Http';
import { CACHE_TTL_LOWER_LIMIT, CACHE_TTL_UPPER_LIMIT } from '../InMemoryCache';
import { ProviderServerOptionDescriptions } from '../Program/programs/types';
import { Range, throwIfOutsideRange } from '@cardano-sdk/util';
import { validate } from 'jsonschema';
import fs from 'fs';

const buildInfoSchema = {
  additionalProperties: false,
  properties: {
    extra: { type: 'object' },
    lastModified: { type: 'number' },
    lastModifiedDate: { type: 'string' },
    rev: { type: 'string' },
    shortRev: { type: 'string' }
  },
  type: 'object'
};

export const buildInfoValidator = (buildInfo: string): BuildInfo => {
  let result: BuildInfo;
  try {
    result = JSON.parse(buildInfo || '{}');
  } catch (error) {
    throw new Error(`Invalid JSON format of process.env.BUILD_INFO: ${error}`);
  }
  validate(result, buildInfoSchema, { throwError: true });
  return result;
};

export const existingFileValidator = (filePath: string) => {
  if (fs.existsSync(filePath)) {
    return filePath;
  }
  throw new Error(`No file exists at ${filePath}`);
};

export const cacheTtlValidator = <Description>(
  ttlInSecs: string,
  range: Required<Range<number>>,
  description: Description
) => {
  const cacheTtlInSecs = Number.parseInt(ttlInSecs, 10);
  if (Number.isNaN(cacheTtlInSecs)) throw new TypeError(`${description} - ${ttlInSecs} is not a number`);
  throwIfOutsideRange(cacheTtlInSecs, range, description as string);
  return cacheTtlInSecs;
};

export const dbCacheValidator = (ttl: string) =>
  cacheTtlValidator(
    ttl,
    { lowerBound: CACHE_TTL_LOWER_LIMIT, upperBound: CACHE_TTL_UPPER_LIMIT },
    ProviderServerOptionDescriptions.DbCacheTtl
  );
