import { BuildInfo } from '../Http';
import { CACHE_TTL_LOWER_LIMIT, CACHE_TTL_UPPER_LIMIT } from '../InMemoryCache';
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
    throw new Error(`Invalid JSON format of build-info: ${error}`);
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

export const floatValidator = (description: string) => (float: string) => {
  const parsed = Number.parseFloat(float);

  if (parsed.toString() === float || (float.startsWith('.') && parsed.toString() === `0${float}`)) return parsed;

  throw new TypeError(`${description} - "${float}" is not a number`);
};

export const integerValidator = (description: string) => (integer: string) => {
  const parsed = Number.parseInt(integer, 10);

  if (parsed.toString() === integer) return parsed;

  throw new TypeError(`${description} - "${integer}" is not an integer`);
};

export const cacheTtlValidator = (ttlInSecs: string, range: Required<Range<number>>, description: string) => {
  const cacheTtlInSecs = integerValidator(description)(ttlInSecs);
  throwIfOutsideRange(cacheTtlInSecs, range, description);
  return cacheTtlInSecs;
};

export const dbCacheValidator = (description: string) => (ttl: string) =>
  cacheTtlValidator(ttl, { lowerBound: CACHE_TTL_LOWER_LIMIT, upperBound: CACHE_TTL_UPPER_LIMIT }, description);

export const urlValidator =
  (description: string, toString = false) =>
  (url: string) => {
    try {
      const parsed = new URL(url);

      return toString ? parsed.toString() : parsed;
    } catch {
      throw new Error(`${description} - "${url}" is not an URL`);
    }
  };
