import { AssetInfo, ImageMediaType, MediaType, NftMetadata, NftMetadataFile, Uri } from '../types';
import { Cardano } from '../..';
import { CustomError } from 'ts-custom-error';
import { Logger } from 'ts-log';
import { asMetadatumArray, asMetadatumMap } from '../../util/metadatum';
import { assetIdFromPolicyAndName } from './assetId';
import { isNotNil } from '@cardano-sdk/util';
import difference from 'lodash/difference';

class InvalidFileError extends CustomError {}

const isString = (obj: unknown): obj is string => typeof obj === 'string';

const asString = (obj: unknown): string | undefined => {
  if (typeof obj === 'string') {
    return obj;
  }
};

const asStringArray = (metadatum: Cardano.Metadatum | undefined): string[] | undefined => {
  if (Array.isArray(metadatum)) {
    const result = metadatum.map(asString);
    if (result.some((str) => typeof str === 'undefined')) {
      return undefined;
    }
    // Based on the CIP25: base64-encoded fields spec
    if (result[0]?.startsWith('data:')) {
      return [result.join('')];
    }
    return result as string[];
  }
  const str = asString(metadatum);
  if (str) {
    return [str];
  }
};

const mapOtherProperties = (metadata: Cardano.MetadatumMap, primaryProperties: string[]) => {
  const extraProperties = difference([...metadata.keys()].filter(isString), primaryProperties);
  if (extraProperties.length === 0) return;
  return extraProperties.reduce((result, key) => {
    result.set(key, metadata.get(key)!);
    return result;
  }, new Map<string, Cardano.Metadatum>());
};

const toArray = <T>(value: T | T[]): T[] => (Array.isArray(value) ? value : [value]);

const missingFileFieldLogMessage = (fieldType: string, assetId: Cardano.AssetId) =>
  `Omitting cip25 metadata file: missing "${fieldType}". AssetId: ${assetId}`;

const mapFile = (metadatum: Cardano.Metadatum, assetId: Cardano.AssetId, logger: Logger): NftMetadataFile | null => {
  const file = asMetadatumMap(metadatum);
  if (!file) throw new InvalidFileError();

  const mediaType = asString(file.get('mediaType'));
  if (!mediaType) {
    logger.warn(missingFileFieldLogMessage('mediaType', assetId));
    return null;
  }
  const name = asString(file.get('name'));
  if (!name) {
    logger.warn(missingFileFieldLogMessage('name', assetId));
    return null;
  }

  const unknownTypeSrc = file.get('src');
  const src = asStringArray(unknownTypeSrc)?.map((fileSrc) => Uri(fileSrc));

  if (!src) {
    logger.warn(missingFileFieldLogMessage('source', assetId));
    return null;
  }

  return {
    mediaType: MediaType(mediaType),
    name,
    otherProperties: mapOtherProperties(file, ['mediaType', 'name', 'src']),
    src: toArray(src)
  };
};

/**
 * Gets the `Map<AssetName, NFTMetadata>` relative to the given policyId from the given
 * `Map<PolicyId, Map<AssetName, NFTMetadata>>`.
 *
 * The policyId in the `policy` Map can be encoded as per CIP-0025 v1 or v2 specifications.
 *
 * @param policy The `MetadatumMap` containing the NFT metadata for all the NFT assets
 * @returns The `MetadatumMap` containing the NFT metadata for all the NFT assets with the given policyId
 */
const getPolicyMetadata = (policy: Cardano.MetadatumMap, policyId: Cardano.PolicyId) =>
  asMetadatumMap(
    policy.get(policyId) ||
      (() => {
        for (const [key, value] of policy.entries()) {
          if (ArrayBuffer.isView(key) && Buffer.from(key).toString('hex') === policyId) return value;
        }
      })()
  );

/**
 * Gets the `NFTMetadata` relative to the given assetName from the given `Map<AssetName, NFTMetadata>`.
 *
 * The assetName in the `policy` Map can be encoded as per CIP-0025 v1 (hex or utf8) or v2 specifications.
 *
 * @param policy The `MetadatumMap` containing the NFT metadata for all the NFT assets with a specific policyId.
 * @returns The NFT metadata for the requested asset
 */
const getAssetMetadata = (policy: Cardano.MetadatumMap, assetName: Cardano.AssetName) =>
  asMetadatumMap(
    policy.get(assetName) ||
      policy.get(Buffer.from(assetName, 'hex').toString('utf8')) ||
      (() => {
        for (const [key, value] of policy.entries()) {
          if (ArrayBuffer.isView(key) && Buffer.from(key).toString('hex') === assetName) return value;
        }
      })()
  );

// TODO: consider hoisting this function together with cip25 types to core or a new cip25 package
/**
 * @returns {NftMetadata | null} CIP-0025 NFT metadata
 */
export const metadatumToCip25 = (
  asset: Pick<AssetInfo, 'policyId' | 'name'>,
  metadatumMap: Cardano.MetadatumMap | undefined,
  logger: Logger
): NftMetadata | null => {
  const cip25Metadata = metadatumMap?.get(721n);
  if (!cip25Metadata) return null;
  const cip25MetadatumMap = asMetadatumMap(cip25Metadata);
  if (!cip25MetadatumMap) return null;
  const policy = getPolicyMetadata(cip25MetadatumMap, asset.policyId);
  if (!policy) return null;
  const assetMetadata = getAssetMetadata(policy, asset.name);
  if (!assetMetadata) return null;
  const name = asString(assetMetadata.get('name'));
  const image = asStringArray(assetMetadata.get('image'));
  if (!name || !image) {
    logger.warn('Invalid CIP-25 metadata', assetMetadata);
    return null;
  }
  const mediaType = asString(assetMetadata.get('mediaType'));
  const files = asMetadatumArray(assetMetadata.get('files'));
  const assetId = assetIdFromPolicyAndName(asset.policyId, asset.name);

  try {
    return {
      description: asStringArray(assetMetadata.get('description')),
      files: files?.map((file) => mapFile(file, assetId, logger)).filter(isNotNil),
      image: image.map((img) => Uri(img)),
      mediaType: mediaType ? ImageMediaType(mediaType) : undefined,
      name,
      otherProperties: mapOtherProperties(assetMetadata, ['name', 'image', 'mediaType', 'description', 'files']),
      version: asString(policy.get('version')) || '1.0'
    };
  } catch (error: unknown) {
    // Any error here means metadata was invalid
    logger.warn('Invalid CIP-25 metadata', assetMetadata, error);
    return null;
  }
};
