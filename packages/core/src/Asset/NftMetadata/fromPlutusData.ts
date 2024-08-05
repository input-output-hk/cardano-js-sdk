import { ImageMediaType, MediaType, NftMetadata, NftMetadataFile, Uri } from './types';
import { Logger } from 'ts-log';
import { asString } from './util';
import { contextLogger, isNotNil } from '@cardano-sdk/util';
import {
  isConstrPlutusData,
  isPlutusBigInt,
  isPlutusBoundedBytes,
  isPlutusList,
  isPlutusMap,
  tryConvertPlutusMapToUtf8Record
} from '../../Cardano/util';
import type { Cardano } from '../..';

const tryCoerce = <T>(
  value: string | Cardano.PlutusData | undefined,
  ctor: (v: string) => T,
  logger: Logger
): T | undefined => {
  if (typeof value !== 'string') return;
  try {
    return ctor(value);
  } catch (error) {
    logger.warn(error instanceof Error ? error.message : error);
  }
};

const mapOtherPropertyValue = (value: string | Cardano.PlutusData, logger: Logger): Cardano.Metadatum => {
  if (typeof value === 'string' || isPlutusBigInt(value) || isPlutusBoundedBytes(value)) return value;
  if (isPlutusMap(value)) {
    // eslint-disable-next-line no-use-before-define
    const properties = mapOtherProperties(tryConvertPlutusMapToUtf8Record(value, logger), logger);
    return new Map(Object.entries(properties));
  }
  const list = isPlutusList(value) ? value.items : value.fields.items;
  return list.map((item) => mapOtherPropertyValue(item, logger));
};

const mapOtherProperties = (
  additionalProperties: Partial<Record<string, string | Cardano.PlutusData>>,
  logger: Logger
): Map<string, Cardano.Metadatum> =>
  Object.entries(additionalProperties).reduce((result, [key, value]) => {
    if (typeof value !== 'undefined') {
      result.set(key, mapOtherPropertyValue(value, logger));
    }
    return result;
  }, new Map());

const undefinedIfEmpty = <K, V>(map: Map<K, V>) => (map.size > 0 ? map : undefined);

const mapFile = (file: Cardano.PlutusData, logger: Logger): NftMetadataFile | undefined => {
  if (!isPlutusMap(file)) {
    logger.warn('expected "files[n]" to be a map');
    return;
  }
  const {
    mediaType: mediaTypeStr,
    src: srcStr,
    name,
    ...additionalProperties
  } = tryConvertPlutusMapToUtf8Record(file, logger);
  const mediaType = tryCoerce(mediaTypeStr, MediaType, logger);
  const src = tryCoerce(srcStr, Uri, logger);
  if (typeof src !== 'string' || typeof mediaType !== 'string') {
    logger.warn('invalid "files[n].src" or "files[n].mediaType"');
    return;
  }
  return {
    mediaType,
    name: asString(name),
    otherProperties: undefinedIfEmpty(mapOtherProperties(additionalProperties, logger)),
    src
  };
};

const mapFiles = (files: string | Cardano.PlutusData | undefined, logger: Logger): NftMetadataFile[] | undefined => {
  if (!files) return;
  if (!isPlutusList(files)) {
    logger.warn('expected "files" to be a list');
    return;
  }
  return files.items.map((file) => mapFile(file, logger)).filter(isNotNil);
};

const getConditionalValidators = (strict: boolean, logger: Logger) => ({
  isNameValid: (name: Cardano.PlutusData | string | undefined): name is string | undefined => {
    if (typeof name === 'string') return true;
    if (typeof name === 'undefined') {
      if (strict) {
        logger.debug('Invalid PlutusData: "name" is required');
        return false;
      }
      return true;
    }
    logger.debug('Invalid PlutusData: "name" must be utf8 bounded bytes');
    return false;
  },
  isValidDatumShape: (plutusData: Cardano.PlutusData | undefined): plutusData is Cardano.ConstrPlutusData => {
    const minNumberOfFields = strict ? 3 : 2;
    const isValid =
      isConstrPlutusData(plutusData) &&
      plutusData.constructor === 0n &&
      plutusData.fields.items.length >= minNumberOfFields;
    if (!isValid)
      logger.debug(
        `Invalid PlutusData: expecting ConstrPlutusData with 0th constructor and ${minNumberOfFields} items`
      );
    return isValid;
  }
});

/**
 * @param plutusData CIP-0068 (label 222) datum
 * @param parentLogger logger
 */
export const fromPlutusData = (
  plutusData: Cardano.PlutusData | undefined,
  parentLogger: Logger,
  strict = false
): NftMetadata | null => {
  const logger = contextLogger(parentLogger, 'NftMetadata.fromPlutusData');
  const conditionalValidators = getConditionalValidators(strict, logger);
  if (!conditionalValidators.isValidDatumShape(plutusData)) {
    return null;
  }

  const [nftMetadata, version] = plutusData.fields.items;
  if (!isPlutusMap(nftMetadata) || !isPlutusBigInt(version)) {
    logger.debug('Invalid PlutusData: expecting a map at [0] and integer at [1]');
    return null;
  }

  const nftMetadataRecord = tryConvertPlutusMapToUtf8Record(nftMetadata, logger);
  const { name, image, mediaType, description, files, ...additionalProperties } = nftMetadataRecord;

  if (!conditionalValidators.isNameValid(name)) {
    return null;
  }

  if (typeof image !== 'string') {
    logger.debug('Invalid PlutusData: "image" must be UTF-8 bounded bytes');
    return null;
  }

  const imageAsUri = tryCoerce(image, Uri, logger);
  if (!imageAsUri) {
    return null;
  }

  return {
    description: asString(description),
    files: mapFiles(files, logger),
    image: imageAsUri,
    mediaType: tryCoerce(mediaType, ImageMediaType, logger),
    name: name || '',
    otherProperties: undefinedIfEmpty(mapOtherProperties(additionalProperties, logger)),
    version: version.toString()
  };
};
