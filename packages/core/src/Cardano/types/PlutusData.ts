/* eslint-disable no-use-before-define */
/* eslint-disable unicorn/number-literal-case */

import type { HexBlob } from '@cardano-sdk/util';

export enum PlutusListEncoding {
  FixedLength,
  IndefiniteLength = 0x9f
}

export enum PlutusMapEncoding {
  FixedLength,
  IndefiniteLength = 0xbf
}

export type PlutusList = {
  /** This may be set when deserializing a datum. Useful for round-trip reserialization. */
  cbor?: HexBlob;
  /** This property provides granular control of how it should be serialized. Useful when constructing a new datum. */
  encoding?: PlutusListEncoding;
  items: PlutusData[];
};

export type PlutusMap = {
  /** This may be set when deserializing a datum. Useful for round-trip reserialization. */
  cbor?: HexBlob;
  /** This property provides granular control of how it should be serialized. Useful when constructing a new datum. */
  encoding?: PlutusMapEncoding;
  data: Map<PlutusData, PlutusData>;
};

export type ConstrPlutusData = {
  /** This may be set when deserializing a datum. Useful for round-trip reserialization. */
  cbor?: HexBlob;
  constructor: bigint;
  fields: PlutusList;
};

export type PlutusData = bigint | Uint8Array | PlutusList | PlutusMap | ConstrPlutusData;
