/* eslint-disable wrap-regex */
import { Cardano, InvalidStringError } from '@cardano-sdk/core';

export type Uri = Cardano.util.OpaqueString<'Uri'>;
export const Uri = (uri: string) => {
  if (/^[a-z]+:\/\/.+/.test(uri)) {
    return uri as unknown as Uri;
  }
  throw new InvalidStringError(
    'Expected Uri to start with "[protocol]://", where protocol is usually "https" or "ipfs"'
  );
};

export type ImageMediaType = Cardano.util.OpaqueString<'ImageMediaType'>;
export const ImageMediaType = (mediaType: string) => {
  if (/^image\/.+$/.test(mediaType)) {
    return mediaType as unknown as ImageMediaType;
  }
  throw new InvalidStringError('Expected media type to be "image/*"');
};

export type MediaType = Cardano.util.OpaqueString<'MediaType'>;
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
  src: Uri | Uri[];
  otherProperties?: {
    [key: string]: Cardano.Metadatum | undefined;
  };
}

/**
 * https://cips.cardano.org/cips/cip25/
 */
export interface NftMetadata {
  name: string;
  image: Uri | Uri[];
  version: string;
  mediaType?: ImageMediaType;
  files?: NftMetadataFile[];
  description?: string | string[];
  otherProperties?: {
    [key: string]: Cardano.Metadatum | undefined;
  };
}

export interface NftMetadataProvider {
  (asset: Cardano.Asset): Promise<NftMetadata | undefined>;
}
