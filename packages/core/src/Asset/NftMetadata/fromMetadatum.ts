import { AssetName } from '../../Cardano/index.js';
import { Cardano } from '../../index.js';
import { ImageMediaType, MediaType, Uri } from './types.js';
import { InvalidFileError } from './errors.js';
import { asMetadatumArray, asMetadatumMap } from '../../util/metadatum.js';
import { asString } from './util.js';
import { isNotNil } from '@cardano-sdk/util';
import difference from 'lodash/difference.js';
import type { AssetInfo } from '../types/index.js';
import type { Logger } from 'ts-log';
import type { NftMetadata, NftMetadataFile } from './types.js';

const isString = (obj: unknown): obj is string => typeof obj === 'string';
const VersionRegExp = /^\d+\.?\d?$/;

const metadatumToString = (metadatum: Cardano.Metadatum | undefined): string | undefined => {
  if (Array.isArray(metadatum)) {
    const result = metadatum.map(asString);
    if (result.some((str) => typeof str === 'undefined')) {
      return undefined;
    }
    return result.join('');
  }
  return asString(metadatum);
};

const mapOtherProperties = (metadata: Cardano.MetadatumMap, primaryProperties: string[]) => {
  const extraProperties = difference([...metadata.keys()].filter(isString), primaryProperties);
  if (extraProperties.length === 0) return;
  return extraProperties.reduce((result, key) => {
    result.set(key, metadata.get(key)!);
    return result;
  }, new Map<string, Cardano.Metadatum>());
};

const missingFieldLogMessage = (fieldType: string, assetId: Cardano.AssetId, rootLevel: boolean) =>
  `Omitting cip25 ${rootLevel ? 'root' : 'file'} metadata: missing "${fieldType}". AssetId: ${assetId}`;

const mapFile = (metadatum: Cardano.Metadatum, assetId: Cardano.AssetId, logger: Logger): NftMetadataFile | null => {
  const file = asMetadatumMap(metadatum);
  if (!file) throw new InvalidFileError();
  const name = asString(file.get('name'));
  const mediaType = asString(file.get('mediaType'));
  if (!mediaType) {
    logger.warn(missingFieldLogMessage('mediaType', assetId, false));
    return null;
  }
  const src = metadatumToString(file.get('src'));
  if (!src) {
    logger.warn(missingFieldLogMessage('source', assetId, false));
    return null;
  }

  return {
    mediaType: MediaType(mediaType),
    name,
    otherProperties: mapOtherProperties(file, ['mediaType', 'name', 'src']),
    src: Uri(src)
  };
};

/**
 * Gets the `Map<AssetName, NFTMetadata>` relative to the given policyId from the given
 * `Map<PolicyId, Map<AssetName, NFTMetadata>>`.
 *
 * The policyId in the `policy` Map can be encoded as per CIP-0025 v1 or v2 specifications.
 *
 * @param policy The `MetadatumMap` containing the NFT metadata for all the NFT assets
 * @param policyId The token policy id.
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

type AssetIdParts = Pick<AssetInfo, 'policyId' | 'name'>;
const getName = (
  assetMetadata: Cardano.MetadatumMap,
  version: string,
  asset: AssetIdParts,
  logger: Logger,
  stripInvisibleCharacters = false
) => {
  const name = asString(assetMetadata.get('name'));
  if (name) return name;
  if (version === '1.0') {
    try {
      return AssetName.toUTF8(asset.name, stripInvisibleCharacters);
    } catch (error) {
      logger.warn(error);
    }
  }
};

const parseVersion = (version: Cardano.Metadatum | undefined) => {
  if (!version) return '1.0';
  if (typeof version === 'bigint') {
    return `${version}.0`;
  }
  const stringVersion = asString(version);
  if (stringVersion && VersionRegExp.test(stringVersion)) {
    return `${Number(stringVersion)}.0`;
  }
};

/**
 * @param asset try to parse NftMetadata for this asset
 * @param metadata transaction metadata (see CIP-0025)
 * @param logger logger to use
 */
// eslint-disable-next-line complexity
export const fromMetadatum = (
  asset: AssetIdParts,
  metadata: Cardano.TxMetadata | undefined,
  logger: Logger,
  strict = false
): NftMetadata | null => {
  const cip25Metadata = metadata?.get(721n);
  if (!cip25Metadata) return null;
  const cip25MetadatumMap = asMetadatumMap(cip25Metadata);
  if (!cip25MetadatumMap) return null;
  const policy = getPolicyMetadata(cip25MetadatumMap, asset.policyId);
  if (!policy) return null;
  const version = parseVersion(policy.get('version'));
  if (!version) return null;
  const assetMetadata = getAssetMetadata(policy, asset.name);
  if (!assetMetadata) return null;
  const name = getName(assetMetadata, version, asset, logger, true);
  const image = metadatumToString(assetMetadata.get('image'));
  const assetId = Cardano.AssetId.fromParts(asset.policyId, asset.name);

  if ((strict && !name) || !image) {
    logger.warn(missingFieldLogMessage(!name ? 'name' : 'image', assetId, true));
    return null;
  }

  const mediaType = asString(assetMetadata.get('mediaType'));
  const files = asMetadatumArray(assetMetadata.get('files'));

  try {
    return {
      description: metadatumToString(assetMetadata.get('description')),
      files: files?.map((file) => mapFile(file, assetId, logger)).filter(isNotNil),
      image: Uri(image),
      mediaType: mediaType ? ImageMediaType(mediaType) : undefined,
      name: name || '',
      otherProperties: mapOtherProperties(assetMetadata, ['name', 'image', 'mediaType', 'description', 'files']),
      version
    };
  } catch (error: unknown) {
    // Any error here means metadata was invalid
    logger.warn('Invalid CIP-25 metadata', assetMetadata, error);
    return null;
  }
};
