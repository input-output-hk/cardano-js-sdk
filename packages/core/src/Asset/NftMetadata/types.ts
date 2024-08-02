/* eslint-disable wrap-regex */
import { InvalidStringError, OpaqueString } from '@cardano-sdk/util';
import { Metadatum } from '../../Cardano/types/AuxiliaryData';

export type Uri = OpaqueString<'Uri'>;
export const Uri = (uri: string) => {
  if (/^[a-z]+:\/\/.+/.test(uri)) {
    return uri as unknown as Uri;
  }
  if (uri.startsWith('data:')) {
    return uri as unknown as Uri;
  }
  if (uri.startsWith('Qm') && uri.length === 46) {
    return `ipfs://${uri}` as unknown as Uri;
  }
  throw new InvalidStringError(
    'Expected Uri to start with "[protocol]:", where protocol is usually "https", "ipfs" or "data"'
  );
};

export type ImageMediaType = OpaqueString<'ImageMediaType'>;
export const ImageMediaType = (mediaType: string) => {
  if (/^image\/.+$/.test(mediaType)) {
    return mediaType as unknown as ImageMediaType;
  }
  throw new InvalidStringError('Expected media type to be "image/*"');
};

export type MediaType = OpaqueString<'MediaType'>;
export const MediaType = (mediaType: string) => {
  if (/^[a-z]+\/.+$/.test(mediaType)) {
    return mediaType as unknown as MediaType;
  }
  throw new InvalidStringError('Expected media type to be "*/*"');
};

/** https://cips.cardano.org/cips/cip25/ */
export interface NftMetadataFile {
  name?: string;
  mediaType: MediaType;
  src: Uri;
  otherProperties?: Map<string, Metadatum>;
}

/** https://cips.cardano.org/cips/cip25/ https://cips.cardano.org/cips/cip68/ (label 222) */
export interface NftMetadata {
  name: string;
  image: Uri;
  version: string;
  mediaType?: ImageMediaType;
  files?: NftMetadataFile[];
  description?: string;
  otherProperties?: Map<string, Metadatum>;
}
