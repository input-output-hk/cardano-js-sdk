import { ExtMetadataFormat } from '../types.js';
import { isNotNil } from '@cardano-sdk/util';
import fs from 'fs';
import path from 'path';
import type { Cardano } from '@cardano-sdk/core';
import type { Cip6ExtMetadataResponse } from './types.js';
import type { StakePoolExtMetadataResponse } from '../types.js';

/**
 * Extracts the extended metadata url, takes CIP-6 with priority if both extended properties exist
 *
 * CIP-6 standard: https://github.com/cardano-foundation/CIPs/blob/master/CIP-0006/README.md
 * AdaPools standard: https://raw.githubusercontent.com/cardanians/adapools.org/master/example-meta.json
 *
 * @returns url string
 */
export const getExtMetadataUrl = (metadata: Cardano.StakePoolMetadata) => metadata.extDataUrl ?? metadata.extended!;

/**
 * A check to determine the schema format
 *
 * CIP-6 schema: https://raw.githubusercontent.com/cardano-foundation/CIPs/b93e77119e15d8763d7548a8a00c4cb7591714e4/CIP-0006/schema.json
 * AdaPools schema: https://a.adapools.org/extended-example
 *
 * @returns extended metadata format
 */
export const getSchemaFormat = (value: Cardano.StakePoolMetadata): ExtMetadataFormat =>
  isNotNil(value.extDataUrl) ? ExtMetadataFormat.CIP6 : ExtMetadataFormat.AdaPools;

/** Loads JSON schema based on extended metadata format */
export const loadJsonSchema = (format: ExtMetadataFormat): JSON => {
  const schemaPath = path.join(__dirname, 'schemas', `${format}.json`);
  return JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
};

/** Type guard to determine if the consumed ext metadata response is in CIP-6 format */
export const isCip6Format = (response: StakePoolExtMetadataResponse): response is Cip6ExtMetadataResponse =>
  isNotNil(response.pool) || isNotNil(response.serial);
