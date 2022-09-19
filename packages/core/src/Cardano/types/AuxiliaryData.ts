import { Hash32ByteBase16 } from '../util/primitives';
import { Script } from './Script';

// eslint-disable-next-line no-use-before-define
export type MetadatumMap = Map<Metadatum, Metadatum>;

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Metadatum[];

export type TxMetadata = Map<bigint, Metadatum>;

export interface AuxiliaryDataBody {
  blob?: TxMetadata;
  scripts?: Script[];
}

export interface AuxiliaryData {
  hash?: Hash32ByteBase16;
  body: AuxiliaryDataBody;
}
