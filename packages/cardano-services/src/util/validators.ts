import { BuildInfo } from '../Http';
import { CACHE_TTL_LOWER_LIMIT, CACHE_TTL_UPPER_LIMIT } from '../InMemoryCache';
import { MissingProgramOption } from '../Program/errors/MissingProgramOption';
import { ProviderServerOptionDescriptions, ServiceNames } from '../Program/programs/types';
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

export const cacheTtlValidator = (ttlInSecs: string) => {
  const cacheTtlInSecs = Number.parseInt(ttlInSecs, 10);

  if (
    typeof cacheTtlInSecs === 'number' &&
    cacheTtlInSecs >= CACHE_TTL_LOWER_LIMIT &&
    cacheTtlInSecs <= CACHE_TTL_UPPER_LIMIT
  ) {
    return cacheTtlInSecs;
  }

  throw new MissingProgramOption(ServiceNames.NetworkInfo, ProviderServerOptionDescriptions.DbCacheTtl);
};
