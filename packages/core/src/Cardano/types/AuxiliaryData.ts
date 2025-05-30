import * as Crypto from '@cardano-sdk/crypto';
import * as Serialization from '../../Serialization/AuxiliaryData';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { Script } from './Script';

// eslint-disable-next-line no-use-before-define
export type MetadatumMap = Map<Metadatum, Metadatum>;

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Metadatum[];

export type TxMetadata = Map<bigint, Metadatum>;

export interface AuxiliaryData {
  blob?: TxMetadata;
  scripts?: Script[];
}

export const computeAuxiliaryDataHash = (data: AuxiliaryData | undefined): Hash32ByteBase16 | undefined =>
  data ? Crypto.blake2b.hash<Hash32ByteBase16>(Serialization.AuxiliaryData.fromCore(data).toCbor(), 32) : undefined;
