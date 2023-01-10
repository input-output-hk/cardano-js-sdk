import { BuildInfo } from '../Http';
import { CACHE_TTL_LOWER_LIMIT, CACHE_TTL_UPPER_LIMIT } from '../InMemoryCache';
import { MissingProgramOption, ProgramOptionDescriptions, ServiceNames } from '../Program';
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

export const cacheTtlValidator = (ttl: string) => {
  const cacheTtl = Number.parseInt(ttl, 10);

  if (typeof cacheTtl === 'number' && cacheTtl >= CACHE_TTL_LOWER_LIMIT && cacheTtl <= CACHE_TTL_UPPER_LIMIT) {
    // The cli script accepts TTLs in minutes, but the underlying level express TTLs in seconds
    return cacheTtl * 60;
  }

  throw new MissingProgramOption(ServiceNames.NetworkInfo, ProgramOptionDescriptions.DbCacheTtl);
};
