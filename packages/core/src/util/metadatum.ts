/* eslint-disable @typescript-eslint/no-explicit-any */
import { InvalidArgumentError } from '@cardano-sdk/util';
import type { Metadatum, MetadatumMap } from '../Cardano/types/AuxiliaryData';

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
export const jsonToMetadatum = (json: any): Metadatum => {
  if (json === null) throw new InvalidArgumentError('json', 'JSON value can not be null');
  switch (typeof json) {
    case 'boolean':
    case 'undefined':
      throw new InvalidArgumentError('json', `JSON value can not be ${typeof json}`);
    case 'number':
    case 'bigint': {
      return BigInt(json);
    }
    case 'string':
      return String(json);
    default: {
      if (Array.isArray(json)) {
        const array = [];
        for (const metadataItem of json) {
          array.push(jsonToMetadatum(metadataItem));
        }
        return array;
      } else if (ArrayBuffer.isView(json)) {
        return new Uint8Array(json.buffer);
      }

      const metadataMap = new Map<Metadatum, Metadatum>();

      for (const key in json) {
        const val = json[key];
        metadataMap.set(jsonToMetadatum(key), jsonToMetadatum(val));
      }

      return metadataMap;
    }
  }
};

/**
 * Converts any Metadatum object to json.
 *
 * @param metadatum The metadatum to be converted to json.
 * @returns The json object.
 */
export const metadatumToJson = (metadatum: Metadatum): any => {
  if (metadatum === null) throw new InvalidArgumentError('data', 'Metadatum value can not be null');

  switch (typeof metadatum) {
    case 'boolean':
    case 'undefined':
    case 'number':
      throw new InvalidArgumentError('metadatum', `Metadatum value can not be ${typeof metadatum}`);
    case 'bigint': {
      return metadatum;
    }
    case 'string':
      return metadatum;
    default: {
      if (Array.isArray(metadatum)) {
        const array = [];
        for (const metadataItem of metadatum) {
          array.push(metadatumToJson(metadataItem));
        }
        return array;
      } else if (ArrayBuffer.isView(metadatum)) {
        return new Uint8Array(metadatum);
      }
      const object: Object = {};

      for (const [key, value] of metadatum.entries()) {
        object[metadatumToJson(key) as keyof Object] = metadatumToJson(value);
      }

      return object;
    }
  }
};
