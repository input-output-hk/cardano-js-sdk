import { ConstrPlutusData, PlutusData, PlutusList, PlutusMap } from '../types';

export const isPlutusBoundedBytes = (plutusData: PlutusData): plutusData is Uint8Array =>
  ArrayBuffer.isView(plutusData);

export const isAnyPlutusDataCollection = (
  plutusData: PlutusData
): plutusData is PlutusList | PlutusMap | ConstrPlutusData =>
  typeof plutusData === 'object' && !isPlutusBoundedBytes(plutusData);

export const isPlutusList = (plutusData: PlutusData): plutusData is PlutusList =>
  isAnyPlutusDataCollection(plutusData) && 'items' in plutusData;

export const isPlutusMap = (plutusData: PlutusData): plutusData is PlutusMap =>
  isAnyPlutusDataCollection(plutusData) && 'data' in plutusData;

export const isConstrPlutusData = (plutusData: PlutusData): plutusData is ConstrPlutusData =>
  isAnyPlutusDataCollection(plutusData) && 'fields' in plutusData;

export const isPlutusBigInt = (plutusData: PlutusData): plutusData is bigint => typeof plutusData === 'bigint';
