import { AssetInfo, ImageMediaType, MediaType, NftMetadata, NftMetadataFile, Uri } from '../types';
import { CustomError } from 'ts-custom-error';
import { Metadatum, MetadatumMap, util } from '../../Cardano';
import { difference } from 'lodash-es';
import { dummyLogger } from 'ts-log';

class InvalidFileError extends CustomError {}

const isString = (obj: unknown): obj is string => typeof obj === 'string';

const asString = (obj: unknown): string | undefined => {
  if (typeof obj === 'string') {
    return obj;
  }
};

const asStringArray = (metadatum: Metadatum | undefined): string[] | undefined => {
  if (Array.isArray(metadatum)) {
    const result = metadatum.map(asString);
    if (result.some((str) => typeof str === 'undefined')) {
      return undefined;
    }
    return result as string[];
  }
  const str = asString(metadatum);
  if (str) {
    return [str];
  }
};

const mapOtherProperties = (metadata: MetadatumMap, primaryProperties: string[]) => {
  const extraProperties = difference([...metadata.keys()].filter(isString), primaryProperties);
  if (extraProperties.length === 0) return;
  return extraProperties.reduce((result, key) => {
    result.set(key, metadata.get(key)!);
    return result;
  }, new Map<string, Metadatum>());
};

const toArray = <T>(value: T | T[]): T[] => (Array.isArray(value) ? value : [value]);

const mapFile = (metadatum: Metadatum): NftMetadataFile => {
  const file = util.metadatum.asMetadatumMap(metadatum);
  if (!file) throw new InvalidFileError();
  const mediaType = asString(file.get('mediaType'));
  const name = asString(file.get('name'));
  const unknownTypeSrc = file.get('src');
  if (!unknownTypeSrc) throw new InvalidFileError();
  const srcAsString = asString(unknownTypeSrc);
  const src = srcAsString
    ? Uri(srcAsString)
    : util.metadatum.asMetadatumArray(unknownTypeSrc)?.map((fileSrc) => {
        const fileSrcAsString = asString(fileSrc);
        if (!fileSrcAsString) throw new InvalidFileError();
        return Uri(fileSrcAsString);
      });
  if (!name || !mediaType || !src) throw new InvalidFileError();
  return {
    mediaType: MediaType(mediaType),
    name,
    otherProperties: mapOtherProperties(file, ['mediaType', 'name', 'src']),
    src: toArray(src)
  };
};

/**
 * Also considers asset name encoded in utf8 within metadata valid
 */
const getAssetMetadata = (policy: MetadatumMap, asset: Pick<AssetInfo, 'name'>) =>
  util.metadatum.asMetadatumMap(
    policy.get(asset.name.toString()) || policy.get(Buffer.from(asset.name, 'hex').toString('utf8'))
  );

// TODO: consider hoisting this function together with cip25 types to core or a new cip25 package
/**
 * @returns {NftMetadata | undefined} CIP-0025 NFT metadata
 */
export const metadatumToCip25 = (
  asset: Pick<AssetInfo, 'policyId' | 'name'>,
  metadatumMap: MetadatumMap | undefined,
  logger = dummyLogger
): NftMetadata | undefined => {
  const cip25Metadata = metadatumMap?.get(721n);
  if (!cip25Metadata) return;
  const cip25MetadatumMap = util.metadatum.asMetadatumMap(cip25Metadata);
  if (!cip25MetadatumMap) return;
  const policy = util.metadatum.asMetadatumMap(cip25MetadatumMap.get(asset.policyId.toString())!);
  if (!policy) return;
  const assetMetadata = getAssetMetadata(policy, asset);
  if (!assetMetadata) return;
  const name = asString(assetMetadata.get('name'));
  const image = asStringArray(assetMetadata.get('image'));
  if (!name || !image) {
    logger.warn('Invalid CIP-25 metadata', assetMetadata);
    return;
  }
  const mediaType = asString(assetMetadata.get('mediaType'));
  const files = util.metadatum.asMetadatumArray(assetMetadata.get('files'));
  try {
    return {
      description: asStringArray(assetMetadata.get('description')),
      files: files ? files.map(mapFile) : undefined,
      image: image.map((img) => Uri(img)),
      mediaType: mediaType ? ImageMediaType(mediaType) : undefined,
      name,
      otherProperties: mapOtherProperties(assetMetadata, ['name', 'image', 'mediaType', 'description', 'files']),
      version: asString(policy.get('version')) || '1.0'
    };
  } catch (error: unknown) {
    // Any error here means metadata was invalid
    logger.warn('Invalid CIP-25 metadata', assetMetadata, error);
  }
};
