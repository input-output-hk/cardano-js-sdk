import { AssetInfo, ImageMediaType, MediaType, NftMetadata, NftMetadataFile, Uri } from '../types';
import { CustomError } from 'ts-custom-error';
import { Metadatum, MetadatumMap, util } from '../../Cardano';
import { dummyLogger } from 'ts-log';
import { omit } from 'lodash-es';

class InvalidFileError extends CustomError {}

const asString = (obj: unknown): string | undefined => {
  if (typeof obj === 'string') {
    return obj;
  }
};

const mapOtherProperties = (metadata: MetadatumMap, primaryProperties: string[]) => {
  const extraProperties = omit(metadata, primaryProperties);
  return Object.keys(extraProperties).length > 0 ? extraProperties : undefined;
};

const mapFile = (metadatum: Metadatum): NftMetadataFile => {
  const file = util.metadatum.asMetadatumMap(metadatum);
  if (!file) throw new InvalidFileError();
  const mediaType = asString(file.mediaType);
  const name = asString(file.name);
  const srcAsString = asString(file.src);
  const src = srcAsString
    ? Uri(srcAsString)
    : util.metadatum.asMetadatumArray(file.src)?.map((fileSrc) => {
        const fileSrcAsString = asString(fileSrc);
        if (!fileSrcAsString) throw new InvalidFileError();
        return Uri(fileSrcAsString);
      });
  if (!name || !mediaType || !src) throw new InvalidFileError();
  return {
    mediaType: MediaType(mediaType),
    name,
    otherProperties: mapOtherProperties(file, ['mediaType', 'name', 'src']),
    src
  };
};

/**
 * Also considers asset name encoded in utf8 within metadata valid
 */
const getAssetMetadata = (policy: MetadatumMap, asset: Pick<AssetInfo, 'name'>) =>
  util.metadatum.asMetadatumMap(
    policy[asset.name.toString()] || policy[Buffer.from(asset.name, 'hex').toString('utf8')]
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
  const cip25Metadata = metadatumMap?.['721'];
  if (!cip25Metadata) return;
  const cip25MetadatumMap = util.metadatum.asMetadatumMap(cip25Metadata);
  if (!cip25MetadatumMap) return;
  const policy = util.metadatum.asMetadatumMap(cip25MetadatumMap[asset.policyId.toString()]);
  if (!policy) return;
  const assetMetadata = getAssetMetadata(policy, asset);
  if (!assetMetadata) return;
  const name = asString(assetMetadata.name);
  const image = asString(assetMetadata.image);
  if (!name || !image) {
    logger.warn('Invalid CIP-25 metadata', assetMetadata);
    return;
  }
  const mediaType = asString(assetMetadata.mediaType);
  const files = util.metadatum.asMetadatumArray(assetMetadata.files);
  try {
    return {
      description: asString(assetMetadata.description),
      files: files ? files.map(mapFile) : undefined,
      image: Uri(image),
      mediaType: mediaType ? ImageMediaType(mediaType) : undefined,
      name,
      otherProperties: mapOtherProperties(assetMetadata, ['name', 'image', 'mediaType', 'description', 'files']),
      version: asString(policy.version) || '1.0'
    };
  } catch (error: unknown) {
    // Any error here means metadata was invalid
    logger.warn('Invalid CIP-25 metadata', assetMetadata, error);
  }
};
