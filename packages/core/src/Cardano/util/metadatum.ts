import { Metadatum, MetadatumMap } from '../types';

/**
 * @returns {MetadatumMap | null} null if Metadatum is not MetadatumMap
 */
export const asMetadatumMap = (metadatum: Metadatum | undefined): MetadatumMap | null => {
  if (metadatum instanceof Map) {
    return metadatum;
  }
  return null;
};

/**
 * @returns {Metadatum[] | null} null if Metadatum is not an array of metadatum
 */
export const asMetadatumArray = (metadatum: Metadatum | undefined): Metadatum[] | null => {
  if (Array.isArray(metadatum)) {
    return metadatum;
  }
  return null;
};
