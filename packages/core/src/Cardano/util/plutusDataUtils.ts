import { TextDecoder } from 'web-encoding';
import type { ConstrPlutusData, PlutusData, PlutusList, PlutusMap } from '../types/index.js';
import type { Logger } from 'ts-log';

export const isPlutusBoundedBytes = (plutusData: unknown): plutusData is Uint8Array => ArrayBuffer.isView(plutusData);

export const isAnyPlutusDataCollection = (
  plutusData: unknown
): plutusData is PlutusList | PlutusMap | ConstrPlutusData =>
  typeof plutusData === 'object' && !isPlutusBoundedBytes(plutusData);

export const isPlutusList = (plutusData: unknown): plutusData is PlutusList =>
  isAnyPlutusDataCollection(plutusData) && 'items' in plutusData;

export const isPlutusMap = (plutusData: unknown): plutusData is PlutusMap =>
  isAnyPlutusDataCollection(plutusData) && 'data' in plutusData;

export const isConstrPlutusData = (plutusData: unknown): plutusData is ConstrPlutusData =>
  isAnyPlutusDataCollection(plutusData) && 'fields' in plutusData;

export const isPlutusBigInt = (plutusData: unknown): plutusData is bigint => typeof plutusData === 'bigint';

const utf8Decoder = new TextDecoder('utf8', { fatal: true });

const tryConvertPlutusDataToUtf8String = (data: PlutusData): PlutusData | string => {
  if (!isPlutusBoundedBytes(data)) return data;
  try {
    return utf8Decoder.decode(data);
  } catch {
    return data;
  }
};

export const tryConvertPlutusMapToUtf8Record = (
  map: PlutusMap,
  logger: Logger
): Partial<Record<string, string | PlutusData>> => {
  const record: Partial<Record<string, string | PlutusData>> = {};
  for (const [key, value] of map.data.entries()) {
    const keyAsStr = tryConvertPlutusDataToUtf8String(key);
    if (typeof keyAsStr !== 'string') {
      logger.warn('Failed to decode plutus map key', key);
      continue;
    }
    record[keyAsStr] = tryConvertPlutusDataToUtf8String(value);
  }
  return record;
};
