import { CSL, coreToCsl as fromCore, cslToCore as toCore } from '../../CSL';
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

/**
 * Converts any json object to Metadatum.
 *
 * @param json The json object to be converted.
 * @returns The metadatum.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const jsonToMetadatum = (json: any): Metadatum =>
  toCore.txMetadatum(CSL.encode_json_str_to_metadatum(JSON.stringify(json), CSL.MetadataJsonSchema.NoConversions));

/**
 * Converts any Metadatum object to json.
 *
 * @param metadatum The metadatum to be converted to json.
 * @returns The json object.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const metadatumToJson = (metadatum: Metadatum): any =>
  JSON.parse(CSL.decode_metadatum_to_json_str(fromCore.txMetadatum(metadatum), CSL.MetadataJsonSchema.NoConversions));
