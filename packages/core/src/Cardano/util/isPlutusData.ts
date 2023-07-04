import { ConstrPlutusData, PlutusList, PlutusMap } from '../types';

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
