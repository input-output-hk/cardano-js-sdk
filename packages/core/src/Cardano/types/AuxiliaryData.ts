import * as Cardano from '.';

// eslint-disable-next-line no-use-before-define
export type MetadatumMap = Map<Metadatum, Metadatum>;

export type Metadatum = bigint | MetadatumMap | string | Uint8Array | Metadatum[];

export type TxMetadata = Map<bigint, Metadatum>;

export interface AuxiliaryDataBody {
  blob?: TxMetadata;
  scripts?: Cardano.Script[];
}

export interface AuxiliaryData {
  hash?: Cardano.Hash32ByteBase16;
  body: AuxiliaryDataBody;
}
