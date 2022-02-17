/* eslint-disable wrap-regex */
import { InvalidStringError } from '../../errors';
import { Metadatum, util } from '../../Cardano';

export type Uri = util.OpaqueString<'Uri'>;
export const Uri = (uri: string) => {
  if (/^[a-z]+:\/\/.+/.test(uri)) {
    return uri as unknown as Uri;
  }
  throw new InvalidStringError(
    'Expected Uri to start with "[protocol]://", where protocol is usually "https" or "ipfs"'
  );
};

export type ImageMediaType = util.OpaqueString<'ImageMediaType'>;
export const ImageMediaType = (mediaType: string) => {
  if (/^image\/.+$/.test(mediaType)) {
    return mediaType as unknown as ImageMediaType;
  }
  throw new InvalidStringError('Expected media type to be "image/*"');
};

export type MediaType = util.OpaqueString<'MediaType'>;
export const MediaType = (mediaType: string) => {
  if (/^[a-z]+\/.+$/.test(mediaType)) {
    return mediaType as unknown as MediaType;
  }
  throw new InvalidStringError('Expected media type to be "*/*"');
};

/**
 * https://cips.cardano.org/cips/cip25/
 */
export interface NftMetadataFile {
  name: string;
  mediaType: MediaType;
  src: Uri[];
  otherProperties?: Map<string, Metadatum>;
}

/**
 * https://cips.cardano.org/cips/cip25/
 */
export interface NftMetadata {
  name: string;
  image: Uri[];
  version: string;
  mediaType?: ImageMediaType;
  files?: NftMetadataFile[];
  description?: string[];
  otherProperties?: Map<string, Metadatum>;
}
